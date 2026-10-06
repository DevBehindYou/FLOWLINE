import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/schedule_block.dart';
import 'args.dart';
import 'checks.dart';

typedef TimeRangeArgs = ({String title, DateTime start, DateTime end});

const _localDateTime = {
  'type': 'string',
  'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
};

final class CreateBlockTool extends AssistantTool<TimeRangeArgs> {
  const CreateBlockTool();

  @override
  String get name => 'create_block';
  @override
  String get description =>
      'Adds a time block to the schedule. The time must be free.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'title': {'type': 'string', 'maxLength': 200},
          'start': _localDateTime,
          'end': _localDateTime,
        },
        'required': ['title', 'start', 'end'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  TimeRangeArgs parse(Map<String, Object?> json) => (
        title: requireString(json, 'title'),
        start: requireDateTime(json, 'start'),
        end: requireDateTime(json, 'end'),
      );

  @override
  Future<ToolValidation> validate(TimeRangeArgs a, ToolEnv env) async =>
      await checkTimeRange(env, a.start, a.end) ?? const Valid();

  @override
  Future<ActionPreview> preview(TimeRangeArgs a, ToolEnv env) async =>
      CreateBlockPreview(title: a.title, start: a.start, end: a.end);

  @override
  Future<ToolOutcome> run(TimeRangeArgs a, ToolEnv env) async {
    final id = await env.schedule
        .createBlock(title: a.title, startTime: a.start, endTime: a.end);
    return ToolOutcome(
      result: {'block_id': id},
      undo: DeleteRows(UndoTable.scheduleBlocks, [id]),
    );
  }
}

typedef MoveBlockArgs = ({int blockId, DateTime start, DateTime end});

/// Why [block] can't be changed by a tool, or null.
Invalid? notMovable(ScheduleBlock? block, int id) {
  if (block == null) return Invalid(InvalidReason.notFound, 'block_id $id');
  // Phone-calendar events are read-only; a series template would move
  // every day at once, which is never what "move X to 7" means.
  if (block.isLocked) {
    return const Invalid(InvalidReason.notSupported, 'locked');
  }
  if (block.recurrence != null && !block.isOccurrence) {
    return const Invalid(InvalidReason.notSupported, 'series');
  }
  return null;
}

final class MoveBlockTool extends AssistantTool<MoveBlockArgs> {
  const MoveBlockTool();

  @override
  String get name => 'move_block';
  @override
  String get description =>
      'Moves one block (or one day of a repeating block) to a new time. '
      'Use the block id from get_agenda.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'block_id': {'type': 'integer'},
          'start': _localDateTime,
          'end': _localDateTime,
        },
        'required': ['block_id', 'start', 'end'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  MoveBlockArgs parse(Map<String, Object?> json) => (
        // Negative ids are computed occurrences of a series.
        blockId: requireInt(json, 'block_id', min: -(1 << 52), max: 1 << 52),
        start: requireDateTime(json, 'start'),
        end: requireDateTime(json, 'end'),
      );

  @override
  Future<ToolValidation> validate(MoveBlockArgs a, ToolEnv env) async {
    final block = await findBlock(env, a.blockId);
    final problem = notMovable(block, a.blockId);
    if (problem != null) return problem;
    if (a.start == block!.startTime && a.end == block.endTime) {
      return const Invalid(InvalidReason.nothingToChange);
    }
    return await checkTimeRange(env, a.start, a.end,
            excludeBlockId: a.blockId) ??
        const Valid();
  }

  @override
  Future<ActionPreview> preview(MoveBlockArgs a, ToolEnv env) async {
    final block = (await findBlock(env, a.blockId))!;
    return MoveBlockPreview(
      title: block.title,
      fromStart: block.startTime,
      fromEnd: block.endTime,
      toStart: a.start,
      toEnd: a.end,
    );
  }

  @override
  Future<ToolOutcome> run(MoveBlockArgs a, ToolEnv env) async {
    final block = (await findBlock(env, a.blockId))!;
    final moved = block.copyWith(startTime: a.start, endTime: a.end);
    if (block.isComputedOccurrence) {
      // Storing the occurrence is what moves it; deleting the stored row
      // brings the computed one back exactly.
      final storedId = await env.schedule.storeOccurrence(block.id);
      await env.schedule.updateBlock(moved);
      return ToolOutcome(
        result: {'block_id': storedId},
        undo: DeleteRows(UndoTable.scheduleBlocks, [storedId]),
      );
    }
    final before = await mustRow(env, UndoTable.scheduleBlocks, block.id);
    await env.schedule.updateBlock(moved);
    final after = await mustRow(env, UndoTable.scheduleBlocks, block.id);
    return ToolOutcome(
      result: {'block_id': block.id},
      undo: fieldsUndo(UndoTable.scheduleBlocks, block.id, before, after),
    );
  }
}
