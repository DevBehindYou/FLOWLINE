// Pure string patches applied to the `flutter create` Android template,
// which CI regenerates on every run (android/ is gitignored on purpose).
// Kept free of dart:io so test/tool/android_patches_test.dart can run
// them against the real template text. Every patch is idempotent and
// throws [AndroidPatchException] when its anchor is missing, so a
// template change on a Flutter bump fails loudly instead of shipping an
// APK without them.

class AndroidPatchException implements Exception {
  AndroidPatchException(this.message);
  final String message;

  @override
  String toString() => 'AndroidPatchException: $message';
}

const manifestPermissions = <String>[
  // flutter create only adds INTERNET to the debug/profile manifests, so
  // without this every AI-provider request fails in a release build.
  'android.permission.INTERNET',
  // Runtime notification permission on Android 13+ (focus/break end).
  'android.permission.POST_NOTIFICATIONS',
  // flutter_local_notifications >= 16 no longer declares this itself; it
  // lets the plugin restore a pending session-end alert after a reboot.
  'android.permission.RECEIVE_BOOT_COMPLETED',
];

// flutter_local_notifications >= 16 requires the app to register these
// for zonedSchedule(); without ScheduledNotificationReceiver the alarm
// fires but the notification is never shown.
const scheduledNotificationReceivers = '''
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
''';

const desugarJdkLibs = 'com.android.tools:desugar_jdk_libs:2.1.4';

String patchManifest(String manifest) {
  var out = manifest;

  for (final permission in manifestPermissions) {
    if (out.contains('android:name="$permission"')) continue;
    out = _insertBefore(
      out,
      '</manifest>',
      '    <uses-permission android:name="$permission"/>\n',
    );
  }

  // Ollama's local/LAN server is plain HTTP, which Android 9+ blocks by
  // default. Blanket allow: manifest XML can't scope it to private IPs.
  if (!out.contains('usesCleartextTraffic')) {
    final match = RegExp(r'<application\b').firstMatch(out);
    if (match == null) {
      throw AndroidPatchException('No <application> tag in AndroidManifest.xml');
    }
    out = out.replaceRange(
      match.end,
      match.end,
      '\n        android:usesCleartextTraffic="true"',
    );
  }

  if (!out.contains('ScheduledNotificationReceiver')) {
    out = _insertBefore(out, '</application>', scheduledNotificationReceivers);
  }

  return out;
}

/// flutter_local_notifications is built with core library desugaring, and
/// AGP refuses to build an app that depends on it without the same.
String patchAppGradleKts(String gradle) {
  var out = gradle;

  if (!out.contains('isCoreLibraryDesugaringEnabled')) {
    out = _insertAfter(
      out,
      'compileOptions {\n',
      '        isCoreLibraryDesugaringEnabled = true\n',
    );
  }

  if (!out.contains('desugar_jdk_libs')) {
    out = '${out.trimRight()}\n\n'
        'dependencies {\n'
        '    coreLibraryDesugaring("$desugarJdkLibs")\n'
        '}\n';
  }

  return out;
}

String _insertBefore(String source, String anchor, String insertion) {
  final index = source.lastIndexOf(anchor);
  if (index < 0) throw AndroidPatchException('Anchor "$anchor" not found');
  return source.replaceRange(index, index, insertion);
}

String _insertAfter(String source, String anchor, String insertion) {
  final index = source.indexOf(anchor);
  if (index < 0) throw AndroidPatchException('Anchor "$anchor" not found');
  final end = index + anchor.length;
  return source.replaceRange(end, end, insertion);
}
