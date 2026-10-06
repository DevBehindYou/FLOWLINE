import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/services/person_dates.dart';
import 'args.dart';
import 'checks.dart';

// People, dates and follow-ups (docs/05 §13.4, §15). A person is named by
// name: an exact match (ignoring case) wins, then the only name that
// contains it; several matches are ambiguous. Writing tools create the
// person when nobody matches, and undo removes them again.

const _personName = {
  'type': 'string',
  'maxLength': 120,
  'description': 'The person\'s name as the user says it.',
};

/// The person [name] means, null when nobody matches, or an [Invalid]
/// when several do.
Future<({Person? person, Invalid? invalid})> _match(
    ToolEnv env, String name) async {
  final exact = await env.people.findExact(name);
  if (exact != null) return (person: exact, invalid: null);
  final found = await env.people.search(name);
  if (found.isEmpty) return (person: null, invalid: null);
  if (found.length == 1) return (person: found.single, invalid: null);
  final names = [for (final p in found) '${p.id}: ${p.name}'];
  return (
    person: null,
    invalid: Invalid(InvalidReason.ambiguous, names.join('; ')),
  );
}

/// The person for a write: matched, or created now. Returns the undo step
/// for a created one (to run last on undo).
Future<({int id, UndoRecipe? undoCreate})> _personForWrite(
    ToolEnv env, String name) async {
  final m = await _match(env, name);
  if (m.invalid != null) throw StateError('${m.invalid}');
  if (m.person != null) return (id: m.person!.id, undoCreate: null);
  final id = await env.people.createPerson(name);
  return (id: id, undoCreate: DeleteRows(UndoTable.people, [id]));
}

final class GetPersonTool extends AssistantTool<String> {
  const GetPersonTool();

  @override
  String get name => 'get_person';
  @override
  String get description =>
      'A person the user knows: their dates and open follow-ups.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {'name': _personName},
        'required': ['name'],
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  String parse(Map<String, Object?> json) =>
      requireString(json, 'name', maxLength: 120);

  @override
  Future<ToolValidation> validate(String name, ToolEnv env) async {
    final m = await _match(env, name);
    if (m.invalid != null) return m.invalid!;
    return m.person == null
        ? Invalid(InvalidReason.notFound, name)
        : const Valid();
  }

  @override
  Future<ActionPreview> preview(String name, ToolEnv env) async =>
      const ReadPreview(ReadKind.person);

  @override
  Future<ToolOutcome> run(String name, ToolEnv env) async {
    final p = (await _match(env, name)).person!;
    final dates = await env.people.getDates(p.id);
    final open = [
      for (final f in await env.people.getOpenFollowUps())
        if (f.personId == p.id) f,
    ];
    return ToolOutcome(result: {
      'id': p.id,
      'name': p.name,
      if (p.relation != null) 'relation': p.relation,
      'dates': [
        for (final d in dates)
          {
            'kind': d.kind.name,
            'month': d.month,
            'day': d.day,
            'days_until': daysUntil(d, env.now),
          },
      ],
      'open_follow_ups': [
        for (final f in open) {'id': f.id, 'about': f.about},
      ],
    });
  }
}

typedef PersonDateArgs = ({
  String person,
  PersonDateKind kind,
  int month,
  int day,
  int? year,
  String? label,
});

final class AddPersonDateTool extends AssistantTool<PersonDateArgs> {
  const AddPersonDateTool();

  @override
  String get name => 'add_person_date';
  @override
  String get description =>
      'Remembers a birthday, anniversary or other yearly date for a '
      'person (created if new).';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'person': _personName,
          'kind': {
            'type': 'string',
            'enum': ['birthday', 'anniversary', 'other'],
          },
          'month': {'type': 'integer', 'minimum': 1, 'maximum': 12},
          'day': {'type': 'integer', 'minimum': 1, 'maximum': 31},
          'year': {'type': 'integer', 'minimum': 1900, 'maximum': 2100},
          'label': {'type': 'string', 'maxLength': 60},
        },
        'required': ['person', 'month', 'day'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  PersonDateArgs parse(Map<String, Object?> json) => (
        person: requireString(json, 'person', maxLength: 120),
        kind: optionalEnum(json, 'kind', PersonDateKind.values) ??
            PersonDateKind.birthday,
        month: requireInt(json, 'month', min: 1, max: 12),
        day: requireInt(json, 'day', min: 1, max: 31),
        year: optionalInt(json, 'year', min: 1900, max: 2100),
        label: optionalString(json, 'label', maxLength: 60),
      );

  @override
  Future<ToolValidation> validate(PersonDateArgs a, ToolEnv env) async {
    if (!isValidMonthDay(a.month, a.day)) {
      return const Invalid(InvalidReason.outOfRange, 'not a real date');
    }
    final m = await _match(env, a.person);
    return m.invalid ?? const Valid();
  }

  @override
  Future<ActionPreview> preview(PersonDateArgs a, ToolEnv env) async {
    final m = await _match(env, a.person);
    return AddPersonDatePreview(
      person: m.person?.name ?? a.person,
      kind: a.kind,
      month: a.month,
      day: a.day,
      newPerson: m.person == null,
    );
  }

  @override
  Future<ToolOutcome> run(PersonDateArgs a, ToolEnv env) async {
    final p = await _personForWrite(env, a.person);
    final id = await env.people.addDate(
        personId: p.id,
        kind: a.kind,
        month: a.month,
        day: a.day,
        year: a.year,
        label: a.label);
    return ToolOutcome(
      result: {'person_id': p.id, 'date_id': id},
      // Undone in reverse: the date, then the person if this made them.
      undo: UndoAll([
        if (p.undoCreate != null) p.undoCreate!,
        DeleteRows(UndoTable.personDates, [id]),
      ]),
    );
  }
}

typedef FollowUpArgs = ({String person, String about, DateTime waitUntil});

final class CreateFollowUpTool extends AssistantTool<FollowUpArgs> {
  const CreateFollowUpTool();

  @override
  String get name => 'create_follow_up';
  @override
  String get description =>
      'Chase a person about something if they haven\'t replied by a time: '
      'a reminder fires then.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'person': _personName,
          'about': {'type': 'string', 'maxLength': 200},
          'wait_until': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
        },
        'required': ['person', 'about', 'wait_until'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  FollowUpArgs parse(Map<String, Object?> json) => (
        person: requireString(json, 'person', maxLength: 120),
        about: requireString(json, 'about'),
        waitUntil: requireDateTime(json, 'wait_until'),
      );

  @override
  Future<ToolValidation> validate(FollowUpArgs a, ToolEnv env) async {
    if (isPast(a.waitUntil, env.now)) {
      return const Invalid(InvalidReason.inPast, 'wait_until');
    }
    return (await _match(env, a.person)).invalid ?? const Valid();
  }

  @override
  Future<ActionPreview> preview(FollowUpArgs a, ToolEnv env) async =>
      CreateFollowUpPreview(
        person: (await _match(env, a.person)).person?.name ?? a.person,
        about: a.about,
        waitUntil: a.waitUntil,
      );

  @override
  Future<ToolOutcome> run(FollowUpArgs a, ToolEnv env) async {
    final p = await _personForWrite(env, a.person);
    final person = (await env.people.getPerson(p.id))!;
    final reminderId = await env.reminders.create(
      title: '${person.name} · ${a.about}',
      fireAt: a.waitUntil,
      kind: ReminderKind.followUp,
    );
    final id = await env.people.createFollowUp(
        personId: p.id,
        about: a.about,
        waitUntil: a.waitUntil,
        reminderId: reminderId);
    return ToolOutcome(
      result: {'follow_up_id': id, 'reminder_id': reminderId},
      // Undone in reverse: follow-up, its reminder, then a new person.
      undo: UndoAll([
        if (p.undoCreate != null) p.undoCreate!,
        DeleteRows(UndoTable.reminders, [reminderId]),
        DeleteRows(UndoTable.followUps, [id]),
      ]),
      afterCommit: [ReminderTouched(reminderId)],
    );
  }
}

final class CompleteFollowUpTool extends AssistantTool<int> {
  const CompleteFollowUpTool();

  @override
  String get name => 'complete_follow_up';
  @override
  String get description =>
      'Marks an open follow-up done (they replied); its reminder closes.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'follow_up_id': {'type': 'integer'},
        },
        'required': ['follow_up_id'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  int parse(Map<String, Object?> json) =>
      requireInt(json, 'follow_up_id', min: 1, max: 1 << 52);

  Future<FollowUp?> _open(ToolEnv env, int id) async {
    final f = await env.people.getFollowUp(id);
    return f == null || f.status != FollowUpStatus.open ? null : f;
  }

  @override
  Future<ToolValidation> validate(int id, ToolEnv env) async =>
      await _open(env, id) == null
          ? Invalid(InvalidReason.notFound, 'follow_up_id $id')
          : const Valid();

  @override
  Future<ActionPreview> preview(int id, ToolEnv env) async {
    final f = (await _open(env, id))!;
    final p = await env.people.getPerson(f.personId);
    return CompleteFollowUpPreview(person: p?.name ?? '', about: f.about);
  }

  @override
  Future<ToolOutcome> run(int id, ToolEnv env) async {
    final f = (await _open(env, id))!;
    final steps = <UndoRecipe>[];
    final before = await mustRow(env, UndoTable.followUps, id);
    await env.people.setFollowUpStatus(id, FollowUpStatus.replied);
    steps.add(fieldsUndo(UndoTable.followUps, id, before,
        await mustRow(env, UndoTable.followUps, id))!);
    final rid = f.reminderId;
    final effects = <AfterCommit>[];
    if (rid != null && (await env.reminders.get(rid))?.isOpen == true) {
      final rBefore = await mustRow(env, UndoTable.reminders, rid);
      await env.reminders.setStatus(rid, ReminderStatus.done);
      steps.add(fieldsUndo(UndoTable.reminders, rid, rBefore,
          await mustRow(env, UndoTable.reminders, rid))!);
      effects.add(ReminderTouched(rid));
    }
    return ToolOutcome(
      result: {'follow_up_id': id},
      undo: steps.length == 1 ? steps.single : UndoAll(steps),
      afterCommit: effects,
    );
  }
}
