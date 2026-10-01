// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiProviders)
final aiProvidersProvider = AiProvidersProvider._();

final class AiProvidersProvider extends $FunctionalProvider<
        AsyncValue<List<AIProviderConfig>>,
        List<AIProviderConfig>,
        Stream<List<AIProviderConfig>>>
    with
        $FutureModifier<List<AIProviderConfig>>,
        $StreamProvider<List<AIProviderConfig>> {
  AiProvidersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'aiProvidersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aiProvidersHash();

  @$internal
  @override
  $StreamProviderElement<List<AIProviderConfig>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<AIProviderConfig>> create(Ref ref) {
    return aiProviders(ref);
  }
}

String _$aiProvidersHash() => r'7a74f36e4aa0a8a07b370ab260708690afe3a58e';

@ProviderFor(activeAiProvider)
final activeAiProviderProvider = ActiveAiProviderProvider._();

final class ActiveAiProviderProvider extends $FunctionalProvider<
        AsyncValue<AIProviderConfig?>,
        AIProviderConfig?,
        Stream<AIProviderConfig?>>
    with
        $FutureModifier<AIProviderConfig?>,
        $StreamProvider<AIProviderConfig?> {
  ActiveAiProviderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeAiProviderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeAiProviderHash();

  @$internal
  @override
  $StreamProviderElement<AIProviderConfig?> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AIProviderConfig?> create(Ref ref) {
    return activeAiProvider(ref);
  }
}

String _$activeAiProviderHash() => r'f45af6d8f8932a40010fe1a4f8240f055803e611';

@ProviderFor(providerHasKey)
final providerHasKeyProvider = ProviderHasKeyFamily._();

final class ProviderHasKeyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  ProviderHasKeyProvider._(
      {required ProviderHasKeyFamily super.from,
      required AIProviderId super.argument})
      : super(
          retry: null,
          name: r'providerHasKeyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$providerHasKeyHash();

  @override
  String toString() {
    return r'providerHasKeyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as AIProviderId;
    return providerHasKey(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderHasKeyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$providerHasKeyHash() => r'584a2700093f4e1248847afa63e185f04c23374a';

final class ProviderHasKeyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, AIProviderId> {
  ProviderHasKeyFamily._()
      : super(
          retry: null,
          name: r'providerHasKeyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ProviderHasKeyProvider call(
    AIProviderId id,
  ) =>
      ProviderHasKeyProvider._(argument: id, from: this);

  @override
  String toString() => r'providerHasKeyProvider';
}

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.

@ProviderFor(latestConversationForProvider)
final latestConversationForProviderProvider =
    LatestConversationForProviderFamily._();

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.

final class LatestConversationForProviderProvider extends $FunctionalProvider<
        AsyncValue<AIConversation?>, AIConversation?, Stream<AIConversation?>>
    with $FutureModifier<AIConversation?>, $StreamProvider<AIConversation?> {
  /// The Assistant tab keeps one ongoing thread per provider rather than a
  /// full conversation list (that's a natural Phase 3b addition once this
  /// is in use) — this picks the most recent one, if any.
  LatestConversationForProviderProvider._(
      {required LatestConversationForProviderFamily super.from,
      required AIProviderId super.argument})
      : super(
          retry: null,
          name: r'latestConversationForProviderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$latestConversationForProviderHash();

  @override
  String toString() {
    return r'latestConversationForProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AIConversation?> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AIConversation?> create(Ref ref) {
    final argument = this.argument as AIProviderId;
    return latestConversationForProvider(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LatestConversationForProviderProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestConversationForProviderHash() =>
    r'b198597860af39306013732a6a8915a1b1c6e96b';

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.

final class LatestConversationForProviderFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AIConversation?>, AIProviderId> {
  LatestConversationForProviderFamily._()
      : super(
          retry: null,
          name: r'latestConversationForProviderProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// The Assistant tab keeps one ongoing thread per provider rather than a
  /// full conversation list (that's a natural Phase 3b addition once this
  /// is in use) — this picks the most recent one, if any.

  LatestConversationForProviderProvider call(
    AIProviderId providerId,
  ) =>
      LatestConversationForProviderProvider._(argument: providerId, from: this);

  @override
  String toString() => r'latestConversationForProviderProvider';
}

@ProviderFor(conversationMessages)
final conversationMessagesProvider = ConversationMessagesFamily._();

final class ConversationMessagesProvider extends $FunctionalProvider<
        AsyncValue<List<AIMessage>>, List<AIMessage>, Stream<List<AIMessage>>>
    with $FutureModifier<List<AIMessage>>, $StreamProvider<List<AIMessage>> {
  ConversationMessagesProvider._(
      {required ConversationMessagesFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'conversationMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$conversationMessagesHash();

  @override
  String toString() {
    return r'conversationMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AIMessage>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<AIMessage>> create(Ref ref) {
    final argument = this.argument as int;
    return conversationMessages(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationMessagesHash() =>
    r'86ab7376e132991e4fc31a92571cc0b871b8eb24';

final class ConversationMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AIMessage>>, int> {
  ConversationMessagesFamily._()
      : super(
          retry: null,
          name: r'conversationMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ConversationMessagesProvider call(
    int conversationId,
  ) =>
      ConversationMessagesProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'conversationMessagesProvider';
}

@ProviderFor(AssistantViewModel)
final assistantViewModelProvider = AssistantViewModelProvider._();

final class AssistantViewModelProvider
    extends $NotifierProvider<AssistantViewModel, bool> {
  AssistantViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assistantViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assistantViewModelHash();

  @$internal
  @override
  AssistantViewModel create() => AssistantViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$assistantViewModelHash() =>
    r'3f3fb8fac0f179c4b34e94a8a88099e3940ee979';

abstract class _$AssistantViewModel extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
