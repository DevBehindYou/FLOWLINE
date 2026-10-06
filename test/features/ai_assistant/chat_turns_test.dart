import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/ai_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/repositories/ai_client.dart';
import 'package:atomic_assist/features/ai_assistant/view/assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

/// Plays queued event streams; records what each request carried.
class _Scripted implements AIClient {
  final queue = <List<AIEvent>>[];
  final requests = <AIRequest>[];

  @override
  AIProviderId get id => AIProviderId.ollama;

  @override
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel}) {
    requests.add(request);
    return Stream.fromIterable(queue.isEmpty
        ? [const AITextDelta('ok'), const AIDone()]
        : queue.removeAt(0));
  }

  @override
  Future<List<AIModelInfo>> listModels(
          AIProviderConfig config, String apiKey) async =>
      const [];
}

class _NoKeys implements SecureKeyStore {
  @override
  Future<String?> getKey(AIProviderId id) async => null;
  @override
  Future<void> setKey(AIProviderId id, String value) async {}
  @override
  Future<void> deleteKey(AIProviderId id) async {}
}

void main() {
  late AppDatabase db;
  late _Scripted client;
  late AIRepositoryImpl ai;
  late TaskRepositoryImpl tasks;

  setUp(() {
    db = createTestDatabase();
    client = _Scripted();
    tasks = TaskRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester) async {
    // Built inside the test's zone: a repository made in setUp starts its
    // seeding outside the widget tester's clock and the screen never
    // settles.
    ai = AIRepositoryImpl(db, _NoKeys(), {AIProviderId.ollama: client});
    await tester.runAsync(() => ai.setActiveProvider(AIProviderId.ollama));
    await pumpScreen(tester,
        db: db,
        child: const AssistantScreen(),
        extraOverrides: [aiRepositoryProvider.overrideWith((ref) => ai)]);
  }

  /// Lets work that needs real async turns (the model client's streams,
  /// database writes after them) finish between frames.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> say(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester);
  }

  testWidgets('a typed request acts, shows what it did, and UNDO reverts it',
      (tester) async {
    await open(tester);
    await say(tester, 'add a task buy milk');

    // The local grammar did it: no model call, a card with the words.
    expect(client.requests, isEmpty);
    expect(find.text('CREATED TASK'), findsOneWidget);
    expect(find.text('buy milk'), findsOneWidget);
    expect(await tester.runAsync(() => tasks.findTasks('milk')), hasLength(1));

    await tester.tap(find.widgetWithText(AtomicButton, 'UNDO'));
    await settle(tester);
    expect(find.text('UNDONE'), findsOneWidget);
    expect(find.widgetWithText(AtomicButton, 'UNDO'), findsNothing);
    expect(await tester.runAsync(() => tasks.findTasks('milk')), isEmpty);
  });

  testWidgets('a delete waits for the confirm sheet', (tester) async {
    final id = (await tester.runAsync(() =>
        tasks.createTask(title: 'Old idea', priority: TaskPriority.low)))!;
    client.queue.add([
      AIToolCall(
          id: 'd1', name: 'delete_task', argumentsJson: '{"task_id": $id}'),
      const AIDone(stopReason: AIStopReason.toolUse),
    ]);
    await open(tester);
    await say(tester, 'get rid of the old idea');

    expect(find.text('"Old idea" will be deleted. You can undo this.'),
        findsOneWidget);
    expect(await tester.runAsync(() => tasks.getTask(id)), isNotNull);

    await tester.tap(find.widgetWithText(AtomicButton, 'Do it'));
    await settle(tester);
    expect(await tester.runAsync(() => tasks.getTask(id)), isNull);
    expect(find.text('DELETED TASK'), findsOneWidget);
    expect(find.text('Old idea'), findsOneWidget);
  });

  testWidgets('cancelling the confirm sheet deletes nothing', (tester) async {
    final id = (await tester.runAsync(
        () => tasks.createTask(title: 'Keep me', priority: TaskPriority.low)))!;
    client.queue.add([
      AIToolCall(
          id: 'd1', name: 'delete_task', argumentsJson: '{"task_id": $id}'),
      const AIDone(stopReason: AIStopReason.toolUse),
    ]);
    await open(tester);
    await say(tester, 'delete keep me');
    await tester.tap(find.widgetWithText(AtomicButton, 'Cancel'));
    await settle(tester);
    expect(await tester.runAsync(() => tasks.getTask(id)), isNotNull);
  });

  testWidgets('a plain question gets the model text, history included',
      (tester) async {
    client.queue
      ..add([const AITextDelta('Hello!'), const AIDone()])
      ..add([const AITextDelta('Still here.'), const AIDone()]);
    await open(tester);
    await say(tester, 'hi there');
    expect(find.text('Hello!'), findsOneWidget);
    await say(tester, 'are you still there');
    expect(find.text('Still here.'), findsOneWidget);
    // The second turn carried the first exchange as history.
    expect(client.requests.last.history.map((m) => m.content),
        ['hi there', 'Hello!']);
  });
}
