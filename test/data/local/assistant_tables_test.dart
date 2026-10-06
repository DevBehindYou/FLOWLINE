import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/ledger.dart';
import 'package:atomic_assist/domain/assistant/proposal.dart';
import 'package:atomic_assist/domain/assistant/utterance.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// The invariants schema v8 keeps in SQL (R3), not in Dart.
void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  final at = DateTime(2026, 10, 5, 9);

  Future<int> addUtterance({String body = 'remind me at 7', double? conf}) =>
      db.into(db.utterances).insert(UtterancesCompanion.insert(
            at: at,
            body: body,
            source: UtteranceSource.voice,
            confidence: Value(conf),
          ));

  AssistantActionsCompanion action({
    String groupId = 'g1',
    String toolName = 'create_task',
    int? utteranceId,
  }) =>
      AssistantActionsCompanion.insert(
        at: at,
        groupId: groupId,
        toolName: toolName,
        argsJson: '{"title":"Call Mum"}',
        origin: ActionOrigin.said,
        decision: Decision.executeWithUndo,
        status: LedgerStatus.done,
        undoJson:
            Value(encodeUndoRecipe(const DeleteRows(UndoTable.tasks, [1]))),
        utteranceId: Value(utteranceId),
      );

  ProposalsCompanion proposal({
    String key = 'upcomingDates:person:12:2026-10-09',
    ProposalStatus status = ProposalStatus.open,
    DateTime? expiresAt,
  }) =>
      ProposalsCompanion.insert(
        createdAt: at,
        expiresAt: Value(expiresAt),
        toolName: 'create_reminder',
        argsJson: '{}',
        origin: ActionOrigin.context,
        reason: ProposalReason.upcomingDate,
        dedupeKey: key,
        status: status,
      );

  group('ledger', () {
    test('stores enums and the recipe, and reads them back', () async {
      final id = await db.into(db.assistantActions).insert(action());
      final row = await (db.select(db.assistantActions)
            ..where((a) => a.id.equals(id)))
          .getSingle();
      expect(row.origin, ActionOrigin.said);
      expect(row.decision, Decision.executeWithUndo);
      expect(row.status, LedgerStatus.done);
      expect(decodeUndoRecipe(row.undoJson), isA<DeleteRows>());
    });

    test('rejects an empty tool name or group id', () async {
      await expectLater(
          db.into(db.assistantActions).insert(action(toolName: '')),
          throwsA(isA<Exception>()));
      await expectLater(
          db.into(db.assistantActions).insert(action(groupId: '')),
          throwsA(isA<Exception>()));
    });

    test('keeps its rows when the utterance is deleted', () async {
      final u = await addUtterance();
      final id =
          await db.into(db.assistantActions).insert(action(utteranceId: u));
      await (db.delete(db.utterances)..where((t) => t.id.equals(u))).go();
      final row = await (db.select(db.assistantActions)
            ..where((a) => a.id.equals(id)))
          .getSingle();
      expect(row.utteranceId, isNull);
    });

    test('rejects an utterance id that does not exist', () async {
      await expectLater(
          db.into(db.assistantActions).insert(action(utteranceId: 99)),
          throwsA(isA<Exception>()));
    });
  });

  group('utterances', () {
    test('rejects empty text and confidence outside 0..1', () async {
      await expectLater(addUtterance(body: ''), throwsA(isA<Exception>()));
      await expectLater(addUtterance(conf: 1.5), throwsA(isA<Exception>()));
      await expectLater(addUtterance(conf: -0.1), throwsA(isA<Exception>()));
      expect(await addUtterance(conf: 0.93), isPositive);
    });
  });

  group('proposals', () {
    test('at most one open proposal per dedupe key', () async {
      await db.into(db.proposals).insert(proposal());
      await expectLater(
          db.into(db.proposals).insert(proposal()), throwsA(isA<Exception>()));
    });

    test('a closed proposal does not block a new open one', () async {
      await db
          .into(db.proposals)
          .insert(proposal(status: ProposalStatus.dismissed));
      await db
          .into(db.proposals)
          .insert(proposal(status: ProposalStatus.expired));
      expect(await db.into(db.proposals).insert(proposal()), isPositive);
      // Different keys never collide.
      expect(await db.into(db.proposals).insert(proposal(key: 'other')),
          isPositive);
    });

    test('expiry must be after creation', () async {
      await expectLater(db.into(db.proposals).insert(proposal(expiresAt: at)),
          throwsA(isA<Exception>()));
      expect(
          await db
              .into(db.proposals)
              .insert(proposal(expiresAt: at.add(const Duration(hours: 1)))),
          isPositive);
    });

    test('rejects an empty dedupe key', () async {
      await expectLater(db.into(db.proposals).insert(proposal(key: '')),
          throwsA(isA<Exception>()));
    });
  });

  test('"Clear all data" empties the assistant tables too', () async {
    final u = await addUtterance();
    await db.into(db.assistantActions).insert(action(utteranceId: u));
    await db.into(db.proposals).insert(proposal());
    await db.wipeAllData();
    expect(await db.select(db.utterances).get(), isEmpty);
    expect(await db.select(db.assistantActions).get(), isEmpty);
    expect(await db.select(db.proposals).get(), isEmpty);
  });

  test('stored enums keep their indexes (R1: append-only)', () {
    expect(ProposalStatus.open.index, 0,
        reason: 'proposals_open_key is a partial index on status = 0');
    expect(ProposalStatus.values.map((e) => e.name),
        ['open', 'accepted', 'dismissed', 'expired']);
    expect(UtteranceSource.values.map((e) => e.name),
        ['typed', 'voice', 'share', 'notificationReply']);
    expect(ProposalReason.values.first, ProposalReason.commitment);
  });
}
