import 'package:atomic_assist/core/layout/window_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Material 3 width breakpoints', () {
    expect(WindowSizeClass.forWidth(360), WindowSizeClass.compact);
    expect(WindowSizeClass.forWidth(599.9), WindowSizeClass.compact);
    expect(WindowSizeClass.forWidth(600), WindowSizeClass.medium);
    expect(WindowSizeClass.forWidth(839.9), WindowSizeClass.medium);
    expect(WindowSizeClass.forWidth(840), WindowSizeClass.expanded);
  });
}
