import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/features/ai_assistant/widgets/chat_bubble.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const anthropic = AIProviderConfig(
    id: AIProviderId.anthropic,
    displayName: 'Anthropic',
    defaultModel: 'm',
    isActive: true,
  );
  const ollama = AIProviderConfig(
    id: AIProviderId.ollama,
    displayName: 'Ollama (Local)',
    defaultModel: 'llama3.2',
    baseUrl: 'http://192.168.1.20:11434',
    isActive: true,
  );

  Future<void> pump(
      WidgetTester tester, AIMessage message, AIProviderConfig provider) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: ChatBubble(message: message, provider: provider)),
    ));
  }

  AIMessage error({AIFailure? failure, String content = ''}) => AIMessage(
        id: 1,
        conversationId: 1,
        role: AIMessageRole.assistant,
        content: content,
        isError: true,
        failure: failure,
        sentAt: DateTime(2026),
      );

  testWidgets('words a typed failure with the vendor name', (tester) async {
    await pump(
        tester,
        error(failure: const AIFailure(AIFailureKind.invalidKey, status: 401)),
        anthropic);
    expect(
        find.text('That API key was rejected by Anthropic.'), findsOneWidget);
  });

  testWidgets('explains localhost when Ollama is unreachable', (tester) async {
    await pump(tester,
        error(failure: const AIFailure(AIFailureKind.unreachable)), ollama);
    expect(find.textContaining('192.168.1.20'), findsOneWidget);
    expect(find.textContaining('localhost means the phone itself'),
        findsOneWidget);
  });

  testWidgets('shows the stored text of an error from before schema v7',
      (tester) async {
    await pump(
        tester, error(content: 'Ollama returned an error (HTTP 500).'), ollama);
    expect(find.text('Ollama returned an error (HTTP 500).'), findsOneWidget);
  });
}
