# SQLite/Drift Local Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all `SharedPreferences` persistence with a Drift SQLite database, preserving legacy data and enabling paged/searchable history.

**Architecture:** Keep domain repository interfaces as the UI boundary. Add a Drift database and repository implementations under `lib/core/database/` and feature data layers, plus a one-time migration service from legacy `SharedPreferences`.

**Tech Stack:** Flutter, Riverpod, Drift, SQLite, SharedPreferences migration, flutter_test.

---

## File Structure

- Modify: `pubspec.yaml` to add `drift`, `sqlite3_flutter_libs`, `path`, `path_provider`, `drift_dev`, `build_runner`.
- Create: `lib/core/database/app_database.dart` for Drift tables and database.
- Create: `lib/core/database/database_provider.dart` for database initialization.
- Create: `lib/core/database/shared_preferences_migration.dart` for legacy import.
- Modify: `lib/shared/providers.dart` to provide database-backed repositories.
- Modify: repository implementations in `lib/features/**/data/repositories/`.
- Modify: `lib/features/chat/domain/repositories/conversation_repository.dart` for paged/search API.
- Modify: `lib/features/chat/presentation/history_screen.dart` for search/filter/pagination.
- Add tests under `test/core/database/` and update existing repository tests.

### Task 1: Add Drift Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] Add runtime and dev dependencies.

```yaml
dependencies:
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.26
  path: ^1.9.0

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.22.1
```

- [ ] Run dependency resolution.

```powershell
flutter pub get
```

Expected: dependency resolution succeeds and `pubspec.lock` updates.

- [ ] Commit.

```powershell
git add pubspec.yaml pubspec.lock
git commit -m "chore: add drift dependencies"
```

### Task 2: Create Database Schema

**Files:**
- Create: `lib/core/database/app_database.dart`
- Generate: `lib/core/database/app_database.g.dart`

- [ ] Add Drift tables for server profiles, app settings, selected models, conversations, messages, and characters.

```dart
@DriftDatabase(tables: [
  ServerProfiles,
  AppSettings,
  SelectedModels,
  Conversations,
  ChatMessages,
  ChatCharacters,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}
```

- [ ] Run code generation.

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Expected: `app_database.g.dart` is generated.

- [ ] Commit.

```powershell
git add lib/core/database/app_database.dart lib/core/database/app_database.g.dart
git commit -m "feat: add local drift database"
```

### Task 3: Add Database Provider and Migration Service

**Files:**
- Create: `lib/core/database/database_provider.dart`
- Create: `lib/core/database/shared_preferences_migration.dart`
- Modify: `lib/main.dart`
- Modify: `lib/shared/providers.dart`

- [ ] Add database initialization using `path_provider` and `NativeDatabase`.
- [ ] Add `SharedPreferencesMigration.run()` that reads legacy keys, upserts rows, and stores completion marker.
- [ ] Call migration before `runApp`.
- [ ] Add tests that seed legacy preferences and verify imported rows.

Run:

```powershell
flutter test test/core/database
```

Expected: migration tests pass.

- [ ] Commit.

```powershell
git add lib/core/database lib/main.dart lib/shared/providers.dart test/core/database
git commit -m "feat: migrate legacy preferences to drift"
```

### Task 4: Replace Repository Implementations

**Files:**
- Modify: `lib/features/servers/data/repositories/server_repository_impl.dart`
- Modify: `lib/features/models/data/repositories/model_selection_repository_impl.dart`
- Modify: `lib/features/chat/data/repositories/conversation_repository_impl.dart`
- Modify: `lib/features/chat/data/repositories/character_repository_impl.dart`
- Modify: `lib/features/chat/data/repositories/instructions_repository_impl.dart`
- Modify: `test/features/**`

- [ ] Rewrite implementations to use `AppDatabase`.
- [ ] Preserve existing method behavior and sort order.
- [ ] Keep JSON entity conversions only at API boundaries; database rows map through explicit helpers.
- [ ] Update tests to construct an in-memory Drift database.

Run:

```powershell
flutter test test/features
```

Expected: existing repository/controller tests pass.

- [ ] Commit.

```powershell
git add lib/features test/features lib/shared/providers.dart
git commit -m "feat: persist app data with drift repositories"
```

### Task 5: Add Paged History Search

**Files:**
- Modify: `lib/features/chat/domain/repositories/conversation_repository.dart`
- Modify: `lib/features/chat/data/repositories/conversation_repository_impl.dart`
- Modify: `lib/features/chat/presentation/history_screen.dart`
- Add: `test/features/chat/data/conversation_history_query_test.dart`

- [ ] Add paged query methods to the repository interface.
- [ ] Implement search over conversation title/model and message content.
- [ ] Add filters for server, model, character, and archived state.
- [ ] Add search field, filter menu, and "Carregar mais" button in history.

Run:

```powershell
flutter test test/features/chat
```

Expected: history query and widget tests pass.

- [ ] Commit.

```powershell
git add lib/features/chat test/features/chat
git commit -m "feat: add searchable paged chat history"
```

### Task 6: Full Verification

- [ ] Run analyzer and tests.

```powershell
flutter analyze
flutter test
```

Expected: both commands pass.

- [ ] Commit any final fixes.

```powershell
git add .
git commit -m "test: verify drift storage migration"
```
