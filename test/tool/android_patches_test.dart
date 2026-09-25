import 'package:flutter_test/flutter_test.dart';

import '../../tool/ci/android_patches.dart';

// Flutter 3.35.7's templates (packages/flutter_tools/templates/app/
// android*.tmpl) rendered for this project, with comments and attributes
// the patches never touch trimmed. Every anchor the patches rely on is
// kept verbatim; refresh these when CI's pinned Flutter version changes.
const _manifestTemplate = '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="flowline"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
''';

const _gradleTemplate = '''
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.devbehindyou.flowline"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
''';

int _count(String haystack, String needle) => needle.allMatches(haystack).length;

void main() {
  group('patchManifest', () {
    final patched = patchManifest(_manifestTemplate);

    test('adds every required permission as a direct child of <manifest>', () {
      final applicationEnd = patched.indexOf('</application>');
      for (final permission in manifestPermissions) {
        final tag = '<uses-permission android:name="$permission"/>';
        expect(patched, contains(tag));
        expect(patched.indexOf(tag), greaterThan(applicationEnd),
            reason: '$permission must not be nested inside <application>');
      }
    });

    test('allows cleartext traffic on the <application> tag for Ollama', () {
      final applicationTag =
          patched.substring(patched.indexOf('<application'), patched.indexOf('<activity'));
      expect(applicationTag, contains('android:usesCleartextTraffic="true"'));
    });

    test('registers both scheduled-notification receivers inside <application>', () {
      final applicationBody =
          patched.substring(patched.indexOf('<application'), patched.indexOf('</application>'));
      expect(applicationBody, contains('ScheduledNotificationReceiver"'));
      expect(applicationBody, contains('ScheduledNotificationBootReceiver"'));
    });

    test('is idempotent', () {
      expect(patchManifest(patched), patched);
      expect(_count(patched, 'android.permission.INTERNET'), 1);
    });

    test('fails loudly when the template has no <application> tag', () {
      expect(
        () => patchManifest('<manifest></manifest>'),
        throwsA(isA<AndroidPatchException>()),
      );
    });
  });

  group('patchAppGradleKts', () {
    final patched = patchAppGradleKts(_gradleTemplate);

    test('enables core library desugaring inside compileOptions', () {
      final compileOptions = patched.substring(
        patched.indexOf('compileOptions {'),
        patched.indexOf('kotlinOptions {'),
      );
      expect(compileOptions, contains('isCoreLibraryDesugaringEnabled = true'));
    });

    test('adds the desugar_jdk_libs dependency at top level', () {
      expect(patched, contains('coreLibraryDesugaring("$desugarJdkLibs")'));
      expect(patched.indexOf('dependencies {'), greaterThan(patched.indexOf('flutter {')));
    });

    test('is idempotent', () {
      expect(patchAppGradleKts(patched), patched);
    });

    test('fails loudly when compileOptions is missing', () {
      expect(
        () => patchAppGradleKts('android {\n}\n'),
        throwsA(isA<AndroidPatchException>()),
      );
    });
  });
}
