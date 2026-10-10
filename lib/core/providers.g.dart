// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(assistantRepository)
final assistantRepositoryProvider = AssistantRepositoryProvider._();

final class AssistantRepositoryProvider extends $FunctionalProvider<
    AssistantRepository,
    AssistantRepository,
    AssistantRepository> with $Provider<AssistantRepository> {
  AssistantRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assistantRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assistantRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssistantRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssistantRepository create(Ref ref) {
    return assistantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantRepository>(value),
    );
  }
}

String _$assistantRepositoryHash() =>
    r'd8c397ff510087879055f60c61087f234f49f65d';

@ProviderFor(peopleRepository)
final peopleRepositoryProvider = PeopleRepositoryProvider._();

final class PeopleRepositoryProvider extends $FunctionalProvider<
    PeopleRepository,
    PeopleRepository,
    PeopleRepository> with $Provider<PeopleRepository> {
  PeopleRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'peopleRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$peopleRepositoryHash();

  @$internal
  @override
  $ProviderElement<PeopleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeopleRepository create(Ref ref) {
    return peopleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeopleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeopleRepository>(value),
    );
  }
}

String _$peopleRepositoryHash() => r'824c1aa4bdad2e1364635711f44f7fd7bb3ad569';

@ProviderFor(listRepository)
final listRepositoryProvider = ListRepositoryProvider._();

final class ListRepositoryProvider
    extends $FunctionalProvider<ListRepository, ListRepository, ListRepository>
    with $Provider<ListRepository> {
  ListRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'listRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$listRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListRepository create(Ref ref) {
    return listRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRepository>(value),
    );
  }
}

String _$listRepositoryHash() => r'21c0762f9175d1c73c1492e74562c1bf6ca390d8';

@ProviderFor(reminderRepository)
final reminderRepositoryProvider = ReminderRepositoryProvider._();

final class ReminderRepositoryProvider extends $FunctionalProvider<
    ReminderRepository,
    ReminderRepository,
    ReminderRepository> with $Provider<ReminderRepository> {
  ReminderRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reminderRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reminderRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReminderRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderRepository create(Ref ref) {
    return reminderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderRepository>(value),
    );
  }
}

String _$reminderRepositoryHash() =>
    r'2fa99277f76e29bb8c1ed9d24bfe8c4ea164280c';

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  TaskRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'd1b32b0edd73be3c572e14024c9203bf1a7c06d8';

@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = ScheduleRepositoryProvider._();

final class ScheduleRepositoryProvider extends $FunctionalProvider<
    ScheduleRepository,
    ScheduleRepository,
    ScheduleRepository> with $Provider<ScheduleRepository> {
  ScheduleRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScheduleRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleRepository create(Ref ref) {
    return scheduleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleRepository>(value),
    );
  }
}

String _$scheduleRepositoryHash() =>
    r'0300f69ab3d681e5cb6f513e12f84c33c92ee242';

@ProviderFor(appSettingsRepository)
final appSettingsRepositoryProvider = AppSettingsRepositoryProvider._();

final class AppSettingsRepositoryProvider extends $FunctionalProvider<
    AppSettingsRepository,
    AppSettingsRepository,
    AppSettingsRepository> with $Provider<AppSettingsRepository> {
  AppSettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppSettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettingsRepository create(Ref ref) {
    return appSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsRepository>(value),
    );
  }
}

String _$appSettingsRepositoryHash() =>
    r'48653f7ebc34f169089ed9578fa46718ae9237ab';

/// Current preferences. Defaults until the first read completes, so
/// nothing waits on (or flashes a spinner for) the settings table.

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// Current preferences. Defaults until the first read completes, so
/// nothing waits on (or flashes a spinner for) the settings table.

final class AppSettingsProvider extends $FunctionalProvider<
        AsyncValue<AppSettings>, AppSettings, Stream<AppSettings>>
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// Current preferences. Defaults until the first read completes, so
  /// nothing waits on (or flashes a spinner for) the settings table.
  AppSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'4d08b216e942c72cf0e47926c369baf7d0d42adc';

@ProviderFor(focusSessionRepository)
final focusSessionRepositoryProvider = FocusSessionRepositoryProvider._();

final class FocusSessionRepositoryProvider extends $FunctionalProvider<
    FocusSessionRepository,
    FocusSessionRepository,
    FocusSessionRepository> with $Provider<FocusSessionRepository> {
  FocusSessionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'focusSessionRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$focusSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<FocusSessionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FocusSessionRepository create(Ref ref) {
    return focusSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSessionRepository>(value),
    );
  }
}

String _$focusSessionRepositoryHash() =>
    r'e736431f78d5e510607da56a25185557d9c4be11';

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider extends $FunctionalProvider<
        AsyncValue<NotificationService>,
        NotificationService,
        FutureOr<NotificationService>>
    with
        $FutureModifier<NotificationService>,
        $FutureProvider<NotificationService> {
  NotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $FutureProviderElement<NotificationService> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationService> create(Ref ref) {
    return notificationService(ref);
  }
}

String _$notificationServiceHash() =>
    r'00ccaba7c6bbb8d602b8b6dec32b3000bfb1712d';

/// One shared client for every AI vendor. Timeouts are generous for the
/// receive side because a non-streaming completion can legitimately take
/// a minute, but a dead network or an unreachable Ollama host now fails
/// in seconds instead of hanging the chat forever (K5).

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// One shared client for every AI vendor. Timeouts are generous for the
/// receive side because a non-streaming completion can legitimately take
/// a minute, but a dead network or an unreachable Ollama host now fails
/// in seconds instead of hanging the chat forever (K5).

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// One shared client for every AI vendor. Timeouts are generous for the
  /// receive side because a non-streaming completion can legitimately take
  /// a minute, but a dead network or an unreachable Ollama host now fails
  /// in seconds instead of hanging the chat forever (K5).
  DioProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dioProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'a776c0eac1fbd6cd8a9772c1528b12065ce3775e';

@ProviderFor(secureKeyStore)
final secureKeyStoreProvider = SecureKeyStoreProvider._();

final class SecureKeyStoreProvider
    extends $FunctionalProvider<SecureKeyStore, SecureKeyStore, SecureKeyStore>
    with $Provider<SecureKeyStore> {
  SecureKeyStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'secureKeyStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$secureKeyStoreHash();

  @$internal
  @override
  $ProviderElement<SecureKeyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureKeyStore create(Ref ref) {
    return secureKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureKeyStore>(value),
    );
  }
}

String _$secureKeyStoreHash() => r'2a1c5d57a9486fcbdaefb79d198e428832637da0';

@ProviderFor(aiRepository)
final aiRepositoryProvider = AiRepositoryProvider._();

final class AiRepositoryProvider
    extends $FunctionalProvider<AIRepository, AIRepository, AIRepository>
    with $Provider<AIRepository> {
  AiRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'aiRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aiRepositoryHash();

  @$internal
  @override
  $ProviderElement<AIRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AIRepository create(Ref ref) {
    return aiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIRepository>(value),
    );
  }
}

String _$aiRepositoryHash() => r'3400d8a71061e3417a5e907e341033113f41c212';

@ProviderFor(exportService)
final exportServiceProvider = ExportServiceProvider._();

final class ExportServiceProvider
    extends $FunctionalProvider<ExportService, ExportService, ExportService>
    with $Provider<ExportService> {
  ExportServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exportServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exportServiceHash();

  @$internal
  @override
  $ProviderElement<ExportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportService create(Ref ref) {
    return exportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportService>(value),
    );
  }
}

String _$exportServiceHash() => r'd8db18ff188965d70ff027315853adcf090b054d';
