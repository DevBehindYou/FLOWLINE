import 'package:atomic_assist/domain/assistant/redact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = {
    'Call Ravi on +91 98765 43210': 'Call Ravi on [phone]',
    'Call 9876543210 back': 'Call [phone] back',
    'Ring (022) 2345-6789': 'Ring [phone]',
    'Mail priya.s+work@example.co.in the deck': 'Mail [email] the deck',
    'Card 4111 1111 1111 1111 expires': 'Card [card] expires',
    'Card 4111-1111-1111-1111': 'Card [card]',
  };
  for (final MapEntry(:key, :value) in cases.entries) {
    test(key, () => expect(redact(key), value));
  }

  test('dates, times, amounts and short numbers stay', () {
    const keep = [
      'Due 2026-10-05 at 19:00',
      'Pay ₹1,840 by Friday',
      'Room 1204, floor 12',
      'Q3 report v2',
      'Flight AI 101',
    ];
    for (final k in keep) {
      expect(redact(k), k, reason: k);
    }
  });
}
