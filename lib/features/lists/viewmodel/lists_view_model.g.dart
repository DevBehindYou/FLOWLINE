// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(checklists)
final checklistsProvider = ChecklistsProvider._();

final class ChecklistsProvider extends $FunctionalProvider<
        AsyncValue<List<Checklist>>, List<Checklist>, Stream<List<Checklist>>>
    with $FutureModifier<List<Checklist>>, $StreamProvider<List<Checklist>> {
  ChecklistsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checklistsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checklistsHash();

  @$internal
  @override
  $StreamProviderElement<List<Checklist>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Checklist>> create(Ref ref) {
    return checklists(ref);
  }
}

String _$checklistsHash() => r'68daf97db3d2728ca49a37a17b4b4804f4bd6de2';

@ProviderFor(checklistItems)
final checklistItemsProvider = ChecklistItemsFamily._();

final class ChecklistItemsProvider extends $FunctionalProvider<
        AsyncValue<List<ChecklistItem>>,
        List<ChecklistItem>,
        Stream<List<ChecklistItem>>>
    with
        $FutureModifier<List<ChecklistItem>>,
        $StreamProvider<List<ChecklistItem>> {
  ChecklistItemsProvider._(
      {required ChecklistItemsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'checklistItemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checklistItemsHash();

  @override
  String toString() {
    return r'checklistItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChecklistItem>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ChecklistItem>> create(Ref ref) {
    final argument = this.argument as int;
    return checklistItems(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChecklistItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checklistItemsHash() => r'0964a83aa749e92e826ef15f7ebfc42057910b04';

final class ChecklistItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChecklistItem>>, int> {
  ChecklistItemsFamily._()
      : super(
          retry: null,
          name: r'checklistItemsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ChecklistItemsProvider call(
    int listId,
  ) =>
      ChecklistItemsProvider._(argument: listId, from: this);

  @override
  String toString() => r'checklistItemsProvider';
}

@ProviderFor(ListsActions)
final listsActionsProvider = ListsActionsProvider._();

final class ListsActionsProvider extends $NotifierProvider<ListsActions, void> {
  ListsActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'listsActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$listsActionsHash();

  @$internal
  @override
  ListsActions create() => ListsActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$listsActionsHash() => r'34ec412265c47b24dd6080c85bdc8a000ccab7fd';

abstract class _$ListsActions extends $Notifier<void> {
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
