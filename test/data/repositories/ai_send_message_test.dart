import 'dart:async';

import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/ai_repository_impl.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/repositories/ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// Records each request and answers with the event stream the test queues.
class _FakeClient implements AIClient {
  _FakeClient([this.id = AIProviderId.ollama]);

  @override
  final AIProviderId id;
  final requests = <AIRequest>[];
  final replies = <Stream<AIEvent> Function(AICancelToken?)>[];

  void reply(String text) => replies
      .add((_) => Stream.fromIterable([AITextDelta(text), const AIDone()]));

  void fail(AIFailureKind kind, {int? status}) =>
      replies.add((_) => Stream.value(AIFailure(kind, status: status)));

  @override
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel}) {
    requests.add(request);
    return replies.removeAt(0)(cancel);
  }

  @override
  Future<List<AIModelInfo>> listModels(
          AIProviderConfig config, String apiKey) async =>
      const [];
}

class _NoKeys implements SecureKeyStore {
  @override
  Future<String?> getKey(AIProviderId id) async => null;
  @override
  Future<void> setKey(AIProviderId id, String value) async {}
  @override
  Future<void> deleteKey(AIProviderId id) async {}
}

void main() {
  late AppDatabase db;
  late _FakeClient client;
  late AIRepositoryImpl repo;
  late int conversationId;

  setUp(() async {
    db = createTestDatabase();
    client = _FakeClient();
    repo = AIRepositoryImpl(db, _NoKeys(), {AIProviderId.ollama: client});
    conversationId =
        await repo.createConversation(providerId: AIProviderId.ollama);
  });
  tearDown(() => db.close());

  Future<List<AIMessage>> messages() =>
      repo.watchMessages(conversationId).first;

  test('a reply is pending while the request is in flight (B23)', () async {
    final events = StreamController<AIEvent>();
    client.replies.add((_) => events.stream);

    final sending =
        repo.sendMessage(conversationId: conversationId, prompt: 'hi');
    await pumpEventQueue();
    final during = await messages();
    expect(during.map((m) => m.role),
        [AIMessageRole.user, AIMessageRole.assistant]);
    expect(during.last.isPending, isTrue);

    events
      ..add(const AITextDelta('hel'))
      ..add(const AITextDelta('lo'))
      ..add(const AIDone());
    await events.close();
    await sending;
    final after = await messages();
    expect(after, hasLength(2), reason: 'the placeholder is filled in place');
    expect(after.last.content, 'hello');
    expect(after.last.isPending, isFalse);
    expect(after.last.isError, isFalse);
    expect(after.last.failure, isNull);
  });

  test('streamed text shows up in the pending reply as it arrives', () async {
    final events = StreamController<AIEvent>();
    client.replies.add((_) => events.stream);
    final sending =
        repo.sendMessage(conversationId: conversationId, prompt: 'hi');
    await pumpEventQueue();

    // Writes are throttled; wait out the interval between chunks.
    events.add(const AITextDelta('Hel'));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    events.add(const AITextDelta('lo'));
    await pumpEventQueue();
    final during = (await messages()).last;
    expect(during.isPending, isTrue);
    expect(during.content, 'Hello');

    events.add(const AIDone());
    await events.close();
    await sending;
    expect((await messages()).last.isPending, isFalse);
  });

  test('a failure is stored by kind and status, for the UI to word', () async {
    client.fail(AIFailureKind.serverError, status: 503);
    await repo.sendMessage(conversationId: conversationId, prompt: 'hi');
    final reply = (await messages()).last;
    expect(reply.isError, isTrue);
    expect(reply.content, isEmpty);
    expect(reply.failure!.kind, AIFailureKind.serverError);
    expect(reply.failure!.status, 503);
  });

  test('a reply interrupted by process death becomes an error on next start',
      () async {
    client.replies.add((_) => StreamController<AIEvent>().stream);
    unawaited(repo.sendMessage(conversationId: conversationId, prompt: 'hi'));
    await pumpEventQueue();

    // A new repository is what the next app launch creates.
    final relaunched =
        AIRepositoryImpl(db, _NoKeys(), {AIProviderId.ollama: _FakeClient()});
    final after = await relaunched.watchMessages(conversationId).first;
    expect(after.last.isPending, isFalse);
    expect(after.last.isError, isTrue);
    expect(after.last.failure!.kind, AIFailureKind.interrupted);
  });

  test('a client that throws leaves an error, not a pending reply', () async {
    client.replies.add((_) => Stream.error(StateError('boom')));
    await expectLater(
      repo.sendMessage(conversationId: conversationId, prompt: 'hi'),
      throwsStateError,
    );
    final after = await messages();
    expect(after.last.isPending, isFalse);
    expect(after.last.failure!.kind, AIFailureKind.unknown);
  });

  test('stopping before any text reads "stopped", keeping the prompt',
      () async {
    final cancel = AICancelToken()..cancel();
    client.replies.add((token) => Stream.value(AIDone(
        stopReason: token!.isCancelled
            ? AIStopReason.cancelled
            : AIStopReason.complete)));
    await repo.sendMessage(
        conversationId: conversationId, prompt: 'hi', cancel: cancel);
    final after = await messages();
    expect(after.first.content, 'hi');
    expect(after.last.failure!.kind, AIFailureKind.cancelled);
  });

  test('a vendor that needs a key, without one, fails without a request',
      () async {
    final openai = _FakeClient(AIProviderId.openai);
    final keyed =
        AIRepositoryImpl(db, _NoKeys(), {AIProviderId.openai: openai});
    final id = await keyed.createConversation(providerId: AIProviderId.openai);
    await keyed.sendMessage(conversationId: id, prompt: 'hi');
    final reply = (await keyed.watchMessages(id).first).last;
    expect(reply.failure!.kind, AIFailureKind.missingKey);
    expect(openai.requests, isEmpty);
  });

  test('error replies are never sent back to the vendor as history (B31)',
      () async {
    client
      ..fail(AIFailureKind.serverError, status: 500)
      ..reply('fine')
      ..reply('ok');

    await repo.sendMessage(conversationId: conversationId, prompt: 'first');
    await repo.sendMessage(conversationId: conversationId, prompt: 'second');
    await repo.sendMessage(conversationId: conversationId, prompt: 'third');

    expect(client.requests[1].history, isEmpty,
        reason: 'the failed exchange is not history');
    expect(
        client.requests[2].history.map((m) => m.content), ['second', 'fine']);
  });

  group('completeOnce', () {
    test('without an active provider fails with noActiveProvider', () async {
      final result = await repo.completeOnce(prompt: 'x');
      expect((result as AIError).failure.kind, AIFailureKind.noActiveProvider);
    });

    test('passes the system prompt and format, and collects the text',
        () async {
      await repo.setActiveProvider(AIProviderId.ollama);
      client.reply('{"a":1}');
      final result = await repo.completeOnce(
          prompt: 'x', system: 'Be exact', format: AIResponseFormat.json);
      expect((result as AIText).text, '{"a":1}');
      expect(client.requests.single.system, 'Be exact');
      expect(client.requests.single.format, AIResponseFormat.json);
      expect(client.requests.single.history, isEmpty);
    });
  });

  group('completeWithTools', () {
    const tool = AIToolSpec(
      name: 'create_task',
      description: 'Create a task.',
      parameters: {'type': 'object'},
    );

    test('native calls come back as they are', () async {
      await repo.setActiveProvider(AIProviderId.ollama);
      client.replies.add((_) => Stream.fromIterable(const [
            AIToolCall(
                id: 'c1', name: 'create_task', argumentsJson: '{"title":"A"}'),
            AIDone(stopReason: AIStopReason.toolUse),
          ]));
      final result = await repo.completeWithTools(
          prompt: 'remind me', tools: const [tool], system: 'Be exact');
      final reply = result as AIToolTurnReply;
      expect(reply.calls.single.name, 'create_task');
      expect(client.requests.single.tools.single.name, 'create_task');
      expect(client.requests.single.system, 'Be exact');
    });

    test('a model without tools is asked for a JSON plan instead', () async {
      await repo.setActiveProvider(AIProviderId.ollama);
      client
        ..fail(AIFailureKind.toolsUnsupported, status: 400)
        ..reply('{"reply":"Okay.","actions":'
            '[{"tool":"create_task","args":{"title":"A"}}]}');
      final result = await repo
          .completeWithTools(prompt: 'remind me', tools: const [tool]);
      final reply = result as AIToolTurnReply;
      expect(reply.text, 'Okay.');
      expect(reply.calls.single.argumentsJson, '{"title":"A"}');
      final retry = client.requests[1];
      expect(retry.tools, isEmpty, reason: 'the retry sends no tools');
      expect(retry.format, AIResponseFormat.json);
      expect(retry.system, contains('create_task'));
    });

    test('an unusable plan is an empty response, not a guess', () async {
      await repo.setActiveProvider(AIProviderId.ollama);
      client
        ..fail(AIFailureKind.toolsUnsupported, status: 400)
        ..reply('I would create a task for you.');
      final result = await repo
          .completeWithTools(prompt: 'remind me', tools: const [tool]);
      expect((result as AIToolTurnFailed).failure.kind,
          AIFailureKind.emptyResponse);
    });

    test('other failures are not retried', () async {
      await repo.setActiveProvider(AIProviderId.ollama);
      client.fail(AIFailureKind.rateLimited, status: 429);
      final result =
          await repo.completeWithTools(prompt: 'x', tools: const [tool]);
      expect(
          (result as AIToolTurnFailed).failure.kind, AIFailureKind.rateLimited);
      expect(client.requests, hasLength(1));
    });

    test('without an active provider', () async {
      final result =
          await repo.completeWithTools(prompt: 'x', tools: const [tool]);
      expect((result as AIToolTurnFailed).failure.kind,
          AIFailureKind.noActiveProvider);
    });
  });

  test('chat history sent to the vendor is windowed (K10)', () async {
    for (var i = 0; i < 25; i++) {
      client.reply('a$i');
      await repo.sendMessage(conversationId: conversationId, prompt: 'q$i');
    }
    client.reply('last');
    await repo.sendMessage(conversationId: conversationId, prompt: 'final');
    final sent = client.requests.last.history;
    expect(sent, hasLength(20), reason: 'ten exchanges, not all 25');
    expect(sent.last.content, 'a24', reason: 'the most recent ones');
  });
}
