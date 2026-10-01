// Typed, never-throwing reads of a decoded JSON response. Vendors change
// response shapes, and a malformed or unexpected body must become a
// "returned an empty response" message, not a TypeError from a blind cast.

Map<String, Object?>? jsonMap(Object? value) =>
    value is Map ? value.cast<String, Object?>() : null;

List<Object?> jsonList(Object? value) =>
    value is List ? value.cast<Object?>() : const [];

String? jsonString(Object? value) => value is String ? value : null;
