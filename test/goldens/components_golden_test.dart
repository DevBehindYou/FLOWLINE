@Tags(['golden'])
library;

import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../design/component_gallery.dart';
import '../support/golden_fonts.dart';

/// The Atomic component library in light and dark, at 100% and 200% text
/// (docs/05 Phase B exit gate). Regenerate with
///   flutter test --update-goldens test/goldens
/// and look at the images before committing.
void main() {
  setUpAll(loadGoldenFonts);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 2.0]) {
      final file = 'components_${mode.name}_${scale == 1 ? '1x' : '2x'}';
      testWidgets(file, (tester) async {
        // Tall enough for the whole gallery at 1x; at 2x it scrolls, and
        // the image shows the top half (the rest is covered at 1x).
        tester.view.physicalSize = const Size(360, 1700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTouch;
        addTearDown(() => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic);

        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AtomicTheme.light(),
          darkTheme: AtomicTheme.dark(),
          themeMode: mode,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: const ComponentGallery(),
            ),
          ),
        ));
        // The loading bar is indeterminate: freeze it at a fixed point.
        await tester.pump(AtomicDurations.enter);
        await expectLater(
            find.byType(MaterialApp), matchesGoldenFile('images/$file.png'));
      });
    }
  }
}
