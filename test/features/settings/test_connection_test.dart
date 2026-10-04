import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/ai_repository_impl.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/repositories/ai_client.dart';
import 'package:atomic_assist/features/settings/view/add_edit_ai_provider_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

class _Keys implements SecureKeyStore {
  final keys = <AIProviderId, String>{};
  @override
  Future<String?> getKey(AIProviderId id) async => keys[id];
  @override
  Future<void> setKey(AIProviderId id, String value) async => keys[id] = value;
  @override
  Future<void> deleteKey(AIProviderId id) async => keys.remove(id);
}

class _ModelsClient implements AIClient {
  _ModelsClient(this.id);

  @override
  final AIProviderId id;
  AIFailure? failWith;
  final asked = <({String apiKey, String? baseUrl})>[];

  @override
  Future<List<AIModelInfo>> listModels(
      AIProviderConfig config, String apiKey) async {
    asked.add((apiKey: apiKey, baseUrl: config.baseUrl));
    if (failWith != null) throw AIFailureException(failWith!);
    return const [
      AIModelInfo('gpt-a', displayName: 'GPT A'),
      AIModelInfo('gpt-b'),
    ];
  }

  @override
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel}) =>
      const Stream.empty();
}

void main() {
  late AppDatabase db;
  late _Keys keys;
  late _ModelsClient openai;
  late _ModelsClient ollama;
  late AIRepositoryImpl repo;
  setUp(() {
    db = createTestDatabase();
    keys = _Keys();
    openai = _ModelsClient(AIProviderId.openai);
    ollama = _ModelsClient(AIProviderId.ollama);
    repo = AIRepositoryImpl(
        db, keys, {AIProviderId.openai: openai, AIProviderId.ollama: ollama});
  });
  tearDown(() => db.close());

  group('repository listModels', () {
    test('uses the typed key over the saved one', () async {
      keys.keys[AIProviderId.openai] = 'saved';
      await repo.listModels(id: AIProviderId.openai, apiKey: 'typed');
      await repo.listModels(id: AIProviderId.openai);
      expect(openai.asked.map((a) => a.apiKey), ['typed', 'saved']);
    });

    test('without any key, fails with missingKey and asks nobody', () async {
      await expectLater(
        repo.listModels(id: AIProviderId.openai),
        throwsA(isA<AIFailureException>()
            .having((e) => e.failure.kind, 'kind', AIFailureKind.missingKey)),
      );
      expect(openai.asked, isEmpty);
    });

    test('tries the typed Ollama address before it is saved', () async {
      await repo.listModels(
          id: AIProviderId.ollama, baseUrl: 'http://192.168.1.20:11434');
      expect(ollama.asked.single.baseUrl, 'http://192.168.1.20:11434');
    });
  });

  group('Test connection in the provider sheet', () {
    const config = AIProviderConfig(
      id: AIProviderId.openai,
      displayName: 'OpenAI',
      defaultModel: 'gpt-old',
      isActive: false,
    );

    Future<void> pumpSheet(WidgetTester tester) async {
      await tester.runAsync(() => repo.watchProviders().first);
      await pumpScreen(
        tester,
        db: db,
        child: const Scaffold(body: AddEditAiProviderSheet(config: config)),
        extraOverrides: [
          secureKeyStoreProvider.overrideWith((ref) => keys),
          aiRepositoryProvider.overrideWith((ref) => repo),
        ],
      );
    }

    Future<void> testConnection(WidgetTester tester) async {
      await tester.enterText(
          find.widgetWithText(TextFormField, 'API key'), 'sk-typed');
      await tester.tap(find.text('Test connection'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the models and lets the user pick one (R21, K6)',
        (tester) async {
      await pumpSheet(tester);
      await testConnection(tester);

      expect(find.text('Connected — 2 models available.'), findsOneWidget);
      // The saved model isn't offered by this key: likely retired.
      expect(find.textContaining('may be retired'), findsOneWidget);

      await tester.tap(find.byTooltip('Choose a model'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GPT A'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'gpt-a'), findsOneWidget);
      expect(find.textContaining('may be retired'), findsNothing);
    });

    testWidgets('a rejected key says so, naming the vendor', (tester) async {
      openai.failWith = const AIFailure(AIFailureKind.invalidKey, status: 401);
      await pumpSheet(tester);
      await testConnection(tester);
      expect(find.text('That API key was rejected by OpenAI.'), findsOneWidget);
    });
  });
}
