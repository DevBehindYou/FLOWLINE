import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/riverpod_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(const ProviderScope(retry: noAutomaticRetry, child: FlowlineApp()));
}

/// The bundled fonts' SIL OFL 1.1 texts, shown on the Licenses page.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Inter', 'assets/fonts/Inter-OFL.txt'),
    ('Space Grotesk', 'assets/fonts/SpaceGrotesk-OFL.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks(
        [family], await rootBundle.loadString(file));
  }
}
