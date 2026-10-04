import 'dart:async';

import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/core/riverpod_config.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/ai_repository_impl.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/repositories/ai_client.dart';
import 'package:atomic_assist/features/ai_assistant/viewmodel/assistant_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// Streams "Partial" and then waits until it's cancelled.
class _SlowClient implements AIClient {
  @override
  AIProviderId get id => AIProviderId.ollama;

  @override
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel}) async* {
    yield const AITextDelta('Partial');
    await cancel!.whenCancelled;
    yield const AIDone(stopReason: AIStopReason.cancelled);
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
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('Stop ends the reply and keeps what arrived', () async {
    final repo =
        AIRepositoryImpl(db, _NoKeys(), {AIProviderId.ollama: _SlowClient()});
    final container = ProviderContainer(retry: noAutomaticRetry, overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      aiRepositoryProvider.overrideWith((ref) => repo),
    ]);
    addTearDown(container.dispose);
    final vm = container.read(assistantViewModelProvider.notifier);

    final sending = vm.send(
        providerId: AIProviderId.ollama,
        existingConversationId: null,
        prompt: 'hi');
    await pumpEventQueue();
    expect(container.read(assistantViewModelProvider), isTrue);

    vm.stop();
    await sending;
    expect(container.read(assistantViewModelProvider), isFalse);

    final conversation = (await repo.watchConversations().first).single;
    final reply = (await repo.watchMessages(conversation.id).first).last;
    expect(reply.content, 'Partial');
    expect(reply.isError, isFalse);
    expect(reply.isPending, isFalse);
  });
}
