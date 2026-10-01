import 'dart:async';

import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/local/secure/secure_key_store.dart';
import 'package:flowline/data/repositories/ai_repository_impl.dart';
import 'package:flowline/domain/entities/ai_message.dart';
import 'package:flowline/domain/entities/ai_provider_config.dart';
import 'package:flowline/domain/entities/ai_response.dart';
import 'package:flowline/domain/repositories/ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// Records what it was asked and answers with whatever the test queues.
class _FakeOllama implements AIClient {
  final requests = <List<AIMessage>>[];
  final replies = <Future<AIResponse> Function()>[];

  @override
  AIProviderId get id => AIProviderId.ollama;

  @override
  Future<AIResponse> sendMessage({
    required AIProviderConfig config,
    required String apiKey,
    required String prompt,
    required List<AIMessage> history,
  }) {
    requests.add(history);
    return replies.removeAt(0)();
  }
}

void main() {
  late AppDatabase db;
  late _FakeOllama client;
  late AIRepositoryImpl repo;
  late int conversationId;

  setUp(() async {
    db = createTestDatabase();
    client = _FakeOllama();
    repo = AIRepositoryImpl(
        db, const SecureKeyStore(), {AIProviderId.ollama: client});
    conversationId =
        await repo.createConversation(providerId: AIProviderId.ollama);
  });
  tearDown(() => db.close());

  Future<List<AIMessage>> messages() =>
      repo.watchMessages(conversationId).first;

  test('a reply is pending while the request is in flight (B23)', () async {
    final reply = Completer<AIResponse>();
    client.replies.add(() => reply.future);

    final sending =
        repo.sendMessage(conversationId: conversationId, prompt: 'hi');
    await pumpEventQueue();
    final during = await messages();
    expect(during.map((m) => m.role),
        [AIMessageRole.user, AIMessageRole.assistant]);
    expect(during.last.isPending, isTrue);

    reply.complete(const AIResponse('hello'));
    await sending;
    final after = await messages();
    expect(after, hasLength(2), reason: 'the placeholder is filled in place');
    expect(after.last.content, 'hello');
    expect(after.last.isPending, isFalse);
    expect(after.last.isError, isFalse);
  });

  test('a reply interrupted by process death becomes an error on next start',
      () async {
    final never = Completer<AIResponse>();
    client.replies.add(() => never.future);
    unawaited(repo.sendMessage(conversationId: conversationId, prompt: 'hi'));
    await pumpEventQueue();

    // A new repository is what the next app launch creates.
    final relaunched = AIRepositoryImpl(
        db, const SecureKeyStore(), {AIProviderId.ollama: _FakeOllama()});
    final after = await relaunched.watchMessages(conversationId).first;
    expect(after.last.isPending, isFalse);
    expect(after.last.isError, isTrue);
    expect(after.last.content, interruptedReplyMessage);
  });

  test('a client that throws leaves an error, not a pending reply', () async {
    client.replies.add(() async => throw StateError('boom'));
    await expectLater(
      repo.sendMessage(conversationId: conversationId, prompt: 'hi'),
      throwsStateError,
    );
    final after = await messages();
    expect(after.last.isPending, isFalse);
    expect(after.last.isError, isTrue);
  });

  test('error replies are never sent back to the vendor as history (B31)',
      () async {
    client.replies
      ..add(() async => const AIResponse.error('Ollama returned an error.'))
      ..add(() async => const AIResponse('fine'))
      ..add(() async => const AIResponse('ok'));

    await repo.sendMessage(conversationId: conversationId, prompt: 'first');
    await repo.sendMessage(conversationId: conversationId, prompt: 'second');
    await repo.sendMessage(conversationId: conversationId, prompt: 'third');

    expect(client.requests[1], isEmpty,
        reason: 'the failed exchange is not history');
    expect(client.requests[2].map((m) => m.content), ['second', 'fine']);
  });
}
