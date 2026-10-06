import '../assistant/ledger.dart';
import '../assistant/proposal.dart';
import '../assistant/utterance.dart';

/// What the assistant core stores besides the user's own data: what was
/// said, what AA did (the ledger is written by the tool executor, in the
/// same transaction as each change), and what it suggests.
abstract interface class AssistantRepository {
  Future<int> recordUtterance(Utterance utterance, {required DateTime at});

  /// Ledger entries with `at` in `[from, to)`, newest first.
  Stream<List<LedgerEntry>> watchLedger(
      {required DateTime from, required DateTime to});

  Future<List<LedgerEntry>> getGroup(String groupId);

  /// One turn's entries, oldest first, live (an UNDO shows at once).
  Stream<List<LedgerEntry>> watchGroup(String groupId);

  /// Stores [draft], or returns null when an open proposal with the same
  /// dedupe key exists (the database enforces it).
  Future<int?> createProposal(ProposalDraft draft, {required DateTime at});

  Future<Proposal?> getProposal(int id);

  /// Open proposals not past their expiry at [now], newest first.
  Stream<List<Proposal>> watchOpenProposals(DateTime now);

  /// Moves an open proposal to [status]. False when it wasn't open (it was
  /// accepted, dismissed or expired already), so a double tap acts once.
  Future<bool> closeProposal(int id, ProposalStatus status);

  /// Marks every open proposal whose expiry has passed as expired.
  Future<int> expireProposals(DateTime now);
}
