import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';

/// Turns any error that reaches the UI into a short sentence a user can act
/// on (rule R14). Raw exception text (SQL, stack details, class names)
/// never reaches the screen; it isn't useful to the user and can leak
/// internals.
String userMessageFor(Object error, AppLocalizations l10n) {
  if (error is DioException) {
    return l10n.errorNetwork;
  }
  final type = error.runtimeType.toString();
  if (type.contains('Sqlite') || type.contains('Drift')) {
    return l10n.errorStorage;
  }
  return l10n.errorGeneric;
}
