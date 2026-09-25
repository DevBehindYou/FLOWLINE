import 'package:drift/drift.dart' show Value;
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/focus_session_repository_impl.dart';
import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FocusSessionRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = FocusSessionRepositoryImpl(db);
  });
  tearDown(() => db.close());

  // A running session anchored at a fixed past instant, as if the app was
  // killed mid-session and only reopened long after it ran out.
  Future<int> insertRunning({
    required DateTime anchor,
    int plannedSec = 1500,
    int remainingSec = 1500,
  }) {
    return db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: plannedSec,
            startedAt: anchor,
            segmentStartedAt: Value(anchor),
            remainingSecAtSegmentStart: remainingSec,
          ),
        );
  }

  Future<FocusSessionRow> row(int id) =>
      (db.select(db.focusSessions)..where((s) => s.id.equals(id))).getSingle();

  test('a session that ran out unobserved is stamped at its natural end',
      () async {
    final id = await insertRunning(anchor: DateTime(2026, 1, 1, 9));

    expect(await repo.completeSession(id, endedEarly: false), isTrue);

    final done = await row(id);
    expect(done.completedAt, DateTime(2026, 1, 1, 9, 25));
    expect(done.actualDurationSec, 1500);
    expect(done.endedEarly, isFalse);
  });

  test('ending early is stamped at the moment the user ended it', () async {
    final before = DateTime.now().subtract(const Duration(seconds: 1));
    final id = await repo.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );

    await repo.completeSession(id, endedEarly: true);

    final done = await row(id);
    expect(done.completedAt!.isAfter(before), isTrue);
    expect(done.endedEarly, isTrue);
    expect(done.actualDurationSec, lessThan(1500));
  });

  test('completing twice is a no-op the second time', () async {
    final id = await insertRunning(anchor: DateTime(2026, 1, 1, 9));

    expect(await repo.completeSession(id, endedEarly: false), isTrue);
    final first = await row(id);
    expect(await repo.completeSession(id, endedEarly: true), isFalse);
    final second = await row(id);

    expect(second.completedAt, first.completedAt);
    expect(second.endedEarly, isFalse);
  });

  test('an extension counts toward planned and actual duration', () async {
    final id = await insertRunning(anchor: DateTime(2026, 1, 1, 9));

    await repo.extendSession(id, 300);
    await repo.completeSession(id, endedEarly: false);

    final done = await row(id);
    expect(done.plannedDurationSec, 1800);
    expect(done.actualDurationSec, 1800);
    expect(done.completedAt, DateTime(2026, 1, 1, 9, 30));
  });

  test('self-heal closes an expired dangling session as completed, not early',
      () async {
    final stale = await insertRunning(anchor: DateTime(2026, 1, 1, 9));

    await repo.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );

    final healed = await row(stale);
    expect(healed.endedEarly, isFalse);
    expect(healed.completedAt, DateTime(2026, 1, 1, 9, 25));
  });

  test('pausing freezes remaining time at the pause moment', () async {
    final anchor = DateTime.now().subtract(const Duration(minutes: 5));
    final id = await insertRunning(anchor: anchor);

    await repo.pauseSession(id);
    final paused = (await repo.getActiveSession())!;

    expect(paused.isPaused, isTrue);
    expect(paused.segmentStartedAt, isNull);
    // 25:00 minus ~5:00 elapsed; a second of slack for the clock tick.
    expect(paused.remainingSec, inInclusiveRange(1199, 1200));
    // Remaining must not keep draining while paused.
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect((await repo.getActiveSession())!.remainingSec, paused.remainingSec);
  });
}
