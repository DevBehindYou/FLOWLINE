// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$taskRepositoryHash() => r'd1b32b0edd73be3c572e14024c9203bf1a7c06d8';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = Provider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = ProviderRef<TaskRepository>;
String _$scheduleRepositoryHash() =>
    r'0300f69ab3d681e5cb6f513e12f84c33c92ee242';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = Provider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleRepositoryRef = ProviderRef<ScheduleRepository>;
String _$focusSessionRepositoryHash() =>
    r'e736431f78d5e510607da56a25185557d9c4be11';

/// See also [focusSessionRepository].
@ProviderFor(focusSessionRepository)
final focusSessionRepositoryProvider =
    Provider<FocusSessionRepository>.internal(
  focusSessionRepository,
  name: r'focusSessionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$focusSessionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FocusSessionRepositoryRef = ProviderRef<FocusSessionRepository>;
String _$notificationServiceHash() =>
    r'00ccaba7c6bbb8d602b8b6dec32b3000bfb1712d';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    FutureProvider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = FutureProviderRef<NotificationService>;
String _$dioHash() => r'a776c0eac1fbd6cd8a9772c1528b12065ce3775e';

/// One shared client for every AI vendor. Timeouts are generous for the
/// receive side because a non-streaming completion can legitimately take
/// a minute, but a dead network or an unreachable Ollama host now fails
/// in seconds instead of hanging the chat forever (K5).
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$secureKeyStoreHash() => r'2a1c5d57a9486fcbdaefb79d198e428832637da0';

/// See also [secureKeyStore].
@ProviderFor(secureKeyStore)
final secureKeyStoreProvider = Provider<SecureKeyStore>.internal(
  secureKeyStore,
  name: r'secureKeyStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureKeyStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureKeyStoreRef = ProviderRef<SecureKeyStore>;
String _$aiRepositoryHash() => r'3400d8a71061e3417a5e907e341033113f41c212';

/// See also [aiRepository].
@ProviderFor(aiRepository)
final aiRepositoryProvider = Provider<AIRepository>.internal(
  aiRepository,
  name: r'aiRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiRepositoryRef = ProviderRef<AIRepository>;
String _$exportServiceHash() => r'd8db18ff188965d70ff027315853adcf090b054d';

/// See also [exportService].
@ProviderFor(exportService)
final exportServiceProvider = Provider<ExportService>.internal(
  exportService,
  name: r'exportServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExportServiceRef = ProviderRef<ExportService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
