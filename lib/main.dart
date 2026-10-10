import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'assistant/reminder_sync.dart';
import 'core/notifications/notification_service.dart';
import 'core/riverpod_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  // Reminder buttons pressed while the app is closed (docs/05 §13).
  NotificationService.backgroundResponseHandler = reminderActionInBackground;
  runApp(
      const ProviderScope(retry: noAutomaticRetry, child: AtomicAssistApp()));
}

/// The bundled fonts' SIL OFL 1.1 texts, shown on the Licenses page.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Bebas Neue', 'assets/fonts/BebasNeue-OFL.txt'),
    ('Hanken Grotesk', 'assets/fonts/HankenGrotesk-OFL.txt'),
    ('JetBrains Mono', 'assets/fonts/JetBrainsMono-OFL.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks(
        [family], await rootBundle.loadString(file));
  }
}
