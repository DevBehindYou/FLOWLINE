// Usage: dart run tool/ci/patch_android.dart <android dir>
//
// Applies Flowline's requirements to a freshly generated `flutter create`
// Android project. See android_patches.dart for what and why.
import 'dart:io';

import 'android_patches.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/ci/patch_android.dart <android dir>');
    exit(64);
  }
  final androidDir = args.single;

  try {
    _patchFile('$androidDir/app/src/main/AndroidManifest.xml', patchManifest);
    _patchFile('$androidDir/app/build.gradle.kts', patchAppGradleKts);
  } on AndroidPatchException catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}

void _patchFile(String path, String Function(String) patch) {
  final file = File(path);
  if (!file.existsSync()) {
    throw AndroidPatchException('$path not found');
  }
  final before = file.readAsStringSync();
  final after = patch(before);
  file.writeAsStringSync(after);
  stdout.writeln(before == after ? 'Unchanged: $path' : 'Patched:   $path');
}
