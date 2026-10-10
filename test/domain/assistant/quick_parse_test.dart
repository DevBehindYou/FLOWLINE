import 'package:atomic_assist/domain/assistant/quick_parse.dart';
import 'package:flutter_test/flutter_test.dart';

// Monday 5 October 2026, 16:40.
final _now = DateTime(2026, 10, 5, 16, 40);

void main() {
  // phrase → (tool, args), or null for "not mine: ask the model".
  final cases = <String, (String, Map<String, Object?>)?>{
    // Reminders, English.
    'remind me to call Mum at 7': (
      'create_reminder',
      {'title': 'call Mum', 'at': '2026-10-05T19:00'}
    ),
    'Remind me to call Mum at 7.': (
      'create_reminder',
      {'title': 'call Mum', 'at': '2026-10-05T19:00'}
    ),
    'remind me to pay rent tomorrow': (
      'create_reminder',
      {'title': 'pay rent', 'at': '2026-10-06T09:00'}
    ),
    'remind me in 20 minutes to stretch': (
      'create_reminder',
      {'title': 'stretch', 'at': '2026-10-05T17:00'}
    ),
    'remind me to stretch in 20 minutes': (
      'create_reminder',
      {'title': 'stretch', 'at': '2026-10-05T17:00'}
    ),
    'remind me about the dentist on friday at 10': (
      'create_reminder',
      {'title': 'the dentist', 'at': '2026-10-09T10:00'}
    ),
    'please remind me to water the plants tonight': (
      'create_reminder',
      {'title': 'water the plants', 'at': '2026-10-05T20:00'}
    ),
    'remind me to send the deck tomorrow morning': (
      'create_reminder',
      {'title': 'send the deck', 'at': '2026-10-06T09:00'}
    ),
    'remind me to book tickets on 20 oct': (
      'create_reminder',
      {'title': 'book tickets', 'at': '2026-10-20T09:00'}
    ),
    'remind me to take medicine at 9pm': (
      'create_reminder',
      {'title': 'take medicine', 'at': '2026-10-05T21:00'}
    ),
    'remind me to leave at 18:30': (
      'create_reminder',
      {'title': 'leave', 'at': '2026-10-05T18:30'}
    ),
    'remind me to call Ravi in 2 hours': (
      'create_reminder',
      {'title': 'call Ravi', 'at': '2026-10-05T18:40'}
    ),
    // Reminders, Hinglish.
    'mujhe yaad dilana ki kal subah gym jaana hai': (
      'create_reminder',
      {'title': 'gym jaana hai', 'at': '2026-10-06T09:00'}
    ),
    'yaad dila dena 5 baje meeting hai': (
      'create_reminder',
      {'title': 'meeting hai', 'at': '2026-10-05T17:00'}
    ),
    'kal subah doodh lena yaad dilana': (
      'create_reminder',
      {'title': 'doodh lena', 'at': '2026-10-06T09:00'}
    ),
    'shaam ko Mummy ko call karna yaad dilana': (
      'create_reminder',
      {'title': 'Mummy ko call karna', 'at': '2026-10-05T18:00'}
    ),
    // A reminder needs a time; without one, the model asks.
    'remind me to call Mum': null,
    'remind me': null,

    // Agenda.
    "what's on today": ('get_agenda', {'day': '2026-10-05'}),
    "what's on tomorrow": ('get_agenda', {'day': '2026-10-06'}),
    'what is on friday': ('get_agenda', {'day': '2026-10-09'}),
    "what's my schedule": ('get_agenda', {'day': '2026-10-05'}),
    'show me the agenda for tomorrow': ('get_agenda', {'day': '2026-10-06'}),
    'what do i have tomorrow': ('get_agenda', {'day': '2026-10-06'}),
    'aaj kya hai': ('get_agenda', {'day': '2026-10-05'}),
    'kal kya hai': ('get_agenda', {'day': '2026-10-06'}),
    "what's the plan for monday": ('get_agenda', {'day': '2026-10-12'}),
    // Not agenda questions.
    "what's the capital of France": null,
    "what's up": null,

    // Lists.
    'add milk to shopping': (
      'add_list_items',
      {
        'list': 'shopping',
        'items': ['milk'],
      }
    ),
    'add milk, eggs and bread to the shopping list': (
      'add_list_items',
      {
        'list': 'shopping',
        'items': ['milk', 'eggs', 'bread'],
      }
    ),
    'put batteries on my errands list': (
      'add_list_items',
      {
        'list': 'errands',
        'items': ['batteries'],
      }
    ),
    'add charger & passport to packing': (
      'add_list_items',
      {
        'list': 'packing',
        'items': ['charger', 'passport'],
      }
    ),
    'shopping list mein doodh aur anda daal do': (
      'add_list_items',
      {
        'list': 'shopping',
        'items': ['doodh', 'anda'],
      }
    ),
    'shopping mein atta daal do': (
      'add_list_items',
      {
        'list': 'shopping',
        'items': ['atta'],
      }
    ),
    // Not list items (a task, a timer, a calendar).
    'add a task to call Mum': ('create_task', {'title': 'call Mum'}),
    'add 30 minutes to the timer': null,
    'add standup to my calendar': null,

    // Focus.
    'start focus': ('start_focus', <String, Object?>{}),
    'start a focus session': ('start_focus', <String, Object?>{}),
    'start a pomodoro': ('start_focus', <String, Object?>{}),
    'start focus for 50 minutes': ('start_focus', {'minutes': 50}),
    'start a focus session for 25 min on the report': (
      'start_focus',
      {'minutes': 25, 'task': 'the report'}
    ),
    'focus for 45 minutes': ('start_focus', {'minutes': 45}),
    'focus for 30m on taxes': ('start_focus', {'minutes': 30, 'task': 'taxes'}),
    'begin focus on email': ('start_focus', {'task': 'email'}),

    // Completing tasks.
    'mark write report as done': ('complete_task', {'task': 'write report'}),
    'mark the invoice done': ('complete_task', {'task': 'the invoice'}),
    'done with laundry': ('complete_task', {'task': 'laundry'}),
    'i finished the slides': ('complete_task', {'task': 'the slides'}),
    'completed tax filing': ('complete_task', {'task': 'tax filing'}),
    'report ho gaya': ('complete_task', {'task': 'report'}),
    'laundry kar liya': ('complete_task', {'task': 'laundry'}),

    // Expenses (amounts in paise).
    'spent 450 on lunch': (
      'log_expense',
      {'amount_minor': 45000, 'currency': 'INR', 'note': 'lunch'}
    ),
    'spent ₹1200 on groceries': (
      'log_expense',
      {'amount_minor': 120000, 'currency': 'INR', 'note': 'groceries'}
    ),
    'paid rs 99.50 for parking': (
      'log_expense',
      {'amount_minor': 9950, 'currency': 'INR', 'note': 'parking'}
    ),
    'spent 2k on shoes': (
      'log_expense',
      {'amount_minor': 200000, 'currency': 'INR', 'note': 'shoes'}
    ),
    'i spent 300 rupees on a cab': (
      'log_expense',
      {'amount_minor': 30000, 'currency': 'INR', 'note': 'a cab'}
    ),
    '450 ka lunch': (
      'log_expense',
      {'amount_minor': 45000, 'currency': 'INR', 'note': 'lunch'}
    ),

    // Memory.
    'remember that Priya is vegetarian': (
      'remember',
      {'fact': 'Priya is vegetarian'}
    ),
    'remember the wifi password is on the fridge': (
      'remember',
      {'fact': 'the wifi password is on the fridge'}
    ),
    'note: car service due in March': (
      'remember',
      {'fact': 'car service due in March'}
    ),
    'note down Ravi likes filter coffee': (
      'remember',
      {'fact': 'Ravi likes filter coffee'}
    ),
    'yaad rakhna ki Anu ka birthday 12 Nov hai': (
      'remember',
      {'fact': 'Anu ka birthday 12 Nov hai'}
    ),

    // Calls and messages (hand-offs).
    'call Mum': ('call', {'person': 'Mum'}),
    'please call the plumber': ('call', {'person': 'the plumber'}),
    'text Priya saying running 10 minutes late': (
      'compose_message',
      {'channel': 'sms', 'to': 'Priya', 'body': 'running 10 minutes late'}
    ),
    'whatsapp Ravi that the meeting moved': (
      'compose_message',
      {'channel': 'whatsapp', 'to': 'Ravi', 'body': 'the meeting moved'}
    ),
    'message Anu': ('compose_message', {'channel': 'sms', 'to': 'Anu'}),
    'email Sam saying deck attached': (
      'compose_message',
      {'channel': 'email', 'to': 'Sam', 'body': 'deck attached'}
    ),
    // "call X at 7" is ambiguous (now? a reminder?): the model decides.
    'call Mum at 7': null,

    // Tasks.
    'add a task to call the bank': ('create_task', {'title': 'call the bank'}),
    'task: renew passport': ('create_task', {'title': 'renew passport'}),
    'todo buy a birthday gift': (
      'create_task',
      {'title': 'buy a birthday gift'}
    ),
    'new task send invoice by friday': (
      'create_task',
      {'title': 'send invoice', 'due': '2026-10-09T17:00'}
    ),
    'add task submit report tomorrow at 3': (
      'create_task',
      {'title': 'submit report', 'due': '2026-10-06T15:00'}
    ),
    'create a task to file taxes due 20 oct': (
      'create_task',
      {'title': 'file taxes', 'due': '2026-10-20T17:00'}
    ),

    // Not ours: the model answers.
    'how do I make chai': null,
    'plan my week': null,
    'move standup to 11': null,
    'hello': null,
    '': null,
    '   ': null,
  };

  for (final MapEntry(key: phrase, value: expected) in cases.entries) {
    test('"$phrase"', () {
      final call = quickParse(phrase, now: _now);
      if (expected == null) {
        expect(call, isNull, reason: 'got $call');
      } else {
        expect(call?.tool, expected.$1);
        expect(call?.args, expected.$2);
      }
    });
  }

  test('at least 150 phrases are covered with the time-phrase table', () {
    // time_phrase_test has ~70; this table the rest.
    expect(cases.length, greaterThanOrEqualTo(80));
  });

  test('ISO formatting pads every field', () {
    expect(isoLocal(DateTime(2026, 1, 2, 3, 4)), '2026-01-02T03:04');
    expect(isoDate(DateTime(2026, 1, 2)), '2026-01-02');
  });
}
