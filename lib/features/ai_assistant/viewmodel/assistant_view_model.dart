import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/ai_conversation.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';

part 'assistant_view_model.g.dart';

@riverpod
Stream<List<AIProviderConfig>> aiProviders(Ref ref) {
  return ref.watch(aiRepositoryProvider).watchProviders();
}

@riverpod
Stream<AIProviderConfig?> activeAiProvider(Ref ref) {
  return ref.watch(aiRepositoryProvider).watchActiveProvider();
}

@riverpod
Future<bool> providerHasKey(Ref ref, AIProviderId id) {
  return ref.watch(aiRepositoryProvider).hasKey(id);
}

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.
@riverpod
Stream<AIConversation?> latestConversationForProvider(
  Ref ref,
  AIProviderId providerId,
) {
  return ref
      .watch(aiRepositoryProvider)
      .watchConversations()
      .map((conversations) {
    final matching =
        conversations.where((c) => c.providerId == providerId).toList();
    return matching.isEmpty ? null : matching.first;
  });
}

@riverpod
Stream<List<AIMessage>> conversationMessages(Ref ref, int conversationId) {
  return ref.watch(aiRepositoryProvider).watchMessages(conversationId);
}

@riverpod
class AssistantViewModel extends _$AssistantViewModel {
  @override
  bool build() => false; // true while a send is in flight

  Future<void> send({
    required AIProviderId providerId,
    required int? existingConversationId,
    required String prompt,
  }) async {
    state = true;
    try {
      final conversationId = existingConversationId ??
          await ref
              .read(aiRepositoryProvider)
              .createConversation(providerId: providerId);
      await ref
          .read(aiRepositoryProvider)
          .sendMessage(conversationId: conversationId, prompt: prompt);
    } finally {
      state = false;
    }
  }
}
