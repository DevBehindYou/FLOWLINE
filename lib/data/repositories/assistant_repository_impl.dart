import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/proposal.dart';
import '../../domain/assistant/utterance.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../local/drift/app_database.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<int> recordUtterance(Utterance utterance, {required DateTime at}) =>
      _db.into(_db.utterances).insert(UtterancesCompanion.insert(
            at: at,
            body: utterance.text,
            source: utterance.source,
            language: Value(utterance.language),
            confidence: Value(utterance.confidence),
          ));

  @override
  Stream<List<LedgerEntry>> watchLedger(
      {required DateTime from, required DateTime to}) {
    final query = _db.select(_db.assistantActions)
      ..where(
          (a) => a.at.isBiggerOrEqualValue(from) & a.at.isSmallerThanValue(to))
      ..orderBy([(a) => OrderingTerm.desc(a.id)]);
    return query.watch().map((rows) => rows.map(_entry).toList());
  }

  @override
  Stream<List<LedgerEntry>> watchGroup(String groupId) {
    final query = _db.select(_db.assistantActions)
      ..where((a) => a.groupId.equals(groupId))
      ..orderBy([(a) => OrderingTerm.asc(a.id)]);
    return query.watch().map((rows) => rows.map(_entry).toList());
  }

  @override
  Future<List<LedgerEntry>> getGroup(String groupId) async {
    final rows = await (_db.select(_db.assistantActions)
          ..where((a) => a.groupId.equals(groupId))
          ..orderBy([(a) => OrderingTerm.asc(a.id)]))
        .get();
    return rows.map(_entry).toList();
  }

  @override
  Future<int?> createProposal(ProposalDraft draft, {required DateTime at}) {
    // Check and insert in one transaction (one connection, so nothing can
    // slip between them); the partial unique index proposals_open_key is
    // the backstop.
    return _db.transaction(() async {
      final open = await (_db.select(_db.proposals)
            ..where((p) =>
                p.dedupeKey.equals(draft.dedupeKey) &
                p.status.equalsValue(ProposalStatus.open)))
          .get();
      if (open.isNotEmpty) return null;
      return _db.into(_db.proposals).insert(ProposalsCompanion.insert(
            createdAt: at,
            expiresAt: Value(draft.expiresAt),
            toolName: draft.toolName,
            argsJson: draft.argsJson,
            origin: draft.origin,
            reason: draft.reason,
            reasonJson: Value(draft.reasonJson),
            sourceText: Value(draft.sourceText),
            dedupeKey: draft.dedupeKey,
            status: ProposalStatus.open,
          ));
    });
  }

  @override
  Future<Proposal?> getProposal(int id) async {
    final row = await (_db.select(_db.proposals)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _proposal(row);
  }

  @override
  Stream<List<Proposal>> watchOpenProposals(DateTime now) {
    final query = _db.select(_db.proposals)
      ..where((p) =>
          p.status.equalsValue(ProposalStatus.open) &
          (p.expiresAt.isNull() | p.expiresAt.isBiggerThanValue(now)))
      ..orderBy([(p) => OrderingTerm.desc(p.id)]);
    return query.watch().map((rows) => rows.map(_proposal).toList());
  }

  @override
  Future<bool> closeProposal(int id, ProposalStatus status) async {
    final changed = await (_db.update(_db.proposals)
          ..where((p) =>
              p.id.equals(id) & p.status.equalsValue(ProposalStatus.open)))
        .write(ProposalsCompanion(status: Value(status)));
    return changed == 1;
  }

  @override
  Future<int> expireProposals(DateTime now) => (_db.update(_db.proposals)
        ..where((p) =>
            p.status.equalsValue(ProposalStatus.open) &
            p.expiresAt.isSmallerOrEqualValue(now)))
      .write(const ProposalsCompanion(status: Value(ProposalStatus.expired)));

  LedgerEntry _entry(AssistantActionRow r) => LedgerEntry(
        id: r.id,
        at: r.at,
        groupId: r.groupId,
        toolName: r.toolName,
        argsJson: r.argsJson,
        origin: r.origin,
        decision: r.decision,
        status: r.status,
        undo: decodeUndoRecipe(r.undoJson),
        utteranceId: r.utteranceId,
        preview: _preview(r.previewJson),
      );

  static ActionPreview? _preview(String? json) {
    if (json == null) return null;
    try {
      return previewFromJson(jsonDecode(json));
    } on FormatException {
      return null;
    }
  }

  Proposal _proposal(ProposalRow r) => Proposal(
        id: r.id,
        createdAt: r.createdAt,
        expiresAt: r.expiresAt,
        toolName: r.toolName,
        argsJson: r.argsJson,
        origin: r.origin,
        reason: r.reason,
        reasonJson: r.reasonJson,
        sourceText: r.sourceText,
        dedupeKey: r.dedupeKey,
        status: r.status,
      );
}
