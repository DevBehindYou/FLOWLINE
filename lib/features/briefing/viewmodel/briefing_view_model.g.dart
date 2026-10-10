// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'briefing_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A briefing as of now (docs/05 §21).

@ProviderFor(briefing)
final briefingProvider = BriefingFamily._();

/// A briefing as of now (docs/05 §21).

final class BriefingProvider extends $FunctionalProvider<AsyncValue<Briefing>,
        Briefing, FutureOr<Briefing>>
    with $FutureModifier<Briefing>, $FutureProvider<Briefing> {
  /// A briefing as of now (docs/05 §21).
  BriefingProvider._(
      {required BriefingFamily super.from,
      required BriefingKind super.argument})
      : super(
          retry: null,
          name: r'briefingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$briefingHash();

  @override
  String toString() {
    return r'briefingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Briefing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Briefing> create(Ref ref) {
    final argument = this.argument as BriefingKind;
    return briefing(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BriefingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$briefingHash() => r'bed93fee4d952bb1f5a4b83f84998c3ed3fcec99';

/// A briefing as of now (docs/05 §21).

final class BriefingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Briefing>, BriefingKind> {
  BriefingFamily._()
      : super(
          retry: null,
          name: r'briefingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// A briefing as of now (docs/05 §21).

  BriefingProvider call(
    BriefingKind kind,
  ) =>
      BriefingProvider._(argument: kind, from: this);

  @override
  String toString() => r'briefingProvider';
}

@ProviderFor(BriefingActions)
final briefingActionsProvider = BriefingActionsProvider._();

final class BriefingActionsProvider
    extends $NotifierProvider<BriefingActions, void> {
  BriefingActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'briefingActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$briefingActionsHash();

  @$internal
  @override
  BriefingActions create() => BriefingActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$briefingActionsHash() => r'c5fcc792564d81edc4713192191fdcb047f00a34';

abstract class _$BriefingActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
