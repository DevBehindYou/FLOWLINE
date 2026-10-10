import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/task.dart';
import 'args.dart';

typedef StartFocusArgs = ({TaskRef? task, int? minutes});

final class StartFocusTool extends AssistantTool<StartFocusArgs> {
  const StartFocusTool();

  @override
  String get name => 'start_focus';
  @override
  String get description =>
      'Starts a focus session now, optionally on a task. Default length '
      'is the user\'s setting.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          ...taskRefProperties,
          'minutes': {'type': 'integer', 'minimum': 5, 'maximum': 180},
        },
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  StartFocusArgs parse(Map<String, Object?> json) => (
        task: json['task_id'] == null && json['task'] == null
            ? null
            : TaskRef.parse(json),
        minutes: optionalInt(json, 'minutes', min: 5, max: 180),
      );

  Future<Task?> _task(StartFocusArgs a, ToolEnv env) async => a.task == null
      ? null
      : switch (await resolveTask(env, a.task!)) {
          Found(:final value) => value,
          NotResolved(:final invalid) => throw StateError('$invalid'),
        };

  @override
  Future<ToolValidation> validate(StartFocusArgs a, ToolEnv env) async {
    if (await env.focus.getActiveSession() != null) {
      return const Invalid(InvalidReason.busy, 'a session is active');
    }
    if (a.task != null) {
      final resolved = await resolveTask(env, a.task!);
      if (resolved case NotResolved(:final invalid)) return invalid;
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(StartFocusArgs a, ToolEnv env) async =>
      StartFocusPreview(
        minutes: a.minutes ?? await env.focusMinutes(),
        taskTitle: (await _task(a, env))?.title,
      );

  @override
  Future<ToolOutcome> run(StartFocusArgs a, ToolEnv env) async {
    final minutes = a.minutes ?? await env.focusMinutes();
    final task = await _task(a, env);
    final id = await env.focus.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: minutes * 60,
      taskId: task?.id,
    );
    return ToolOutcome(
      result: {'session_id': id, 'minutes': minutes},
      undo: StopFocus(id),
      afterCommit: [FocusStarted(id)],
    );
  }
}
