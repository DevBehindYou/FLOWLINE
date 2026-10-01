import 'package:dio/dio.dart';

/// Turns any error that reaches the UI into a short sentence a user can act
/// on (rule R14). Raw exception text (SQL, stack details, class names)
/// never reaches the screen; it isn't useful to the user and can leak
/// internals.
String userMessageFor(Object error) {
  if (error is DioException) {
    return "Couldn't reach the server — check your connection.";
  }
  final type = error.runtimeType.toString();
  if (type.contains('Sqlite') || type.contains('Drift')) {
    return "Couldn't read your data on this phone.";
  }
  return 'Something went wrong.';
}
