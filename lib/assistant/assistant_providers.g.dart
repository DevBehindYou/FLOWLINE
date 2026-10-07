// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toolRegistry)
final toolRegistryProvider = ToolRegistryProvider._();

final class ToolRegistryProvider
    extends $FunctionalProvider<ToolRegistry, ToolRegistry, ToolRegistry>
    with $Provider<ToolRegistry> {
  ToolRegistryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toolRegistryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toolRegistryHash();

  @$internal
  @override
  $ProviderElement<ToolRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToolRegistry create(Ref ref) {
    return toolRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolRegistry>(value),
    );
  }
}

String _$toolRegistryHash() => r'9ec5742bbb4e786e594faefbef7e1f64924b375c';

/// A fresh env per call: "now" is read when it's made.

@ProviderFor(toolEnvFactory)
final toolEnvFactoryProvider = ToolEnvFactoryProvider._();

/// A fresh env per call: "now" is read when it's made.

final class ToolEnvFactoryProvider extends $FunctionalProvider<
    ToolEnv Function(),
    ToolEnv Function(),
    ToolEnv Function()> with $Provider<ToolEnv Function()> {
  /// A fresh env per call: "now" is read when it's made.
  ToolEnvFactoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toolEnvFactoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toolEnvFactoryHash();

  @$internal
  @override
  $ProviderElement<ToolEnv Function()> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToolEnv Function() create(Ref ref) {
    return toolEnvFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolEnv Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolEnv Function()>(value),
    );
  }
}

String _$toolEnvFactoryHash() => r'7778e4200a7043958e772dd3d39a55178e1d5c60';

@ProviderFor(afterCommitHandler)
final afterCommitHandlerProvider = AfterCommitHandlerProvider._();

final class AfterCommitHandlerProvider extends $FunctionalProvider<
    AfterCommitHandler,
    AfterCommitHandler,
    AfterCommitHandler> with $Provider<AfterCommitHandler> {
  AfterCommitHandlerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'afterCommitHandlerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$afterCommitHandlerHash();

  @$internal
  @override
  $ProviderElement<AfterCommitHandler> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AfterCommitHandler create(Ref ref) {
    return afterCommitHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AfterCommitHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AfterCommitHandler>(value),
    );
  }
}

String _$afterCommitHandlerHash() =>
    r'422c0fdb2642c19a292d4a9b76d69954b99b64d9';

@ProviderFor(toolExecutor)
final toolExecutorProvider = ToolExecutorProvider._();

final class ToolExecutorProvider
    extends $FunctionalProvider<ToolExecutor, ToolExecutor, ToolExecutor>
    with $Provider<ToolExecutor> {
  ToolExecutorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toolExecutorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toolExecutorHash();

  @$internal
  @override
  $ProviderElement<ToolExecutor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToolExecutor create(Ref ref) {
    return toolExecutor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolExecutor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolExecutor>(value),
    );
  }
}

String _$toolExecutorHash() => r'130569405617ff70f26232c95a98c69df3450ed8';

@ProviderFor(undoService)
final undoServiceProvider = UndoServiceProvider._();

final class UndoServiceProvider
    extends $FunctionalProvider<UndoService, UndoService, UndoService>
    with $Provider<UndoService> {
  UndoServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'undoServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$undoServiceHash();

  @$internal
  @override
  $ProviderElement<UndoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UndoService create(Ref ref) {
    return undoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UndoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UndoService>(value),
    );
  }
}

String _$undoServiceHash() => r'09b410c8fa386d8f9bf61f69a577505ff36094a0';

@ProviderFor(assistantOrchestrator)
final assistantOrchestratorProvider = AssistantOrchestratorProvider._();

final class AssistantOrchestratorProvider extends $FunctionalProvider<
    AssistantOrchestrator,
    AssistantOrchestrator,
    AssistantOrchestrator> with $Provider<AssistantOrchestrator> {
  AssistantOrchestratorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assistantOrchestratorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assistantOrchestratorHash();

  @$internal
  @override
  $ProviderElement<AssistantOrchestrator> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssistantOrchestrator create(Ref ref) {
    return assistantOrchestrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantOrchestrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantOrchestrator>(value),
    );
  }
}

String _$assistantOrchestratorHash() =>
    r'2dd2e3063341aceb9719b71110146183303e4579';

@ProviderFor(proposalService)
final proposalServiceProvider = ProposalServiceProvider._();

final class ProposalServiceProvider extends $FunctionalProvider<ProposalService,
    ProposalService, ProposalService> with $Provider<ProposalService> {
  ProposalServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'proposalServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$proposalServiceHash();

  @$internal
  @override
  $ProviderElement<ProposalService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProposalService create(Ref ref) {
    return proposalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProposalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProposalService>(value),
    );
  }
}

String _$proposalServiceHash() => r'c77037545d524ebaf6ae306b416ea91c10077090';

@ProviderFor(assistChat)
final assistChatProvider = AssistChatProvider._();

final class AssistChatProvider
    extends $FunctionalProvider<AssistChat, AssistChat, AssistChat>
    with $Provider<AssistChat> {
  AssistChatProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assistChatProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assistChatHash();

  @$internal
  @override
  $ProviderElement<AssistChat> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssistChat create(Ref ref) {
    return assistChat(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistChat value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistChat>(value),
    );
  }
}

String _$assistChatHash() => r'a3cedf3c9b4330d6d92e61983050c92c62a91170';

/// The context scanners (docs/05 §5.2), run on app start and resume.

@ProviderFor(scannerRunner)
final scannerRunnerProvider = ScannerRunnerProvider._();

/// The context scanners (docs/05 §5.2), run on app start and resume.

final class ScannerRunnerProvider
    extends $FunctionalProvider<ScannerRunner, ScannerRunner, ScannerRunner>
    with $Provider<ScannerRunner> {
  /// The context scanners (docs/05 §5.2), run on app start and resume.
  ScannerRunnerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scannerRunnerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scannerRunnerHash();

  @$internal
  @override
  $ProviderElement<ScannerRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScannerRunner create(Ref ref) {
    return scannerRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScannerRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScannerRunner>(value),
    );
  }
}

String _$scannerRunnerHash() => r'aaece294486bb1ad94acb1d2b8f502f516f93930';

@ProviderFor(reminderSync)
final reminderSyncProvider = ReminderSyncProvider._();

final class ReminderSyncProvider
    extends $FunctionalProvider<ReminderSync, ReminderSync, ReminderSync>
    with $Provider<ReminderSync> {
  ReminderSyncProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reminderSyncProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reminderSyncHash();

  @$internal
  @override
  $ProviderElement<ReminderSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderSync create(Ref ref) {
    return reminderSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderSync>(value),
    );
  }
}

String _$reminderSyncHash() => r'7d94eec723bb8a3e493231d78628373f8398dc0b';
