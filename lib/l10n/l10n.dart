import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'action_text.dart';
export 'ai_failure_text.dart';
export 'app_localizations.dart';
export 'enum_labels.dart';
export 'formats.dart';

/// `context.l10n.someString` for every user-facing string (no literals in
/// widgets; test/code_rules enforces it).
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings for code without a BuildContext (notification text scheduled
/// from a view model): the device's preferred supported language.
AppLocalizations deviceLocalizations() => lookupAppLocalizations(
      basicLocaleListResolution(
        PlatformDispatcher.instance.locales,
        AppLocalizations.supportedLocales,
      ),
    );
