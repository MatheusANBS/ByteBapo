# HTTPS Proxy Remote Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Support HTTPS proxy access with a custom authorization header whose value is stored in Android secure storage.

**Architecture:** Store non-secret server metadata in the normal repository and store secret header values through `flutter_secure_storage`; resolve headers immediately before HTTP requests.

**Tech Stack:** Flutter, `flutter_secure_storage`, Riverpod, HTTP client tests.

---

## File Structure

- Modify: `pubspec.yaml`
- Add: `lib/core/secure_storage/secure_value_store.dart`
- Add: `lib/features/servers/data/server_secret_store.dart`
- Modify: `lib/features/servers/domain/entities/server_profile.dart`
- Modify: `lib/features/servers/data/repositories/server_repository_impl.dart`
- Modify: `lib/core/network/ollama_api_client.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Add: `docs/REMOTE_ACCESS.md`
- Modify: `docs/TECHNICAL.md`
- Add/update tests under `test/core/network/`, `test/features/servers/`.

### Task 1: Add Secure Storage

**Files:**
- Modify: `pubspec.yaml`
- Add: `lib/core/secure_storage/secure_value_store.dart`
- Add: `test/core/secure_storage/secure_value_store_test.dart`

- [ ] Add dependency.

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

- [ ] Create `SecureValueStore` abstraction with production and in-memory implementations.

```dart
abstract class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
```

Run:

```powershell
flutter pub get
flutter test test/core/secure_storage
```

Expected: secure store tests pass.

- [ ] Commit.

```powershell
git add pubspec.yaml pubspec.lock lib/core/secure_storage test/core/secure_storage
git commit -m "feat: add secure value storage"
```

### Task 2: Split Server Header Metadata and Secret

**Files:**
- Modify: `lib/features/servers/domain/entities/server_profile.dart`
- Add: `lib/features/servers/data/server_secret_store.dart`
- Modify: `lib/features/servers/data/repositories/server_repository_impl.dart`
- Modify: `test/features/servers/data/server_repository_test.dart`
- Modify: `test/features/servers/data/server_profile_test.dart`

- [ ] Add `authHeaderName` and `hasAuthHeaderValue` to `ServerProfile`.
- [ ] Store secret value under `server.<id>.auth_header_value`.
- [ ] Delete the secure value when removing a server profile.
- [ ] Migrate existing non-empty `headers` values into secure storage during the Drift migration if the Drift plan has landed first.

Run:

```powershell
flutter test test/features/servers
```

Expected: server entity and repository tests pass.

- [ ] Commit.

```powershell
git add lib/features/servers test/features/servers
git commit -m "feat: store server auth headers securely"
```

### Task 3: Resolve Headers for Requests

**Files:**
- Modify: `lib/core/network/ollama_api_client.dart`
- Add: `lib/core/network/server_header_resolver.dart`
- Modify: `test/core/network/ollama_api_client_test.dart`

- [ ] Add a resolver that returns `{authHeaderName: secureValue}` when both are present.
- [ ] Use resolved headers in `listModels` and `streamChat`.
- [ ] Test that custom headers are sent to both endpoints.

Run:

```powershell
flutter test test/core/network
```

Expected: network tests pass.

- [ ] Commit.

```powershell
git add lib/core/network test/core/network
git commit -m "feat: send secure proxy headers"
```

### Task 4: Update Server UI

**Files:**
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Add: `test/features/servers/presentation/server_screen_proxy_test.dart`

- [ ] Label fields as optional proxy header name and secure value.
- [ ] Allow custom names such as `Authorization`, `X-Api-Key`, and Cloudflare Access headers.
- [ ] Do not show saved secret values back in plain text.
- [ ] Add widget tests for save, edit, and delete behavior.

Run:

```powershell
flutter test test/features/servers
```

Expected: server UI tests pass.

- [ ] Commit.

```powershell
git add lib/features/servers test/features/servers
git commit -m "feat: add https proxy auth fields"
```

### Task 5: Document Remote Access

**Files:**
- Add: `docs/REMOTE_ACCESS.md`
- Modify: `docs/TECHNICAL.md`

- [ ] Document HTTPS proxy, Cloudflare Tunnel, Tailscale, ZeroTier, and why not to expose Ollama directly.
- [ ] Show examples of custom headers without real secrets.

Run:

```powershell
flutter analyze
flutter test
```

Expected: analyzer and tests pass.

- [ ] Commit.

```powershell
git add docs/REMOTE_ACCESS.md docs/TECHNICAL.md
git commit -m "docs: add remote access guidance"
```
