import 'package:drift/native.dart';
import 'package:flowline/data/local/drift/app_database.dart';

/// An in-memory Drift database for widget/unit tests — never touches disk,
/// never touches the real `flowline.sqlite` a device would use. Callers
/// are responsible for `close()`; prefer `addTearDown(db.close)` right
/// after creating one.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
