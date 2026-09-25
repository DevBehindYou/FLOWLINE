import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/local/secure/secure_key_store.dart';
import 'package:flowline/data/repositories/ai_repository_impl.dart';
import 'package:flowline/domain/entities/ai_message.dart';
import 'package:flowline/domain/entities/ai_provider_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

// Only exercises paths that never touch SecureKeyStore, so no
// flutter_secure_storage platform-channel mock is needed.
void main() {
  late AppDatabase db;
  late AIRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = AIRepositoryImpl(db, const SecureKeyStore(), const {});
  });
  tearDown(() => db.close());

  test('seeds all four providers exactly once, none active', () async {
    final providers = await repo.watchProviders().first;
    expect(providers.map((p) => p.id), unorderedEquals(AIProviderId.values));
    expect(providers.where((p) => p.isActive), isEmpty);

    // A second repository over the same DB must not seed duplicates.
    final again = AIRepositoryImpl(db, const SecureKeyStore(), const {});
    expect(await again.watchProviders().first, hasLength(AIProviderId.values.length));
  });

  test('setActiveProvider leaves exactly one provider active', () async {
    await repo.setActiveProvider(AIProviderId.openai);
    await repo.setActiveProvider(AIProviderId.gemini);

    final providers = await repo.watchProviders().first;
    final active = providers.where((p) => p.isActive).toList();
    expect(active, hasLength(1));
    expect(active.single.id, AIProviderId.gemini);
    expect((await repo.watchActiveProvider().first)?.id, AIProviderId.gemini);
  });

  test('createConversation defaults the title and keeps the provider', () async {
    final id = await repo.createConversation(providerId: AIProviderId.ollama);

    final conversations = await repo.watchConversations().first;
    final created = conversations.singleWhere((c) => c.id == id);
    expect(created.title, 'New conversation');
    expect(created.providerId, AIProviderId.ollama);
  });

  test('deleting a conversation cascades to its messages', () async {
    final id = await repo.createConversation(providerId: AIProviderId.ollama);
    await db.into(db.aiMessages).insert(
          AiMessagesCompanion.insert(
            conversationId: id,
            role: AIMessageRole.user,
            content: 'hello',
          ),
        );

    await repo.deleteConversation(id);

    expect(await db.select(db.aiMessages).get(), isEmpty);
  });
}
