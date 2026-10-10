// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What PLAN MY DAY would do now (docs/05 §12.3): a preview, nothing
/// written.

@ProviderFor(dayPlanPreview)
final dayPlanPreviewProvider = DayPlanPreviewProvider._();

/// What PLAN MY DAY would do now (docs/05 §12.3): a preview, nothing
/// written.

final class DayPlanPreviewProvider extends $FunctionalProvider<
        AsyncValue<List<PlannedTask>>,
        List<PlannedTask>,
        FutureOr<List<PlannedTask>>>
    with
        $FutureModifier<List<PlannedTask>>,
        $FutureProvider<List<PlannedTask>> {
  /// What PLAN MY DAY would do now (docs/05 §12.3): a preview, nothing
  /// written.
  DayPlanPreviewProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dayPlanPreviewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dayPlanPreviewHash();

  @$internal
  @override
  $FutureProviderElement<List<PlannedTask>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlannedTask>> create(Ref ref) {
    return dayPlanPreview(ref);
  }
}

String _$dayPlanPreviewHash() => r'540870e601e4fc7cd7baaf50d93ec4157d6f7059';

@ProviderFor(PlanDayActions)
final planDayActionsProvider = PlanDayActionsProvider._();

final class PlanDayActionsProvider
    extends $NotifierProvider<PlanDayActions, void> {
  PlanDayActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'planDayActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$planDayActionsHash();

  @$internal
  @override
  PlanDayActions create() => PlanDayActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$planDayActionsHash() => r'4038dd3a48bf912193fee483a3be50316d316230';

abstract class _$PlanDayActions extends $Notifier<void> {
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
