import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/features/ai_assistant/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  AIMessage reply(AIStopReason? stop) => AIMessage(
        id: 1,
        conversationId: 1,
        role: AIMessageRole.assistant,
        content: 'Here is the first part',
        sentAt: DateTime(2026, 10, 5, 9),
        stopReason: stop,
      );

  for (final (stop, shown) in [
    (AIStopReason.maxTokens, true),
    (AIStopReason.complete, false),
    (null, false), // rows from before schema v9
  ]) {
    testWidgets('cut-off line for $stop: $shown (B18)', (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await pumpScreen(tester,
          db: db, child: Scaffold(body: ChatBubble(message: reply(stop))));
      expect(find.text('Here is the first part'), findsOneWidget);
      expect(find.text('Cut off: the reply reached its length limit.'),
          shown ? findsOneWidget : findsNothing);
    });
  }
}
