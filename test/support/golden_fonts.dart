import 'package:flutter/services.dart';

/// Loads the bundled fonts and the Material icon font, so golden images
/// show real text rather than test boxes.
Future<void> loadGoldenFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      loader.addFont(rootBundle.load(file));
    }
    await loader.load();
  }

  await family('BebasNeue', ['assets/fonts/BebasNeue-Regular.ttf']);
  await family('HankenGrotesk', [
    for (final w in ['Regular', 'Medium', 'Bold'])
      'assets/fonts/HankenGrotesk-$w.ttf',
  ]);
  await family('JetBrainsMono', [
    for (final w in ['Regular', 'Medium', 'Bold'])
      'assets/fonts/JetBrainsMono-$w.ttf',
  ]);
  await family('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}
