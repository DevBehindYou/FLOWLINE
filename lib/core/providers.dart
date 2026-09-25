import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/local/drift/app_database.dart';
import '../data/local/secure/secure_key_store.dart';
import '../data/remote/ai_clients/anthropic_client.dart';
import '../data/remote/ai_clients/gemini_client.dart';
import '../data/remote/ai_clients/ollama_client.dart';
import '../data/remote/ai_clients/openai_client.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../data/repositories/focus_session_repository_impl.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/export/export_service.dart';
import '../domain/entities/ai_provider_config.dart';
import '../domain/repositories/ai_client.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/focus_session_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/task_repository.dart';
import 'notifications/notification_service.dart';

part 'providers.g.dart';

// App-wide singletons live here rather than in a separate DI folder —
// with a handful of repositories/services total, a dedicated DI layer
// would be an extra layer of indirection with nothing to justify it yet.

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(Ref ref) {
  return ScheduleRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
FocusSessionRepository focusSessionRepository(Ref ref) {
  return FocusSessionRepositoryImpl(ref.watch(appDatabaseProvider));
}

// Async and lazy on purpose: the notification permission prompt should
// appear the first time the user actually starts a focus session, not
// at app launch before they've done anything.
@Riverpod(keepAlive: true)
Future<NotificationService> notificationService(Ref ref) async {
  final service = NotificationService();
  await service.init();
  return service;
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio();

@Riverpod(keepAlive: true)
SecureKeyStore secureKeyStore(Ref ref) => const SecureKeyStore();

@Riverpod(keepAlive: true)
AIRepository aiRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final clients = <AIProviderId, AIClient>{
    AIProviderId.anthropic: AnthropicClient(dio),
    AIProviderId.openai: OpenAIClient(dio),
    AIProviderId.gemini: GeminiClient(dio),
    AIProviderId.ollama: OllamaClient(dio),
  };
  return AIRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(secureKeyStoreProvider),
    clients,
  );
}

@Riverpod(keepAlive: true)
ExportService exportService(Ref ref) => const ExportService();
