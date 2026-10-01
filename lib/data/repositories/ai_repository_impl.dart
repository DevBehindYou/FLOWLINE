import 'package:drift/drift.dart';

import '../../domain/ai/ai_contract.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/entities/ai_provider_config.dart';
import '../../domain/repositories/ai_client.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/services/chat_history.dart';
import '../local/drift/app_database.dart';
import '../local/secure/secure_key_store.dart';

class _DefaultProvider {
  const _DefaultProvider(this.id, this.displayName, this.model, this.baseUrl);
  final AIProviderId id;
  final String displayName;
  final String model;
  final String? baseUrl;
}

const _defaultProviders = [
  _DefaultProvider(
      AIProviderId.anthropic, 'Anthropic', 'claude-3-5-sonnet-20241022', null),
  _DefaultProvider(AIProviderId.openai, 'OpenAI', 'gpt-4o-mini', null),
  _DefaultProvider(
      AIProviderId.gemini, 'Google Gemini', 'gemini-1.5-flash', null),
  _DefaultProvider(AIProviderId.ollama, 'Ollama (Local)', 'llama3.2',
      'http://localhost:11434'),
];

// Drift stores date-times at second precision, so a fast reply (local
// Ollama, an immediate error) shares its prompt's `sentAt`. The row id
// breaks the tie, keeping both the chat and the history sent to the vendor
// in the order the messages were written.
List<OrderClauseGenerator<$AiMessagesTable>> get _messageOrder => [
      (m) => OrderingTerm.asc(m.sentAt),
      (m) => OrderingTerm.asc(m.id),
    ];

class AIRepositoryImpl implements AIRepository {
  AIRepositoryImpl(this._db, this._secureStore, this._clients) {
    _seedFuture = _initialize();
  }

  final AppDatabase _db;
  final SecureKeyStore _secureStore;
  final Map<AIProviderId, AIClient> _clients;
  late final Future<void> _seedFuture;

  /// Runs once per process, before any read or write.
  Future<void> _initialize() async {
    await _ensureSeeded();
    await _failInterruptedReplies();
  }

  /// A reply still pending when the repository starts was interrupted:
  /// the process died (or was killed in the background) mid-request, so it
  /// will never arrive. Turn it into a visible error instead of leaving the
  /// prompt unanswered forever (B23).
  Future<void> _failInterruptedReplies() {
    return (_db.update(_db.aiMessages)..where((m) => m.isPending.equals(true)))
        .write(const AiMessagesCompanion(
      isPending: Value(false),
      isError: Value(true),
      errorKind: Value(AIFailureKind.interrupted),
    ));
  }

  Future<void> _ensureSeeded() async {
    final existing = await _db.select(_db.aiProviderConfigs).get();
    if (existing.isNotEmpty) return;
    for (final defaultProvider in _defaultProviders) {
      await _db.into(_db.aiProviderConfigs).insert(
            AiProviderConfigsCompanion.insert(
              // A lone INTEGER PRIMARY KEY is SQLite's rowid alias, so
              // drift treats it as optional in insert companions.
              providerId: Value(defaultProvider.id),
              displayName: defaultProvider.displayName,
              defaultModel: defaultProvider.model,
              baseUrl: Value(defaultProvider.baseUrl),
            ),
          );
    }
  }

  @override
  Stream<List<AIProviderConfig>> watchProviders() async* {
    await _seedFuture;
    yield* _db.select(_db.aiProviderConfigs).watch().map(
          (rows) => rows.map(_mapProvider).toList(),
        );
  }

  @override
  Stream<AIProviderConfig?> watchActiveProvider() async* {
    await _seedFuture;
    final query = _db.select(_db.aiProviderConfigs)
      ..where((p) => p.isActive.equals(true));
    yield* query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapProvider(row));
  }

  @override
  Future<void> saveProviderKey({
    required AIProviderId id,
    required String apiKey,
    required String model,
    String? baseUrl,
  }) async {
    await _seedFuture;
    if (apiKey.isNotEmpty) {
      await _secureStore.setKey(id, apiKey);
    }
    await (_db.update(_db.aiProviderConfigs)
          ..where((p) => p.providerId.equalsValue(id)))
        .write(
      AiProviderConfigsCompanion(
        defaultModel: Value(model),
        baseUrl: Value(baseUrl),
      ),
    );
  }

  @override
  Future<void> setActiveProvider(AIProviderId id) async {
    await _seedFuture;
    await _db.transaction(() async {
      await _db
          .update(_db.aiProviderConfigs)
          .write(const AiProviderConfigsCompanion(isActive: Value(false)));
      await (_db.update(_db.aiProviderConfigs)
            ..where((p) => p.providerId.equalsValue(id)))
          .write(const AiProviderConfigsCompanion(isActive: Value(true)));
    });
  }

  @override
  Future<void> removeProviderKey(AIProviderId id) async {
    await _seedFuture;
    await _secureStore.deleteKey(id);
    await (_db.update(_db.aiProviderConfigs)
          ..where((p) => p.providerId.equalsValue(id)))
        .write(const AiProviderConfigsCompanion(isActive: Value(false)));
  }

  @override
  Future<bool> hasKey(AIProviderId id) async {
    if (id == AIProviderId.ollama) return true;
    final key = await _secureStore.getKey(id);
    return key != null && key.isNotEmpty;
  }

  @override
  Stream<List<AIConversation>> watchConversations() async* {
    await _seedFuture;
    final query = _db.select(_db.aiConversations)
      ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]);
    yield* query.watch().map((rows) => rows.map(_mapConversation).toList());
  }

  @override
  Stream<List<AIMessage>> watchMessages(int conversationId) async* {
    await _seedFuture;
    final query = _db.select(_db.aiMessages)
      ..where((m) => m.conversationId.equals(conversationId))
      ..orderBy(_messageOrder);
    yield* query.watch().map((rows) => rows.map(_mapMessage).toList());
  }

  @override
  Future<int> createConversation(
      {required AIProviderId providerId, String? title}) {
    return _db.into(_db.aiConversations).insert(
          AiConversationsCompanion.insert(
            providerId: providerId,
            title: title ?? 'New conversation',
          ),
        );
  }

  @override
  Future<void> deleteConversation(int id) {
    return (_db.delete(_db.aiConversations)..where((c) => c.id.equals(id)))
        .go();
  }

  @override
  Future<void> sendMessage({
    required int conversationId,
    required String prompt,
    AICancelToken? cancel,
  }) async {
    await _seedFuture;
    // History BEFORE inserting the new user message, so it isn't
    // duplicated when the client builds its request; only completed
    // exchanges, never error bubbles (B31).
    final historyRows = await (_db.select(_db.aiMessages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy(_messageOrder))
        .get();
    final history = buildChatHistory(historyRows.map(_mapMessage).toList());

    // The prompt and a pending placeholder for its reply are written
    // together, before the network call: if the process dies mid-request,
    // the next launch turns the placeholder into an error (B23).
    final replyId = await _db.transaction(() async {
      await _db.into(_db.aiMessages).insert(AiMessagesCompanion.insert(
            conversationId: conversationId,
            role: AIMessageRole.user,
            content: prompt,
          ));
      return _db.into(_db.aiMessages).insert(AiMessagesCompanion.insert(
            conversationId: conversationId,
            role: AIMessageRole.assistant,
            content: '',
            isPending: const Value(true),
          ));
    });

    final reply = StringBuffer();
    try {
      final conversation = await (_db.select(_db.aiConversations)
            ..where((c) => c.id.equals(conversationId)))
          .getSingle();
      final events = await _events(
        conversation.providerId,
        prompt: prompt,
        history: history,
        cancel: cancel,
      );
      await for (final event in events) {
        switch (event) {
          case AITextDelta(:final text):
            reply.write(text);
          case AIDone(:final stopReason):
            await _finishReply(replyId, reply.toString(), stopReason);
            return;
          case AIFailure():
            await _failReply(replyId, event);
            return;
        }
      }
      // A stream that ended without Done or Failure broke the contract.
      await _failReply(replyId, const AIFailure(AIFailureKind.unknown));
    } catch (_) {
      // The safety net that keeps the placeholder from staying pending.
      await _failReply(replyId, const AIFailure(AIFailureKind.unknown));
      rethrow;
    }
  }

  /// The vendor's event stream for [providerId], or a single failure when
  /// the request can't be made (no key saved).
  Future<Stream<AIEvent>> _events(
    AIProviderId providerId, {
    required String prompt,
    List<AIMessage> history = const [],
    String? system,
    AIResponseFormat format = AIResponseFormat.text,
    AICancelToken? cancel,
  }) async {
    final configRow = await (_db.select(_db.aiProviderConfigs)
          ..where((p) => p.providerId.equalsValue(providerId)))
        .getSingle();
    final config = _mapProvider(configRow);
    final apiKey = await _secureStore.getKey(providerId) ?? '';
    if (config.requiresApiKey && apiKey.isEmpty) {
      return Stream.value(const AIFailure(AIFailureKind.missingKey));
    }
    return _clients[providerId]!.send(
      AIRequest(
        config: config,
        apiKey: apiKey,
        prompt: prompt,
        history: history,
        system: system,
        format: format,
      ),
      cancel: cancel,
    );
  }

  Future<void> _finishReply(int replyId, String text, AIStopReason stop) {
    // Stopped before any text arrived: say so rather than leave a blank.
    if (text.isEmpty) {
      return _failReply(
          replyId,
          AIFailure(stop == AIStopReason.cancelled
              ? AIFailureKind.cancelled
              : AIFailureKind.emptyResponse));
    }
    return (_db.update(_db.aiMessages)..where((m) => m.id.equals(replyId)))
        .write(AiMessagesCompanion(
      content: Value(text),
      isError: const Value(false),
      isPending: const Value(false),
    ));
  }

  Future<void> _failReply(int replyId, AIFailure failure) {
    return (_db.update(_db.aiMessages)..where((m) => m.id.equals(replyId)))
        .write(AiMessagesCompanion(
      content: const Value(''),
      isError: const Value(true),
      isPending: const Value(false),
      errorKind: Value(failure.kind),
      errorStatus: Value(failure.status),
    ));
  }

  @override
  Future<AICompletion> completeOnce({
    required String prompt,
    String? system,
    AIResponseFormat format = AIResponseFormat.text,
  }) async {
    await _seedFuture;
    final activeRow = await (_db.select(_db.aiProviderConfigs)
          ..where((p) => p.isActive.equals(true)))
        .getSingleOrNull();
    if (activeRow == null) {
      return const AIError(AIFailure(AIFailureKind.noActiveProvider));
    }
    return collect(await _events(activeRow.providerId,
        prompt: prompt, system: system, format: format));
  }

  AIProviderConfig _mapProvider(AiProviderConfigRow row) {
    return AIProviderConfig(
      id: row.providerId,
      displayName: row.displayName,
      defaultModel: row.defaultModel,
      baseUrl: row.baseUrl,
      isActive: row.isActive,
    );
  }

  AIConversation _mapConversation(AiConversationRow row) {
    return AIConversation(
      id: row.id,
      providerId: row.providerId,
      title: row.title,
      createdAt: row.createdAt,
    );
  }

  AIMessage _mapMessage(AiMessageRow row) {
    return AIMessage(
      id: row.id,
      conversationId: row.conversationId,
      role: row.role,
      content: row.content,
      isError: row.isError,
      isPending: row.isPending,
      sentAt: row.sentAt,
      failure: row.errorKind == null
          ? null
          : AIFailure(row.errorKind!, status: row.errorStatus),
    );
  }
}
