# Flutter CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add GitHub Actions CI for formatting, analysis, and unit/widget tests on `main`.

**Architecture:** A single workflow installs Flutter stable, restores caches, gets dependencies, checks format, analyzes, and runs tests.

**Tech Stack:** GitHub Actions, Flutter stable, Dart formatter.

---

## File Structure

- Create: `.github/workflows/flutter-ci.yml`
- Modify: `docs/TECHNICAL.md` to mention CI scope.

### Task 1: Add Workflow

**Files:**
- Create: `.github/workflows/flutter-ci.yml`

- [ ] Create the workflow.

```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test
```

- [ ] Commit.

```powershell
git add .github/workflows/flutter-ci.yml
git commit -m "ci: add flutter checks"
```

### Task 2: Document CI

**Files:**
- Modify: `docs/TECHNICAL.md`

- [ ] Add a CI section explaining triggers and commands.

````markdown
## CI

O repositório usa GitHub Actions em pushes para `main` e pull requests direcionados para `main`.

O pipeline executa:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Os testes de integração permanecem locais neste momento.
````

- [ ] Run local verification.

```powershell
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Expected: all commands pass.

- [ ] Commit.

```powershell
git add docs/TECHNICAL.md
git commit -m "docs: describe flutter ci"
```
