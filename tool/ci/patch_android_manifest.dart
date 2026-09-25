// Applies Flowline's Android manifest requirements on top of the
// `flutter create` template, which CI regenerates from scratch on every
// run (android/ is gitignored deliberately — see README "Before you
// build"). Idempotent: safe to run more than once against the same file.
//
// Usage: dart run tool/ci/patch_android_manifest.dart <path-to-AndroidManifest.xml>
import 'dart:io';

const _permissions = <String>[
  // Release builds don't get this for free the way debug/profile do —
  // flutter create only adds INTERNET to android/app/src/{debug,profile}
  // /AndroidManifest.xml, not to main/. Every AI provider call (Anthropic,
  // OpenAI, Gemini, Ollama) goes over HTTP(S), so without this a release
  // APK builds fine and then silently fails every network request.
  'android.permission.INTERNET',
  // Documented in README "Before you build" step 3 — required for the
  // focus/break session-complete notification (Android 13+/API 33+).
  'android.permission.POST_NOTIFICATIONS',
];

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/ci/patch_android_manifest.dart <AndroidManifest.xml path>');
    exit(64);
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('AndroidManifest.xml not found at ${args.first}');
    exit(1);
  }

  var contents = file.readAsStringSync();

  for (final permission in _permissions) {
    final tag = '<uses-permission android:name="$permission"/>';
    if (contents.contains('android:name="$permission"')) {
      stdout.writeln('Skipping $permission — already present.');
      continue;
    }
    if (!contents.contains('</manifest>')) {
      stderr.writeln('Could not find </manifest> closing tag to insert $permission before.');
      exit(1);
    }
    contents = contents.replaceFirst('</manifest>', '    $tag\n</manifest>');
    stdout.writeln('Added $permission');
  }

  // Ollama's local/LAN server is plain HTTP; Android 9+ blocks cleartext
  // traffic by default. Documented in README "Before you build" step 4 —
  // a blanket allow, since Android's manifest XML can't scope this to
  // private-IP ranges the way a network-security-config could.
  const cleartextAttr = 'android:usesCleartextTraffic="true"';
  if (contents.contains('usesCleartextTraffic')) {
    stdout.writeln('Skipping usesCleartextTraffic — already present.');
  } else {
    final applicationTagMatch = RegExp(r'<application\b').firstMatch(contents);
    if (applicationTagMatch == null) {
      stderr.writeln('Could not find <application> tag to add $cleartextAttr to.');
      exit(1);
    }
    final insertAt = applicationTagMatch.end;
    contents = contents.replaceRange(insertAt, insertAt, '\n        $cleartextAttr');
    stdout.writeln('Added usesCleartextTraffic="true" to <application>.');
  }

  file.writeAsStringSync(contents);
  stdout.writeln('Patched ${file.path}');
}
