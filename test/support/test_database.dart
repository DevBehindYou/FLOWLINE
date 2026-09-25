import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flowline/data/local/drift/app_database.dart';

/// An in-memory Drift database for widget/unit tests — never touches disk.
/// Callers must `close()` it, typically via `tearDown`.
///
/// `closeStreamsSynchronously` matters for widget tests: by default drift
/// closes an unlistened query stream on a timer, and flutter_test fails a
/// test that ends with a timer still pending.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true),
  );
}
