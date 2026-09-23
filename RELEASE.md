# Store builds

From frontend, use these commands instead of plain flutter build:

```sh
python3 scripts/build_release.py ios      # App Store IPA
python3 scripts/build_release.py android  # Play Store AAB
python3 scripts/build_release.py both     # Same version/build for both stores
python3 scripts/build_release.py apk      # Android APK for distribution/testing
```

Each invocation increments the build number in pubspec.yaml once. Starting at
1.11.1+80, the next invocation reserves 1.11.1+81. Public version stays unchanged
unless explicitly provided for a new store release:

```sh
python3 scripts/build_release.py both --version 1.12.0
```

Android already reads Flutter's versionName/versionCode. iOS Info.plist now
reads FLUTTER_BUILD_NAME/FLUTTER_BUILD_NUMBER instead of hard-coded values.
These commands explicitly select the live API and do not upload or submit apps.
Signing and store access must already be configured; iOS builds require macOS.

Before the first release, compare pubspec's build number with the highest build
already uploaded to both stores. Set it to at least that highest number if needed;
the script cannot read App Store Connect or Play Console. A new public App Store
release also needs an appropriate higher public version and matching store entry.

Commit the updated pubspec.yaml after building and sync it before another person
or machine builds. Local builds are serialized; separate clones are not. Failed
builds keep their reserved number to avoid reusing a partially produced artifact.

Plain flutter build, IDE builds, and direct Xcode Archive do not automatically
increment. Debug runs and hot reload remain unaffected. Always use the commands
above for release builds. No App Store or Play Store upload is performed here.

Verify this tooling without producing store builds:

```sh
python3 -B -m unittest discover -s scripts -p 'test_build_release.py'
```
