# Fase 3A — Seleção de modelo no Drift Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persistir a seleção de modelo por servidor em SQLite, removendo esse fluxo funcional do `SharedPreferences`.

**Architecture:** A tabela `selected_models` usa `server_profile_id` como chave primária e chave estrangeira para `server_profiles`, com cascata de exclusão. `DriftModelSelectionRepository` implementa o contrato existente e é composto por Riverpod; apresentação continua dependente somente de `ModelSelectionRepository`.

**Tech Stack:** Flutter, Dart, Drift, Riverpod, flutter_test.

## Global Constraints

- O banco permanece novo, em `schemaVersion = 1`, sem importar dados do `SharedPreferences`.
- A remoção de um servidor apaga sua seleção de modelo por cascata.
- Nenhum repositório funcional de seleção de modelo usa `SharedPreferences` após esta fase.
- O desenvolvimento segue TDD: cada comportamento novo é escrito, falha e só então recebe implementação.

---

### Task 1: Tabela relacional `selected_models`

**Files:**
- Modify: `lib/core/database/app_database.dart`
- Regenerate: `lib/core/database/app_database.g.dart`
- Test: `test/core/database/app_database_test.dart`

**Produces:** A tabela Drift `SelectedModels` com `serverProfileId`, `modelId` e `updatedAt`; `serverProfileId` referencia `ServerProfiles.id` com `onDelete: KeyAction.cascade`.

- [ ] **Step 1: Write the failing test**

```dart
test('deletes a selected model when its server is deleted', () async {
  await database.into(database.serverProfiles).insert(serverRow);
  await database.into(database.selectedModels).insert(selectionRow);
  await database.deleteServer('server-1');

  expect(await database.select(database.selectedModels).get(), isEmpty);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/database/app_database_test.dart`

Expected: compilation fails because `selectedModels` and `SelectedModelsCompanion` do not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
class SelectedModels extends Table {
  TextColumn get serverProfileId => text().references(
    ServerProfiles,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get modelId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {serverProfileId};
}

@DriftDatabase(tables: [ServerProfiles, AppSettings, SelectedModels])
class AppDatabase extends _$AppDatabase { /* existing database methods */ }
```

Enable `PRAGMA foreign_keys = ON` in the database `onCreate` callback and regenerate with `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/database/app_database_test.dart`

Expected: PASS.

### Task 2: Repositório Drift de seleção de modelo

**Files:**
- Create: `lib/features/models/data/repositories/drift_model_selection_repository.dart`
- Modify: `lib/shared/providers.dart`
- Test: `test/features/models/data/drift_model_selection_repository_test.dart`

**Consumes:** `AppDatabase.selectedModels` e `ModelSelectionRepository`.

**Produces:** `DriftModelSelectionRepository.getSelectedModel` e `setSelectedModel`; inserir ou atualizar um modelo para um servidor, e remover a linha quando `model` for nulo ou vazio.

- [ ] **Step 1: Write the failing test**

```dart
test('updates and clears the selection for one server', () async {
  await repository.setSelectedModel('qwen3:latest', serverProfileId: 'server-1');
  expect(await repository.getSelectedModel(serverProfileId: 'server-1'), 'qwen3:latest');

  await repository.setSelectedModel(null, serverProfileId: 'server-1');
  expect(await repository.getSelectedModel(serverProfileId: 'server-1'), isNull);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/models/data/drift_model_selection_repository_test.dart`

Expected: compilation fails because `DriftModelSelectionRepository` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
class DriftModelSelectionRepository implements ModelSelectionRepository {
  const DriftModelSelectionRepository({required this.database});
  final AppDatabase database;

  @override
  Future<String?> getSelectedModel({String? serverProfileId}) async { /* select row */ }

  @override
  Future<void> setSelectedModel(String? model, {String? serverProfileId}) async { /* delete or upsert */ }
}
```

Replace `ModelSelectionRepositoryImpl(preferences: ...)` in `modelSelectionRepositoryProvider` with `DriftModelSelectionRepository(database: ref.watch(appDatabaseProvider))`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/models/data/drift_model_selection_repository_test.dart`

Expected: PASS.

### Task 3: Regressão de composição

**Files:**
- Modify: `test/widget_test.dart` only if an override still depends on `SharedPreferences` for model selection.

- [ ] **Step 1: Run static analysis and all tests**

Run: `dart format lib test && flutter analyze && flutter test`

Expected: analysis reports no issues and all tests pass.

- [ ] **Step 2: Confirm the removed dependency**

Run: `rg -n "ModelSelectionRepositoryImpl|models.selected.v1" lib test`

Expected: no functional composition references remain; the legacy implementation can stay temporarily only while other direct tests are migrated in a later task.
