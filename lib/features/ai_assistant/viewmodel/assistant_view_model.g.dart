// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiProvidersHash() => r'7a74f36e4aa0a8a07b370ab260708690afe3a58e';

/// See also [aiProviders].
@ProviderFor(aiProviders)
final aiProvidersProvider =
    AutoDisposeStreamProvider<List<AIProviderConfig>>.internal(
  aiProviders,
  name: r'aiProvidersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiProvidersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiProvidersRef = AutoDisposeStreamProviderRef<List<AIProviderConfig>>;
String _$activeAiProviderHash() => r'f45af6d8f8932a40010fe1a4f8240f055803e611';

/// See also [activeAiProvider].
@ProviderFor(activeAiProvider)
final activeAiProviderProvider =
    AutoDisposeStreamProvider<AIProviderConfig?>.internal(
  activeAiProvider,
  name: r'activeAiProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeAiProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAiProviderRef = AutoDisposeStreamProviderRef<AIProviderConfig?>;
String _$providerHasKeyHash() => r'584a2700093f4e1248847afa63e185f04c23374a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [providerHasKey].
@ProviderFor(providerHasKey)
const providerHasKeyProvider = ProviderHasKeyFamily();

/// See also [providerHasKey].
class ProviderHasKeyFamily extends Family<AsyncValue<bool>> {
  /// See also [providerHasKey].
  const ProviderHasKeyFamily();

  /// See also [providerHasKey].
  ProviderHasKeyProvider call(
    AIProviderId id,
  ) {
    return ProviderHasKeyProvider(
      id,
    );
  }

  @override
  ProviderHasKeyProvider getProviderOverride(
    covariant ProviderHasKeyProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'providerHasKeyProvider';
}

/// See also [providerHasKey].
class ProviderHasKeyProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [providerHasKey].
  ProviderHasKeyProvider(
    AIProviderId id,
  ) : this._internal(
          (ref) => providerHasKey(
            ref as ProviderHasKeyRef,
            id,
          ),
          from: providerHasKeyProvider,
          name: r'providerHasKeyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$providerHasKeyHash,
          dependencies: ProviderHasKeyFamily._dependencies,
          allTransitiveDependencies:
              ProviderHasKeyFamily._allTransitiveDependencies,
          id: id,
        );

  ProviderHasKeyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final AIProviderId id;

  @override
  Override overrideWith(
    FutureOr<bool> Function(ProviderHasKeyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProviderHasKeyProvider._internal(
        (ref) => create(ref as ProviderHasKeyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _ProviderHasKeyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderHasKeyProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProviderHasKeyRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `id` of this provider.
  AIProviderId get id;
}

class _ProviderHasKeyProviderElement
    extends AutoDisposeFutureProviderElement<bool> with ProviderHasKeyRef {
  _ProviderHasKeyProviderElement(super.provider);

  @override
  AIProviderId get id => (origin as ProviderHasKeyProvider).id;
}

String _$latestConversationForProviderHash() =>
    r'b198597860af39306013732a6a8915a1b1c6e96b';

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.
///
/// Copied from [latestConversationForProvider].
@ProviderFor(latestConversationForProvider)
const latestConversationForProviderProvider =
    LatestConversationForProviderFamily();

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.
///
/// Copied from [latestConversationForProvider].
class LatestConversationForProviderFamily
    extends Family<AsyncValue<AIConversation?>> {
  /// The Assistant tab keeps one ongoing thread per provider rather than a
  /// full conversation list (that's a natural Phase 3b addition once this
  /// is in use) — this picks the most recent one, if any.
  ///
  /// Copied from [latestConversationForProvider].
  const LatestConversationForProviderFamily();

  /// The Assistant tab keeps one ongoing thread per provider rather than a
  /// full conversation list (that's a natural Phase 3b addition once this
  /// is in use) — this picks the most recent one, if any.
  ///
  /// Copied from [latestConversationForProvider].
  LatestConversationForProviderProvider call(
    AIProviderId providerId,
  ) {
    return LatestConversationForProviderProvider(
      providerId,
    );
  }

  @override
  LatestConversationForProviderProvider getProviderOverride(
    covariant LatestConversationForProviderProvider provider,
  ) {
    return call(
      provider.providerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'latestConversationForProviderProvider';
}

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.
///
/// Copied from [latestConversationForProvider].
class LatestConversationForProviderProvider
    extends AutoDisposeStreamProvider<AIConversation?> {
  /// The Assistant tab keeps one ongoing thread per provider rather than a
  /// full conversation list (that's a natural Phase 3b addition once this
  /// is in use) — this picks the most recent one, if any.
  ///
  /// Copied from [latestConversationForProvider].
  LatestConversationForProviderProvider(
    AIProviderId providerId,
  ) : this._internal(
          (ref) => latestConversationForProvider(
            ref as LatestConversationForProviderRef,
            providerId,
          ),
          from: latestConversationForProviderProvider,
          name: r'latestConversationForProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$latestConversationForProviderHash,
          dependencies: LatestConversationForProviderFamily._dependencies,
          allTransitiveDependencies:
              LatestConversationForProviderFamily._allTransitiveDependencies,
          providerId: providerId,
        );

  LatestConversationForProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.providerId,
  }) : super.internal();

  final AIProviderId providerId;

  @override
  Override overrideWith(
    Stream<AIConversation?> Function(LatestConversationForProviderRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestConversationForProviderProvider._internal(
        (ref) => create(ref as LatestConversationForProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        providerId: providerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AIConversation?> createElement() {
    return _LatestConversationForProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestConversationForProviderProvider &&
        other.providerId == providerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, providerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LatestConversationForProviderRef
    on AutoDisposeStreamProviderRef<AIConversation?> {
  /// The parameter `providerId` of this provider.
  AIProviderId get providerId;
}

class _LatestConversationForProviderProviderElement
    extends AutoDisposeStreamProviderElement<AIConversation?>
    with LatestConversationForProviderRef {
  _LatestConversationForProviderProviderElement(super.provider);

  @override
  AIProviderId get providerId =>
      (origin as LatestConversationForProviderProvider).providerId;
}

String _$conversationMessagesHash() =>
    r'86ab7376e132991e4fc31a92571cc0b871b8eb24';

/// See also [conversationMessages].
@ProviderFor(conversationMessages)
const conversationMessagesProvider = ConversationMessagesFamily();

/// See also [conversationMessages].
class ConversationMessagesFamily extends Family<AsyncValue<List<AIMessage>>> {
  /// See also [conversationMessages].
  const ConversationMessagesFamily();

  /// See also [conversationMessages].
  ConversationMessagesProvider call(
    int conversationId,
  ) {
    return ConversationMessagesProvider(
      conversationId,
    );
  }

  @override
  ConversationMessagesProvider getProviderOverride(
    covariant ConversationMessagesProvider provider,
  ) {
    return call(
      provider.conversationId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationMessagesProvider';
}

/// See also [conversationMessages].
class ConversationMessagesProvider
    extends AutoDisposeStreamProvider<List<AIMessage>> {
  /// See also [conversationMessages].
  ConversationMessagesProvider(
    int conversationId,
  ) : this._internal(
          (ref) => conversationMessages(
            ref as ConversationMessagesRef,
            conversationId,
          ),
          from: conversationMessagesProvider,
          name: r'conversationMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$conversationMessagesHash,
          dependencies: ConversationMessagesFamily._dependencies,
          allTransitiveDependencies:
              ConversationMessagesFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  ConversationMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final int conversationId;

  @override
  Override overrideWith(
    Stream<List<AIMessage>> Function(ConversationMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationMessagesProvider._internal(
        (ref) => create(ref as ConversationMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AIMessage>> createElement() {
    return _ConversationMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMessagesRef on AutoDisposeStreamProviderRef<List<AIMessage>> {
  /// The parameter `conversationId` of this provider.
  int get conversationId;
}

class _ConversationMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<AIMessage>>
    with ConversationMessagesRef {
  _ConversationMessagesProviderElement(super.provider);

  @override
  int get conversationId =>
      (origin as ConversationMessagesProvider).conversationId;
}

String _$assistantViewModelHash() =>
    r'3cd54f073b8df3aef807276f057cacec86968bc1';

/// See also [AssistantViewModel].
@ProviderFor(AssistantViewModel)
final assistantViewModelProvider =
    AutoDisposeNotifierProvider<AssistantViewModel, bool>.internal(
  AssistantViewModel.new,
  name: r'assistantViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$assistantViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AssistantViewModel = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
