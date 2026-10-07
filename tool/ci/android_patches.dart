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
  // Push-to-talk (docs/05 §22.1): asked for at runtime on the first tap.
  'android.permission.RECORD_AUDIO',
];

// Android 11+ package visibility: without these, speech_to_text finds no
// recogniser and flutter_tts no voice, and both fail silently.
const voiceQueries = '''
        <intent>
            <action android:name="android.speech.RecognitionService"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE"/>
        </intent>
''';

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

// App identity. `flutter create` derives both from the pubspec name
// (atomic_assist): label "atomic_assist", id com.devbehindyou.atomic_assist.
// The store id is the conventional no-underscore form; it is permanent
// once published, and a different id is a different app with its own
// (empty) storage. The Kotlin namespace stays as generated: Android allows
// the namespace and the application id to differ.
const appLabel = 'Atomic Assist';
const applicationId = 'com.devbehindyou.atomicassist';

const desugarJdkLibs = 'com.android.tools:desugar_jdk_libs:2.1.4';

// Android Auto Backup copies app data to the user's Google account and
// restores it on a new phone. The database should travel (in a local-first
// app it's the only copy of the user's data); flutter_secure_storage's
// preferences must not: they're encrypted with a Keystore key that never
// leaves the device, so a restored copy can't be decrypted and the plugin
// throws on read. Excluding only these files keeps everything else in the
// default backup set.
const secureStoragePrefsFiles = [
  'FlutterSecureStorage.xml',
  'FlutterSecureKeyStorage.xml',
  // flutter_secure_storage 10.x records its cipher configuration here.
  'FlutterSecureStorageConfiguration.xml',
];

String _excludeLines(String indent) => secureStoragePrefsFiles
    .map((f) => '$indent<exclude domain="sharedpref" path="$f"/>')
    .join('\n');

/// Android <= 11 (`android:fullBackupContent`).
String get backupRulesXml => '<?xml version="1.0" encoding="utf-8"?>\n'
    '<full-backup-content>\n'
    '${_excludeLines('    ')}\n'
    '</full-backup-content>\n';

/// Android 12+ (`android:dataExtractionRules`).
String get dataExtractionRulesXml => '<?xml version="1.0" encoding="utf-8"?>\n'
    '<data-extraction-rules>\n'
    '    <cloud-backup>\n'
    '${_excludeLines('        ')}\n'
    '    </cloud-backup>\n'
    '    <device-transfer>\n'
    '${_excludeLines('        ')}\n'
    '    </device-transfer>\n'
    '</data-extraction-rules>\n';

/// Resource files the manifest's backup attributes point at, keyed by
/// path relative to the android/ directory.
Map<String, String> get backupResourceFiles => {
      'app/src/main/res/xml/atomic_backup_rules.xml': backupRulesXml,
      'app/src/main/res/xml/atomic_data_extraction_rules.xml':
          dataExtractionRulesXml,
    };

// Launch screen. The template's splash is a white window (black at
// night) and Android 12+ draws the launcher icon on that. These files
// replace it with the app's own surface colours, so the native splash,
// the first Flutter frame and the first screen are one continuous colour
// (spec §5.1). They are whole files the app owns rather than patches,
// so a template change can't silently drop them. Keep the colours equal
// to AtomicTheme's backgrounds (test/tool/android_patches_test.dart checks).
const splashColorLight = '#F4F5F1';
const splashColorDark = '#15171B';

String _colorsXml(String color) => '<?xml version="1.0" encoding="utf-8"?>\n'
    '<resources>\n'
    '    <color name="atomic_splash_background">$color</color>\n'
    '</resources>\n';

const _launchBackgroundXml = '<?xml version="1.0" encoding="utf-8"?>\n'
    '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <item android:drawable="@color/atomic_splash_background" />\n'
    '</layer-list>\n';

/// Android 12+ ignores windowBackground for the launch screen and uses
/// these attributes instead. Only LaunchTheme is redefined: styles resolve
/// by name, so the template's NormalTheme still applies.
String _launchThemeV31(String parent) =>
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<resources>\n'
    '    <style name="LaunchTheme" parent="$parent">\n'
    '        <item name="android:windowBackground">@drawable/launch_background</item>\n'
    '        <item name="android:windowSplashScreenBackground">@color/atomic_splash_background</item>\n'
    '    </style>\n'
    '</resources>\n';

/// Keyed by path relative to the android/ directory.
Map<String, String> get splashResourceFiles => {
      'app/src/main/res/values/atomic_colors.xml': _colorsXml(splashColorLight),
      'app/src/main/res/values-night/atomic_colors.xml':
          _colorsXml(splashColorDark),
      'app/src/main/res/drawable/launch_background.xml': _launchBackgroundXml,
      'app/src/main/res/drawable-v21/launch_background.xml':
          _launchBackgroundXml,
      'app/src/main/res/values-v31/styles.xml':
          _launchThemeV31('@android:style/Theme.Light.NoTitleBar'),
      'app/src/main/res/values-night-v31/styles.xml':
          _launchThemeV31('@android:style/Theme.Black.NoTitleBar'),
    };

// Release signing. The template signs release builds with the debug key,
// and every CI runner generates a fresh debug keystore, so each build had
// a different signature: Android refuses to install it over the previous
// one, and the only way forward (uninstall) deletes the local database.
// CI writes android/key.properties from repository secrets; when it's
// absent (forks, before the secrets exist) the build still falls back to
// the debug key, and CI says so in the job summary.
// Kotlin build scripts need the imports at the very top of the file:
// inside the script `java` resolves to Gradle's `java` extension, so a
// fully qualified `java.util.Properties()` doesn't compile. This mirrors
// the pattern in Flutter's Android deployment docs.
const _keystoreImports = '''
import java.io.FileInputStream
import java.util.Properties

''';

const _keystorePropertiesBlock = '''
// Release signing: android/key.properties is written by CI from secrets.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

''';

const _releaseSigningConfig = '''
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

''';

const templateReleaseSigning =
    'signingConfig = signingConfigs.getByName("debug")';
const atomicReleaseSigning = 'signingConfig = '
    'if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") '
    'else signingConfigs.getByName("debug")';

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

  // The launcher shows the brand name, not the Dart package name.
  final label = RegExp(r'android:label="[^"]*"');
  if (!label.hasMatch(out)) {
    throw AndroidPatchException('No android:label in AndroidManifest.xml');
  }
  out = out.replaceFirst(label, 'android:label="$appLabel"');

  // Ollama's local/LAN server is plain HTTP, which Android 9+ blocks by
  // default. Blanket allow: manifest XML can't scope it to private IPs.
  out = _addApplicationAttribute(out, 'android:usesCleartextTraffic', 'true');

  // Back up the database, never flutter_secure_storage's preferences (see
  // backupResourceFiles).
  out = _addApplicationAttribute(
      out, 'android:fullBackupContent', '@xml/atomic_backup_rules');
  out = _addApplicationAttribute(
      out, 'android:dataExtractionRules', '@xml/atomic_data_extraction_rules');

  if (!out.contains('android.speech.RecognitionService')) {
    out = _insertBefore(out, '    </queries>', voiceQueries);
  }

  if (!out.contains('ScheduledNotificationReceiver')) {
    // Before the closing tag's own indentation, so both stay aligned.
    out = _insertBefore(
        out, '    </application>', scheduledNotificationReceivers);
  }

  return out;
}

/// flutter_local_notifications is built with core library desugaring, and
/// AGP refuses to build an app that depends on it without the same. Also
/// wires the release signing config (see [atomicReleaseSigning]).
String patchAppGradleKts(String gradle) {
  var out = gradle;

  final appId = RegExp(r'applicationId = "[^"]*"');
  if (!appId.hasMatch(out)) {
    throw AndroidPatchException('No applicationId in app/build.gradle.kts');
  }
  out = out.replaceFirst(appId, 'applicationId = "$applicationId"');

  if (!out.contains('isCoreLibraryDesugaringEnabled')) {
    out = _insertAfter(
      out,
      'compileOptions {\n',
      '        isCoreLibraryDesugaringEnabled = true\n',
    );
  }

  if (!out.contains('import java.util.Properties')) {
    out = '${_keystoreImports.trimLeft()}$out';
  }
  if (!out.contains('keystorePropertiesFile')) {
    out = _insertBefore(out, 'android {\n', _keystorePropertiesBlock,
        first: true);
  }
  if (!out.contains('create("release")')) {
    out = _insertBefore(out, '    buildTypes {\n', _releaseSigningConfig,
        first: true);
  }
  if (out.contains(templateReleaseSigning)) {
    out = out.replaceFirst(templateReleaseSigning, atomicReleaseSigning);
  } else if (!out.contains(atomicReleaseSigning)) {
    throw AndroidPatchException(
        'Release signingConfig line not found in app/build.gradle.kts');
  }

  if (!out.contains('desugar_jdk_libs')) {
    out = '${out.trimRight()}\n\n'
        'dependencies {\n'
        '    coreLibraryDesugaring("$desugarJdkLibs")\n'
        '}\n';
  }

  return out;
}

/// Adds `name="value"` right after `<application` unless [name] is
/// already set. Manifest XML attributes are order-independent.
String _addApplicationAttribute(String manifest, String name, String value) {
  if (manifest.contains('$name=')) return manifest;
  final match = RegExp(r'<application\b').firstMatch(manifest);
  if (match == null) {
    throw AndroidPatchException('No <application> tag in AndroidManifest.xml');
  }
  return manifest.replaceRange(
    match.end,
    match.end,
    '\n        $name="$value"',
  );
}

String _insertBefore(
  String source,
  String anchor,
  String insertion, {
  bool first = false,
}) {
  final index = first ? source.indexOf(anchor) : source.lastIndexOf(anchor);
  if (index < 0) throw AndroidPatchException('Anchor "$anchor" not found');
  return source.replaceRange(index, index, insertion);
}

String _insertAfter(String source, String anchor, String insertion) {
  final index = source.indexOf(anchor);
  if (index < 0) throw AndroidPatchException('Anchor "$anchor" not found');
  final end = index + anchor.length;
  return source.replaceRange(end, end, insertion);
}
