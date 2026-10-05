import 'time_phrase.dart';

// The local grammar (docs/05 §9.8). Most daily requests come in a handful
// of shapes; parsing them on the phone makes them instant, free, offline
// and private. Each match becomes the same tool call a model would make,
// with the same argument names, so it goes through the same validation
// and policy. Anything else returns null and goes to the model.

/// A tool call the grammar recognised.
final class LocalCall {
  const LocalCall(this.tool, this.args);
  final String tool;
  final Map<String, Object?> args;

  @override
  String toString() => 'LocalCall($tool, $args)';
}

/// Local date-time as ISO 8601 without a zone ("2026-10-05T19:00"): the
/// format tool arguments use (the model is told the same).
String isoLocal(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${_pad2(t.month)}-${_pad2(t.day)}'
    'T${_pad2(t.hour)}:${_pad2(t.minute)}';

/// Local date as ISO 8601 ("2026-10-05").
String isoDate(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${_pad2(t.month)}-${_pad2(t.day)}';

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Parses [text] into one tool call, or null when it isn't one of the
/// known shapes (the model takes it from there).
LocalCall? quickParse(
  String text, {
  required DateTime now,
  DayParts parts = const DayParts(),
}) {
  final input = text.trim().replaceAll(RegExp(r'[.!?]+$'), '').trim();
  if (input.isEmpty) return null;
  for (final rule in _rules) {
    final call = rule(input, now, parts);
    if (call != null) return call;
  }
  return null;
}

typedef _Rule = LocalCall? Function(String text, DateTime now, DayParts parts);

final _rules = <_Rule>[
  _reminder,
  _agenda,
  _listAdd,
  _focus,
  _complete,
  _expense,
  _remember,
  _callOrMessage,
  _task,
];

// ---- remind me to X at T · X yaad dila(na) · yaad dilana ki X ----------
final _remindEn = RegExp(
    r'^(?:please\s+)?remind\s+me\s+(?:to\s+|about\s+|that\s+)?(.+)$',
    caseSensitive: false);
final _remindHi1 = RegExp(
    r'^(?:mujhe\s+)?yaad\s+dila(?:na|o|dena|de)?(?:\s+(?:dena|do|de))?\s+(?:ki\s+)?(.+)$',
    caseSensitive: false);
final _remindHi2 = RegExp(
    r'^(?:mujhe\s+)?(.+?)\s+(?:ke\s+liye\s+)?yaad\s+dila(?:na|o|dena|de)?$',
    caseSensitive: false);

LocalCall? _reminder(String text, DateTime now, DayParts parts) {
  final m = _remindEn.firstMatch(text) ??
      _remindHi1.firstMatch(text) ??
      _remindHi2.firstMatch(text);
  if (m == null) return null;
  final body = m.group(1)!;
  final when = findTimePhrase(body, now: now, parts: parts);
  if (when == null) return null; // "remind me" needs a time; ask the model
  final at = switch (when.value) {
    AtInstant(:final at) => at,
    // A day without a time: the morning of that day.
    OnDay(:final day) => DateTime(day.year, day.month, day.day, parts.morning),
  };
  final title = _tidyTitle(when.strip(body));
  if (title.isEmpty) return null;
  return LocalCall('create_reminder', {'title': title, 'at': isoLocal(at)});
}

// ---- what's on today / tomorrow / friday · aaj kya hai ------------------
final _agendaEn = RegExp(
    r"^(?:what(?:'s| is)|whats|show(?: me)?|what do i have|anything)\s*"
    r'(?:on\s+|planned\s+|scheduled\s+|for\s+|my\s+)*(?:the\s+)?'
    r'(?:agenda|schedule|plan|day)?\s*(?:for\s+|on\s+)?(.*)$',
    caseSensitive: false);
final _agendaHi = RegExp(r'^(.+?)\s+(?:kya\s+hai|ka\s+plan|ka\s+schedule)$',
    caseSensitive: false);

LocalCall? _agenda(String text, DateTime now, DayParts parts) {
  final m = _agendaHi.firstMatch(text) ?? _agendaEn.firstMatch(text);
  if (m == null) return null;
  final rest = m.group(1)!.trim();
  final DateTime day;
  if (rest.isEmpty || rest == 'today' || rest == 'for today') {
    // "what's on" alone only counts with an agenda word.
    if (rest.isEmpty &&
        !RegExp(r'agenda|schedule|plan', caseSensitive: false).hasMatch(text)) {
      return null;
    }
    day = now;
  } else {
    final when = findTimePhrase(rest, now: now, parts: parts);
    if (when == null || when.strip(rest).isNotEmpty) return null;
    day = switch (when.value) {
      AtInstant(:final at) => at,
      OnDay(:final day) => day,
    };
  }
  return LocalCall('get_agenda', {'day': isoDate(day)});
}

// ---- add milk, eggs and bread to shopping · shopping mein milk daal do --
final _listAddEn = RegExp(
    r'^(?:please\s+)?(?:add|put)\s+(.+?)\s+(?:to|on|in(?:to)?)\s+'
    r'(?:the\s+|my\s+)?(.+?)(?:\s+list)?$',
    caseSensitive: false);
final _listAddHi = RegExp(
    r'^(?:(.+?)\s+list\s+mein|(.+?)\s+mein)\s+(.+?)\s+(?:daal|add\s+kar|likh)\s*(?:do|dena|o|de)?$',
    caseSensitive: false);

LocalCall? _listAdd(String text, DateTime now, DayParts parts) {
  String list;
  String items;
  final en = _listAddEn.firstMatch(text);
  if (en != null) {
    items = en.group(1)!;
    list = en.group(2)!;
    // "add a task to call Mum" and "add 30 min to the timer" are not
    // list items.
    if (RegExp(r'^(?:a\s+)?(?:task|reminder|block|todo)\b',
                caseSensitive: false)
            .hasMatch(items) ||
        RegExp(r'\b(?:timer|calendar|today|tomorrow|schedule)\b',
                caseSensitive: false)
            .hasMatch(list)) {
      return null;
    }
  } else {
    final hi = _listAddHi.firstMatch(text);
    if (hi == null) return null;
    list = (hi.group(1) ?? hi.group(2))!;
    items = hi.group(3)!;
  }
  final split = items
      .split(RegExp(r'\s*(?:,|\band\b|\baur\b|&|\+)\s*', caseSensitive: false))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (split.isEmpty || list.trim().isEmpty) return null;
  return LocalCall(
      'add_list_items', {'list': list.trim().toLowerCase(), 'items': split});
}

// ---- start a focus (session) (for 25 min) (on X) -------------------------
final _focusEn = RegExp(
    r'^(?:start|begin)\s+(?:a\s+)?(?:focus|pomodoro)(?:\s+session)?'
    r'(?:\s+(?:for\s+)?(\d{1,3})\s*(?:minutes?|mins?|m))?'
    r'(?:\s+on\s+(.+))?$',
    caseSensitive: false);
final _focusFor = RegExp(
    r'^focus\s+(?:for\s+)?(\d{1,3})\s*(?:minutes?|mins?|m)(?:\s+on\s+(.+))?$',
    caseSensitive: false);

LocalCall? _focus(String text, DateTime now, DayParts parts) {
  final m = _focusEn.firstMatch(text) ?? _focusFor.firstMatch(text);
  if (m == null) return null;
  final minutes = m.group(1) == null ? null : int.parse(m.group(1)!);
  final on = m.group(2)?.trim();
  return LocalCall('start_focus', {
    if (minutes != null) 'minutes': minutes,
    if (on != null && on.isNotEmpty) 'task': on,
  });
}

// ---- mark X done · done with X · X ho gaya -------------------------------
final _completeEn = RegExp(
    r'^(?:mark\s+(.+?)\s+(?:as\s+)?(?:done|complete(?:d)?|finished)'
    r'|(?:i\s+)?(?:finished|completed|done\s+with)\s+(.+))$',
    caseSensitive: false);
final _completeHi = RegExp(
    r'^(.+?)\s+(?:ho\s+gaya|ho\s+gayi|kar\s+liya|khatam)$',
    caseSensitive: false);

LocalCall? _complete(String text, DateTime now, DayParts parts) {
  final m = _completeEn.firstMatch(text);
  final title = m != null
      ? (m.group(1) ?? m.group(2))
      : _completeHi.firstMatch(text)?.group(1);
  if (title == null) return null;
  final clean = _tidyTitle(title);
  if (clean.isEmpty) return null;
  return LocalCall('complete_task', {'task': clean});
}

// ---- spent 450 on lunch · ₹450 lunch · 450 ka lunch ---------------------
final _amountPart = r'(?:₹|rs\.?\s*|inr\s*)?(\d+(?:[.,]\d{1,2})?)\s*(k)?'
    r'(?:\s*(?:rupees|rs|inr|₹))?';
final _expenseEn = RegExp(
    '^(?:i\\s+)?(?:spent|paid)\\s+$_amountPart\\s+(?:on|for)\\s+(.+)\$',
    caseSensitive: false);
final _expenseHi =
    RegExp('^$_amountPart\\s+ka\\s+(.+)\$', caseSensitive: false);

LocalCall? _expense(String text, DateTime now, DayParts parts) {
  final m = _expenseEn.firstMatch(text) ?? _expenseHi.firstMatch(text);
  if (m == null) return null;
  final value = double.tryParse(m.group(1)!.replaceAll(',', '.'));
  if (value == null) return null;
  final rupees = m.group(2) == null ? value : value * 1000;
  final note = _tidyTitle(m.group(3)!);
  if (note.isEmpty) return null;
  return LocalCall('log_expense', {
    // Minor units (paise): money is never a double past this point.
    'amount_minor': (rupees * 100).round(),
    'currency': 'INR',
    'note': note,
  });
}

// ---- remember (that) X · note: X · yaad rakhna ki X -----------------------
final _rememberEn = RegExp(
    r'^(?:remember|note(?:\s+down)?|make\s+a\s+note)\s*(?:that|:|-)?\s+(.+)$',
    caseSensitive: false);
final _rememberHi =
    RegExp(r'^yaad\s+rakh(?:na|o)?\s+(?:ki\s+)?(.+)$', caseSensitive: false);

LocalCall? _remember(String text, DateTime now, DayParts parts) {
  final m = _rememberEn.firstMatch(text) ?? _rememberHi.firstMatch(text);
  if (m == null) return null;
  final fact = m.group(1)!.trim();
  if (fact.isEmpty) return null;
  return LocalCall('remember', {'fact': fact});
}

// ---- call P · text/message/whatsapp P (saying M) ------------------------
final _call = RegExp(r'^(?:please\s+)?(?:call|phone|ring|dial)\s+(.+)$',
    caseSensitive: false);
final _message = RegExp(
    r'^(?:please\s+)?(text|message|msg|sms|whatsapp|email|mail)\s+(.+?)'
    r'(?:\s+(?:saying|that|to say|ki)\s+(.+))?$',
    caseSensitive: false);

LocalCall? _callOrMessage(String text, DateTime now, DayParts parts) {
  final call = _call.firstMatch(text);
  if (call != null) {
    // "call Mum at 7" is a reminder-ish request; let the model decide. (A
    // time inside a message body is just content.)
    if (findTimePhrase(text, now: now, parts: parts) != null) return null;
    final who = call.group(1)!.trim();
    return who.isEmpty ? null : LocalCall('call', {'person': who});
  }
  final m = _message.firstMatch(text);
  if (m == null) return null;
  final channel = switch (m.group(1)!.toLowerCase()) {
    'whatsapp' => 'whatsapp',
    'email' || 'mail' => 'email',
    _ => 'sms',
  };
  return LocalCall('compose_message', {
    'channel': channel,
    'to': m.group(2)!.trim(),
    if (m.group(3) case final body? when body.trim().isNotEmpty)
      'body': body.trim(),
  });
}

// ---- (add a) task X (by/due T) · todo: X ----------------------------------
final _taskEn = RegExp(
    r'^(?:add\s+(?:a\s+)?(?:new\s+)?task|new\s+task|create\s+(?:a\s+)?task|'
    r'task|todo|to-do)\s*(?::|-|to)?\s+(.+)$',
    caseSensitive: false);

LocalCall? _task(String text, DateTime now, DayParts parts) {
  final m = _taskEn.firstMatch(text);
  if (m == null) return null;
  var body = m.group(1)!;
  DateTime? due;
  final when = findTimePhrase(body, now: now, parts: parts);
  if (when != null) {
    due = switch (when.value) {
      AtInstant(:final at) => at,
      // Due on a day: the end of its working day.
      OnDay(:final day) => DateTime(day.year, day.month, day.day, 17),
    };
    body = when.strip(body).replaceAll(
        RegExp(r'\s+(?:by|due|on|before)$', caseSensitive: false), '');
  }
  final title = _tidyTitle(body);
  if (title.isEmpty) return null;
  return LocalCall('create_task', {
    'title': title,
    if (due != null) 'due': isoLocal(due),
  });
}

/// Trims connecting words left at the edges once a time phrase is out
/// ("call Mum at" → "call Mum"), and a leading "to".
String _tidyTitle(String s) {
  var out = s.trim();
  final edge = RegExp(r'^(?:to|ki|ko)\s+|\s+(?:at|on|by|in|for|due|ko|ki|ke)$',
      caseSensitive: false);
  while (edge.hasMatch(out)) {
    out = out.replaceAll(edge, '').trim();
  }
  return out;
}
