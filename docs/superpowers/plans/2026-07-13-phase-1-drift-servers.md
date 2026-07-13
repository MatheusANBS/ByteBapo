# Fase 1 — Persistência e Servidores Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir a persistência de servidores por SQLite/Drift, guardar chaves fora do banco e expor o CRUD de servidores à composição Riverpod.

**Architecture:** O domínio continua Dart puro e declara o contrato `ServerRepository`. `AppDatabase` e `DriftServerRepository` vivem em data/core e realizam apenas mapeamento e transações; `ServerSecretStore` encapsula `flutter_secure_storage`. O perfil não contém a chave: o repositório a anexa apenas para o cliente de rede depois de lê-la no armazenamento seguro.

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, flutter_secure_storage, flutter_test.

## Global Constraints

- O banco começa vazio em `schemaVersion = 1`; não lê, migra nem remove dados legados de `SharedPreferences`.
- A chave NVIDIA não é persistida no SQLite, serializada, registrada em log ou incluída em uma mensagem de falha.
- O domínio não importa Flutter, Riverpod, Drift, SQLite, HTTP ou armazenamento seguro.
- O aplicativo preserva Android API 24 e roda `dart format lib test`, `flutter analyze`, `flutter test` e `flutter build apk --debug` ao concluir a fase.

---

## Estrutura de arquivos

- `lib/core/database/app_database.dart`: tabelas `server_profiles`, `app_settings` e abertura Drift.
- `lib/core/database/app_database.g.dart`: código gerado pelo Drift, nunca editado manualmente.
- `lib/core/secure_storage/server_secret_store.dart`: contrato e implementação de chaves por alias.
- `lib/features/servers/domain/entities/server_profile.dart`: entidade sem segredo persistível, status e avatar.
- `lib/features/servers/data/repositories/drift_server_repository.dart`: mapeamento, CRUD, seleção ativa e coordenação transacional com segredos.
- `lib/shared/providers.dart` e `lib/main.dart`: composição do banco e dos repositórios.
- `test/core/database/app_database_test.dart`: constraints e seleção ativa no banco em memória.
- `test/features/servers/data/drift_server_repository_test.dart`: CRUD, segredo e limpeza compensatória.

### Task 1: Dependências e banco Drift

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/database/app_database.dart`
- Create: `test/core/database/app_database_test.dart`

**Interfaces:**
- Produces `AppDatabase(QueryExecutor executor)` para testes e `AppDatabase.defaults()` para o app.
- Produces `Future<String?> readSetting(String key)` e `Future<void> writeSetting(String key, String? value)`.

- [ ] **Step 1: Adicionar as dependências de infraestrutura**

Run: `flutter pub add drift drift_flutter flutter_secure_storage && flutter pub add --dev drift_dev build_runner`

- [ ] **Step 2: Escrever o teste de banco que falha**

```dart
test('clears the active setting when its server is deleted', () async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await database.into(database.serverProfiles).insert(ServerProfilesCompanion.insert(
    id: 'server-1', name: 'NVIDIA', provider: 'nvidia', protocol: 'https',
    host: 'integrate.api.nvidia.com', port: const Value(443),
    createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
  ));
  await database.writeSetting(AppSettingKey.activeServerId, 'server-1');
  await database.deleteServer('server-1');
  expect(await database.readSetting(AppSettingKey.activeServerId), isNull);
});
```

- [ ] **Step 3: Rodar o teste e observar falha por `AppDatabase` inexistente**

Run: `flutter test test/core/database/app_database_test.dart`
Expected: FAIL, because the database API has not been implemented.

- [ ] **Step 4: Implementar a menor versão de `AppDatabase`**

```dart
@DriftDatabase(tables: [ServerProfiles, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  AppDatabase.defaults() : super(driftDatabase(name: 'bytepapo'));
  @override int get schemaVersion => 1;
  Future<void> deleteServer(String id) => transaction(() async {
    await (delete(serverProfiles)..where((row) => row.id.equals(id))).go();
    await writeSetting(AppSettingKey.activeServerId, null);
  });
}
```

- [ ] **Step 5: Gerar Drift e verificar o teste verde**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/core/database/app_database_test.dart`
Expected: PASS.

### Task 2: Segredos e entidade de servidor

**Files:**
- Create: `lib/core/secure_storage/server_secret_store.dart`
- Modify: `lib/features/servers/domain/entities/server_profile.dart`
- Modify: `test/features/servers/data/server_profile_test.dart`
- Create: `test/core/secure_storage/server_secret_store_test.dart`

**Interfaces:**
- Produces `abstract interface class ServerSecretStore` with `read`, `write` and `delete`.
- `ServerProfile` exposes nullable `apiKeyAlias`, `avatarPath` and `connectionStatus`, but never `apiKey` or authorization headers.

- [ ] **Step 1: Escrever testes de contrato de segredo e de perfil sem chave**

```dart
test('creates a deterministic alias without exposing the key', () {
  expect(ServerSecretStore.aliasFor('server-1'), 'server-api-key:server-1');
  expect(ServerProfile.create(...).toJson().containsKey('apiKey'), isFalse);
});
```

- [ ] **Step 2: Rodar os testes e observar falha esperada**

Run: `flutter test test/core/secure_storage/server_secret_store_test.dart test/features/servers/data/server_profile_test.dart`
Expected: FAIL because the secret-store API and secret-free entity do not exist.

- [ ] **Step 3: Implementar o contrato e adaptar a entidade**

```dart
abstract interface class ServerSecretStore {
  static String aliasFor(String serverId) => 'server-api-key:$serverId';
  Future<String?> read(String alias);
  Future<void> write(String alias, String value);
  Future<void> delete(String alias);
}
```

- [ ] **Step 4: Confirmar os testes verdes**

Run: `flutter test test/core/secure_storage/server_secret_store_test.dart test/features/servers/data/server_profile_test.dart`
Expected: PASS.

### Task 3: Repositório Drift de servidores

**Files:**
- Create: `lib/features/servers/data/repositories/drift_server_repository.dart`
- Modify: `lib/features/servers/domain/repositories/server_repository.dart`
- Create: `test/features/servers/data/drift_server_repository_test.dart`

**Interfaces:**
- Consumes `AppDatabase` and `ServerSecretStore`.
- Produces `save(ServerProfile profile, {String? apiKey})`, `remove`, `list`, `getActiveServerId` and `setActiveServerId`.

- [ ] **Step 1: Escrever os testes de repositório**

```dart
test('stores NVIDIA keys only in secure storage', () async {
  await repository.save(profile, apiKey: 'nvapi-secret');
  expect(await secrets.read(ServerSecretStore.aliasFor(profile.id)), 'nvapi-secret');
  final row = await database.select(database.serverProfiles).getSingle();
  expect(row.apiKeyAlias, ServerSecretStore.aliasFor(profile.id));
  expect(row.toString(), isNot(contains('nvapi-secret')));
});

test('deletes a confirmed database row before deleting its secret', () async {
  await repository.remove('server-1');
  expect(await database.serverExists('server-1'), isFalse);
  expect(await secrets.read(ServerSecretStore.aliasFor('server-1')), isNull);
});
```

- [ ] **Step 2: Rodar os testes e observar falha esperada**

Run: `flutter test test/features/servers/data/drift_server_repository_test.dart`
Expected: FAIL because `DriftServerRepository` is absent.

- [ ] **Step 3: Implementar mapeadores e transações mínimas**

```dart
Future<void> save(ServerProfile profile, {String? apiKey}) async {
  final alias = apiKey == null || apiKey.isEmpty ? null : ServerSecretStore.aliasFor(profile.id);
  await database.transaction(() async { await database.upsertServer(profile, apiKeyAlias: alias); });
  if (alias != null) await secrets.write(alias, apiKey);
}
```

- [ ] **Step 4: Confirmar os testes verdes**

Run: `flutter test test/features/servers/data/drift_server_repository_test.dart`
Expected: PASS.

### Task 4: Composição do aplicativo e remoção do caminho de servidores em SharedPreferences

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/shared/providers.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- `appDatabaseProvider` fornece a instância de `AppDatabase`.
- `serverRepositoryProvider` fornece `DriftServerRepository`.
- A tela envia a chave como argumento de `save`; nenhum widget lê a chave depois de salvar.

- [ ] **Step 1: Escrever teste de widget para salvar servidor NVIDIA sem reproduzir a chave**

```dart
await tester.enterText(find.byType(TextFormField).last, 'nvapi-secret');
await tester.tap(find.text('Salvar'));
expect(find.textContaining('nvapi-secret'), findsNothing);
expect(await secrets.read(ServerSecretStore.aliasFor(savedId)), 'nvapi-secret');
```

- [ ] **Step 2: Rodar o teste e observar falha esperada**

Run: `flutter test test/widget_test.dart --plain-name "saves NVIDIA server without rendering its key"`
Expected: FAIL because the provider graph still uses SharedPreferences.

- [ ] **Step 3: Implementar a composição e adaptar a tela**

```dart
final appDatabaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError());
final serverRepositoryProvider = Provider<ServerRepository>((ref) => DriftServerRepository(
  database: ref.watch(appDatabaseProvider), secrets: ref.watch(serverSecretStoreProvider),
));
```

- [ ] **Step 4: Confirmar o widget e toda a suíte verde**

Run: `dart format lib test && flutter analyze && flutter test`
Expected: all commands exit with code 0.

- [ ] **Step 5: Validar o artefato Android**

Run: `flutter build apk --debug`
Expected: build succeeds and creates a debug APK.
