// Redaction (docs/05 §6.4). Before a cloud request, phone numbers, email
// addresses and card-like numbers in the *context* AA adds (task and
// block titles, notes) are replaced with placeholders. What the user
// typed is sent as typed: they chose to say it.

final _email = RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+');

// 13-19 digits, optionally grouped by spaces or dashes: card numbers.
final _card = RegExp(r'\b\d(?:[ -]?\d){12,18}\b');

// A phone number: optional +country or "(area)", then 8-14 digits with
// the usual separators. Times ("19:00") never match (a colon); ISO dates
// have eight digits too and are kept explicitly.
final _phone =
    RegExp(r'(?<![\w(])(?:\+|\()?\d(?:[ ().-]{0,2}\d){7,13}(?![\w])');
final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String redact(String text) => text
    .replaceAll(_email, '[email]')
    .replaceAll(_card, '[card]')
    .replaceAllMapped(
        _phone, (m) => _isoDate.hasMatch(m[0]!) ? m[0]! : '[phone]');
