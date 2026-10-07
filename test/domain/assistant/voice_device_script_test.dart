import 'package:atomic_assist/domain/assistant/quick_parse.dart';
import 'package:flutter_test/flutter_test.dart';

/// docs/voice-device-check.md: the owner's 20 spoken commands. The
/// recogniser hands over plain lower-case text, often without
/// punctuation; every command that should work offline must parse to the
/// tool the script expects, so the device check measures recognition,
/// not a grammar gap.
void main() {
  // Monday 5 October 2026, 16:40.
  final now = DateTime(2026, 10, 5, 16, 40);

  const script = <String, String?>{
    'remind me to call mum at 7': 'create_reminder',
    'remind me to stretch in 20 minutes': 'create_reminder',
    'remind me to pay rent tomorrow': 'create_reminder',
    'remind me about the dentist on friday at 10': 'create_reminder',
    'remind me to take medicine at 9 pm': 'create_reminder',
    'yaad dila dena 5 baje meeting hai': 'create_reminder',
    'add milk to shopping': 'add_list_items',
    'add milk eggs and bread to the shopping list': 'add_list_items',
    'put batteries on my errands list': 'add_list_items',
    'add charger and passport to packing': 'add_list_items',
    'shopping list mein doodh aur anda daal do': 'add_list_items',
    'add a task to call the bank': 'create_task',
    'add task submit report tomorrow at 3': 'create_task',
    'new task send invoice by friday': 'create_task',
    'start focus for 25 minutes on write report': 'start_focus',
    'mark write report as done': 'complete_task',
    'done with laundry': 'complete_task',
    // A read: in the chat it goes to the model.
    'what do i have tomorrow': 'get_agenda',
    'start a pomodoro': 'start_focus',
    'remind me to water the plants tonight': 'create_reminder',
  };

  test('the script has 20 commands', () => expect(script, hasLength(20)));

  for (final MapEntry(key: said, value: tool) in script.entries) {
    test(said, () {
      expect(quickParse(said, now: now)?.tool, tool);
    });
  }
}
