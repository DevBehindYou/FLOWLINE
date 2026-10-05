import 'autonomy.dart';

// Proposals (docs/05 §9.5): a tool call that hasn't run, waiting in the
// Inbox for one tap. Pure Dart; enums are stored by index, append-only
// (R1).

enum ProposalStatus { open, accepted, dismissed, expired }

/// Why AA suggested it (docs/05 §5). Worded by l10n from this and the
/// proposal's reason JSON, never stored as English.
enum ProposalReason {
  /// Something the user said they'd do (§5.1).
  commitment,

  // Context scanners (§5.2).
  meetingWithoutPrep,
  upcomingDate,
  overdueDrift,
  billDue,
  freeGapForTasks,
  dayOverbooked,
  followUpDue,
  documentExpiring,

  /// A repeated manual edit (§5.3).
  pattern,
}

final class Proposal {
  const Proposal({
    required this.id,
    required this.createdAt,
    required this.toolName,
    required this.argsJson,
    required this.origin,
    required this.reason,
    required this.reasonJson,
    required this.dedupeKey,
    required this.status,
    this.expiresAt,
    this.sourceText,
  });

  final int id;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String toolName;

  /// Untrusted until ACCEPT re-validates it against the current state
  /// (R16).
  final String argsJson;
  final ActionOrigin origin;
  final ProposalReason reason;
  final String reasonJson;

  /// What the user said, for "YOU SAID · …"; null for scanner findings.
  final String? sourceText;

  /// At most one open proposal per key (a partial unique index), e.g.
  /// `upcomingDates:person:12:2026-10-09`.
  final String dedupeKey;
  final ProposalStatus status;
}
