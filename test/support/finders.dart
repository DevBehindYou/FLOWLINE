import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [Text] showing [label], either as written or as its mono caps form:
/// `AtomicText.mono('Retry')` draws "RETRY" and keeps "Retry" as the
/// semantics label, which is what users of screen readers hear.
Finder findLabel(String label) => find.byWidgetPredicate(
      (w) => w is Text && (w.data == label || (w.semanticsLabel == label)),
      description: 'Text "$label" (as written or in mono caps)',
    );
