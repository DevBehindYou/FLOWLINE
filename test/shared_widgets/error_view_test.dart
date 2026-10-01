import 'package:dio/dio.dart';
import 'package:flowline/core/error/user_message.dart';
import 'package:flowline/shared_widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('userMessageFor (K9)', () {
    test('never echoes the raw exception text', () {
      final message =
          userMessageFor(StateError('SELECT * FROM tasks failed: secret'));
      expect(message, isNot(contains('secret')));
      expect(message, isNot(contains('StateError')));
    });

    test('names a network problem for Dio failures', () {
      final message = userMessageFor(
        DioException(requestOptions: RequestOptions(path: '/x')),
      );
      expect(message, contains('connection'));
    });
  });

  testWidgets('ErrorView shows plain copy and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ErrorView(
          error: Exception('SqliteException(1): no such table: tasks'),
          onRetry: () => retries++,
        ),
      ),
    ));

    expect(find.textContaining('no such table'), findsNothing);
    expect(find.text('Something went wrong.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('compact ErrorView fits inside a row of a section',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ErrorView(error: Exception('x'), compact: true, onRetry: () {}),
      ),
    ));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
