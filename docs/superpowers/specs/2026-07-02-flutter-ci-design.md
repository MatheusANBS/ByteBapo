# Flutter CI Design

## Context

The repository currently documents local commands but does not define CI. The project needs a GitHub Actions workflow that protects `main` with automated formatting, analysis, and unit/widget tests.

## Goals

- Add GitHub Actions for `main`.
- Run `flutter pub get`.
- Run `dart format --set-exit-if-changed .`.
- Run `flutter analyze`.
- Run `flutter test`.
- Cache Flutter and pub dependencies where practical.

## Non-Goals

- Integration tests are not included in CI initially.
- Android APK release publishing is out of scope for CI.
- Pull request validation for non-main branches is out of scope unless the branch targets `main`.

## Workflow

Create `.github/workflows/flutter-ci.yml`.

Triggers:

- `push` to `main`.
- `pull_request` with target branch `main`.

The workflow should run on `ubuntu-latest`, check out the repository, install stable Flutter, restore caches, fetch dependencies, then execute format, analyze, and tests.

## Testing

The workflow file should be validated locally by running the same commands:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Acceptance Criteria

- GitHub Actions shows a CI workflow for pushes to `main` and PRs targeting `main`.
- The workflow fails if formatting, analyzer, or tests fail.
- Integration tests remain documented as local-only.
