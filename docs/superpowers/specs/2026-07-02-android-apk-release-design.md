# Android APK Release Design

## Context

`android/app/build.gradle.kts` currently signs release builds with the debug signing config. BytePapo needs a documented APK release process with a real local keystore and a versioning policy.

## Goals

- Configure Gradle release signing using `android/key.properties`.
- Keep keystore secrets out of git.
- Document APK release commands.
- Introduce a version policy based on SemVer plus an incrementing build number in `pubspec.yaml`.

## Non-Goals

- AAB / Play Store release is out of scope.
- CI-based release publishing is out of scope.
- Automatic version bumping is out of scope.

## Signing Design

Add Gradle logic that loads `key.properties` when present:

- `storeFile`
- `storePassword`
- `keyAlias`
- `keyPassword`

Release builds must use the release signing config. If `key.properties` is missing, Gradle should fail clearly for release builds instead of silently using debug keys.

Add `android/key.properties.example` and ensure `android/key.properties` and keystore files are ignored by git.

## Versioning Policy

Use `pubspec.yaml` as the source of truth:

```yaml
version: MAJOR.MINOR.PATCH+BUILD
```

Rules:

- `MAJOR`: incompatible user-visible or storage changes.
- `MINOR`: new backward-compatible features.
- `PATCH`: bug fixes and documentation-only release fixes.
- `BUILD`: increment every APK release, even if SemVer does not change.

## Documentation

Create `docs/RELEASE_ANDROID.md` covering:

- keystore creation with `keytool`;
- `key.properties` creation;
- version bump rules;
- `flutter clean` when needed;
- `flutter build apk --release`;
- APK output path;
- sanity checks before distributing.

## Acceptance Criteria

- `flutter build apk --release` produces a signed APK when `key.properties` and keystore are present.
- Release builds no longer use debug signing.
- Secrets are not committed.
- The release process is documented for APK-only distribution.
