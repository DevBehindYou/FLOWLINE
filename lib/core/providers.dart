import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/local/drift/app_database.dart';
import '../data/local/secure/secure_key_store.dart';
import '../data/remote/ai_clients/anthropic_client.dart';
import '../data/remote/ai_clients/gemini_client.dart';
import '../data/remote/ai_clients/ollama_client.dart';
import '../data/remote/ai_clients/openai_client.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../data/repositories/app_settings_repository_impl.dart';
import '../data/repositories/assistant_repository_impl.dart';
import '../data/repositories/focus_session_repository_impl.dart';
import '../data/repositories/list_repository_impl.dart';
import '../data/repositories/reminder_repository_impl.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/export/export_service.dart';
import '../domain/entities/ai_provider_config.dart';
import '../domain/entities/app_settings.dart';
import '../domain/repositories/ai_client.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../domain/repositories/assistant_repository.dart';
import '../domain/repositories/focus_session_repository.dart';
import '../domain/repositories/list_repository.dart';
import '../domain/repositories/reminder_repository.dart';
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
AssistantRepository assistantRepository(Ref ref) {
  return AssistantRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
ListRepository listRepository(Ref ref) {
  return ListRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
ReminderRepository reminderRepository(Ref ref) {
  return ReminderRepositoryImpl(ref.watch(appDatabaseProvider));
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
AppSettingsRepository appSettingsRepository(Ref ref) {
  return AppSettingsRepositoryImpl(ref.watch(appDatabaseProvider));
}

/// Current preferences. Defaults until the first read completes, so
/// nothing waits on (or flashes a spinner for) the settings table.
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) {
  return ref.watch(appSettingsRepositoryProvider).watch();
}

@Riverpod(keepAlive: true)
FocusSessionRepository focusSessionRepository(Ref ref) {
  return FocusSessionRepositoryImpl(ref.watch(appDatabaseProvider));
}

// Initialised at startup (to receive notification taps), but the
// permission prompt is separate: NotificationService.requestPermission runs
// on the first session start, not at launch.
@Riverpod(keepAlive: true)
Future<NotificationService> notificationService(Ref ref) async {
  final service = NotificationService();
  await service.init();
  return service;
}

/// One shared client for every AI vendor. Timeouts are generous for the
/// receive side because a non-streaming completion can legitimately take
/// a minute, but a dead network or an unreachable Ollama host now fails
/// in seconds instead of hanging the chat forever (K5).
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
  ));
  ref.onDispose(dio.close);
  return dio;
}

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
