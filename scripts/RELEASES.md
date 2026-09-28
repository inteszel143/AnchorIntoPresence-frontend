# Store builds

Run from the frontend directory:

```sh
python3 scripts/build_release.py ios
python3 scripts/build_release.py android
```

`release_versions.json` records each platform's last reserved and built versions.
Every invocation increments that platform's patch version and build number by one.
An explicit `--version X.Y.Z` overrides the version name; the build number still
increments. Android APK and AAB builds share the Android counter. `both` reserves
one version for each platform independently.

The script passes versions directly to Flutter, leaving the shared pubspec version
unchanged. Failed attempts retain their reserved numbers to avoid accidental reuse.
`built` means the local build command succeeded, not that the artifact was uploaded
or accepted by the store. Check the store's latest used build number before building
if another developer or CI has uploaded builds outside this script.

Builds use the production API. Uploading through Transporter or Google Play Console
is a separate step. Android signing credentials remain in ignored key.properties.
