// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(people)
final peopleProvider = PeopleProvider._();

final class PeopleProvider extends $FunctionalProvider<AsyncValue<List<Person>>,
        List<Person>, Stream<List<Person>>>
    with $FutureModifier<List<Person>>, $StreamProvider<List<Person>> {
  PeopleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'peopleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$peopleHash();

  @$internal
  @override
  $StreamProviderElement<List<Person>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Person>> create(Ref ref) {
    return people(ref);
  }
}

String _$peopleHash() => r'b240cf1440fd102958ba179cd18b306439cb13fe';

@ProviderFor(person)
final personProvider = PersonFamily._();

final class PersonProvider
    extends $FunctionalProvider<AsyncValue<Person?>, Person?, FutureOr<Person?>>
    with $FutureModifier<Person?>, $FutureProvider<Person?> {
  PersonProvider._(
      {required PersonFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'personProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$personHash();

  @override
  String toString() {
    return r'personProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Person?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Person?> create(Ref ref) {
    final argument = this.argument as int;
    return person(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PersonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personHash() => r'30cd74af48a9f347cbc4d0b75d1d73b8f56d9f4d';

final class PersonFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Person?>, int> {
  PersonFamily._()
      : super(
          retry: null,
          name: r'personProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PersonProvider call(
    int id,
  ) =>
      PersonProvider._(argument: id, from: this);

  @override
  String toString() => r'personProvider';
}

@ProviderFor(personDates)
final personDatesProvider = PersonDatesFamily._();

final class PersonDatesProvider extends $FunctionalProvider<
        AsyncValue<List<PersonDate>>,
        List<PersonDate>,
        Stream<List<PersonDate>>>
    with $FutureModifier<List<PersonDate>>, $StreamProvider<List<PersonDate>> {
  PersonDatesProvider._(
      {required PersonDatesFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'personDatesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$personDatesHash();

  @override
  String toString() {
    return r'personDatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PersonDate>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PersonDate>> create(Ref ref) {
    final argument = this.argument as int;
    return personDates(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personDatesHash() => r'c00d4e962bebfc2d37f57e7d6251234c18811639';

final class PersonDatesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PersonDate>>, int> {
  PersonDatesFamily._()
      : super(
          retry: null,
          name: r'personDatesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PersonDatesProvider call(
    int personId,
  ) =>
      PersonDatesProvider._(argument: personId, from: this);

  @override
  String toString() => r'personDatesProvider';
}

@ProviderFor(personFollowUps)
final personFollowUpsProvider = PersonFollowUpsFamily._();

final class PersonFollowUpsProvider extends $FunctionalProvider<
        AsyncValue<List<FollowUp>>, List<FollowUp>, Stream<List<FollowUp>>>
    with $FutureModifier<List<FollowUp>>, $StreamProvider<List<FollowUp>> {
  PersonFollowUpsProvider._(
      {required PersonFollowUpsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'personFollowUpsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$personFollowUpsHash();

  @override
  String toString() {
    return r'personFollowUpsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FollowUp>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<FollowUp>> create(Ref ref) {
    final argument = this.argument as int;
    return personFollowUps(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PersonFollowUpsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personFollowUpsHash() => r'f996e97bd1dc12254561313f3883b521a5d2ddf2';

final class PersonFollowUpsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FollowUp>>, int> {
  PersonFollowUpsFamily._()
      : super(
          retry: null,
          name: r'personFollowUpsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PersonFollowUpsProvider call(
    int personId,
  ) =>
      PersonFollowUpsProvider._(argument: personId, from: this);

  @override
  String toString() => r'personFollowUpsProvider';
}

@ProviderFor(PeopleActions)
final peopleActionsProvider = PeopleActionsProvider._();

final class PeopleActionsProvider
    extends $NotifierProvider<PeopleActions, void> {
  PeopleActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'peopleActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$peopleActionsHash();

  @$internal
  @override
  PeopleActions create() => PeopleActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$peopleActionsHash() => r'b7d1db107f1279c20fe03383aaf510b6462bf4a6';

abstract class _$PeopleActions extends $Notifier<void> {
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
