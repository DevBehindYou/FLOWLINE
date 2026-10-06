// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Open proposals, newest first (docs/05 §11 SUGGESTED).

@ProviderFor(openProposals)
final openProposalsProvider = OpenProposalsProvider._();

/// Open proposals, newest first (docs/05 §11 SUGGESTED).

final class OpenProposalsProvider extends $FunctionalProvider<
        AsyncValue<List<Proposal>>, List<Proposal>, Stream<List<Proposal>>>
    with $FutureModifier<List<Proposal>>, $StreamProvider<List<Proposal>> {
  /// Open proposals, newest first (docs/05 §11 SUGGESTED).
  OpenProposalsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openProposalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openProposalsHash();

  @$internal
  @override
  $StreamProviderElement<List<Proposal>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Proposal>> create(Ref ref) {
    return openProposals(ref);
  }
}

String _$openProposalsHash() => r'7169d5b3cb306a9c7e46a99d55d23570c826808f';

/// The Inbox tab's badge.

@ProviderFor(openProposalCount)
final openProposalCountProvider = OpenProposalCountProvider._();

/// The Inbox tab's badge.

final class OpenProposalCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The Inbox tab's badge.
  OpenProposalCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openProposalCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openProposalCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return openProposalCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$openProposalCountHash() => r'c5f0b62a583457b947e19aa56896c2f29afbc2a7';

/// What a proposal would do, worded from the tool's own preview against
/// the state now; null when it no longer fits (it can't be accepted).

@ProviderFor(proposalPreview)
final proposalPreviewProvider = ProposalPreviewFamily._();

/// What a proposal would do, worded from the tool's own preview against
/// the state now; null when it no longer fits (it can't be accepted).

final class ProposalPreviewProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              ActionPreview preview,
              ActionRisk risk,
            })?>,
        ({
          ActionPreview preview,
          ActionRisk risk,
        })?,
        FutureOr<
            ({
              ActionPreview preview,
              ActionRisk risk,
            })?>>
    with
        $FutureModifier<
            ({
              ActionPreview preview,
              ActionRisk risk,
            })?>,
        $FutureProvider<
            ({
              ActionPreview preview,
              ActionRisk risk,
            })?> {
  /// What a proposal would do, worded from the tool's own preview against
  /// the state now; null when it no longer fits (it can't be accepted).
  ProposalPreviewProvider._(
      {required ProposalPreviewFamily super.from,
      required Proposal super.argument})
      : super(
          retry: null,
          name: r'proposalPreviewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$proposalPreviewHash();

  @override
  String toString() {
    return r'proposalPreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      ({
        ActionPreview preview,
        ActionRisk risk,
      })?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        ActionPreview preview,
        ActionRisk risk,
      })?> create(Ref ref) {
    final argument = this.argument as Proposal;
    return proposalPreview(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProposalPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proposalPreviewHash() => r'c23549f4091e95656d7c5e25529207ac168a5f50';

/// What a proposal would do, worded from the tool's own preview against
/// the state now; null when it no longer fits (it can't be accepted).

final class ProposalPreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  ActionPreview preview,
                  ActionRisk risk,
                })?>,
            Proposal> {
  ProposalPreviewFamily._()
      : super(
          retry: null,
          name: r'proposalPreviewProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// What a proposal would do, worded from the tool's own preview against
  /// the state now; null when it no longer fits (it can't be accepted).

  ProposalPreviewProvider call(
    Proposal proposal,
  ) =>
      ProposalPreviewProvider._(argument: proposal, from: this);

  @override
  String toString() => r'proposalPreviewProvider';
}

/// Today's ledger (DONE BY AA · TODAY).

@ProviderFor(todaysActions)
final todaysActionsProvider = TodaysActionsProvider._();

/// Today's ledger (DONE BY AA · TODAY).

final class TodaysActionsProvider extends $FunctionalProvider<
        AsyncValue<List<LedgerEntry>>,
        List<LedgerEntry>,
        Stream<List<LedgerEntry>>>
    with
        $FutureModifier<List<LedgerEntry>>,
        $StreamProvider<List<LedgerEntry>> {
  /// Today's ledger (DONE BY AA · TODAY).
  TodaysActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaysActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaysActionsHash();

  @$internal
  @override
  $StreamProviderElement<List<LedgerEntry>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<LedgerEntry>> create(Ref ref) {
    return todaysActions(ref);
  }
}

String _$todaysActionsHash() => r'e20c463467f22b9b7b01afb602ddc51d62dbaf2a';

/// The last 30 days, for Activity, newest first.

@ProviderFor(recentActions)
final recentActionsProvider = RecentActionsProvider._();

/// The last 30 days, for Activity, newest first.

final class RecentActionsProvider extends $FunctionalProvider<
        AsyncValue<List<LedgerEntry>>,
        List<LedgerEntry>,
        Stream<List<LedgerEntry>>>
    with
        $FutureModifier<List<LedgerEntry>>,
        $StreamProvider<List<LedgerEntry>> {
  /// The last 30 days, for Activity, newest first.
  RecentActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentActionsHash();

  @$internal
  @override
  $StreamProviderElement<List<LedgerEntry>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<LedgerEntry>> create(Ref ref) {
    return recentActions(ref);
  }
}

String _$recentActionsHash() => r'd3581a67b14d76e2f86bb4a3b3e794d15e94a9a9';

@ProviderFor(InboxActions)
final inboxActionsProvider = InboxActionsProvider._();

final class InboxActionsProvider extends $NotifierProvider<InboxActions, void> {
  InboxActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inboxActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inboxActionsHash();

  @$internal
  @override
  InboxActions create() => InboxActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$inboxActionsHash() => r'24b48686586a010033036b0731c3954df7f1f8d8';

abstract class _$InboxActions extends $Notifier<void> {
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
