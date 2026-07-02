# Integration Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add local Flutter integration tests for the primary BytePapo user journey without requiring a real Ollama server.

**Architecture:** Use provider overrides and fake API/database dependencies to run deterministic `integration_test` flows through the real app UI.

**Tech Stack:** Flutter `integration_test`, Riverpod provider overrides, fake HTTP/API client.

---

## File Structure

- Modify: `pubspec.yaml`
- Add: `integration_test/app_flow_test.dart`
- Add: `test/support/fake_ollama_api_client.dart`
- Add: `test/support/test_app.dart`
- Add: `docs/INTEGRATION_TESTS.md`
- Modify: `docs/TECHNICAL.md`

### Task 1: Add Integration Test Package

**Files:**
- Modify: `pubspec.yaml`

- [ ] Add dependency.

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

- [ ] Fetch dependencies.

```powershell
flutter pub get
```

Expected: `pubspec.lock` updates.

- [ ] Commit.

```powershell
git add pubspec.yaml pubspec.lock
git commit -m "test: add integration test package"
```

### Task 2: Add Test Harness

**Files:**
- Add: `test/support/fake_ollama_api_client.dart`
- Add: `test/support/test_app.dart`

- [ ] Create fake API behavior: `/api/tags` returns two fake models; chat stream returns deterministic chunks.
- [ ] Create `pumpBytePapoTestApp()` with provider overrides for repositories, API client, and secure storage/database test dependencies.
- [ ] Add stable widget keys to production screens where needed.

Run:

```powershell
flutter test test/support
```

Expected: support files compile through dependent tests.

- [ ] Commit.

```powershell
git add test/support lib
git commit -m "test: add bytepapo integration harness"
```

### Task 3: Add Primary Flow Test

**Files:**
- Add: `integration_test/app_flow_test.dart`

- [ ] Write integration test that registers fake server and confirms test connection.
- [ ] Select fake model.
- [ ] Send chat message and wait for fake streaming response.
- [ ] Open history, search the conversation, and reopen it.
- [ ] Add global instructions or a character and verify fake client receives context.

Run:

```powershell
flutter test integration_test
```

Expected: integration suite passes locally.

- [ ] Commit.

```powershell
git add integration_test
git commit -m "test: cover primary app flow"
```

### Task 4: Document Local Execution

**Files:**
- Add: `docs/INTEGRATION_TESTS.md`
- Modify: `docs/TECHNICAL.md`

- [ ] Document command.

```powershell
flutter test integration_test
```

- [ ] State that integration tests are local-only and not part of GitHub Actions yet.

- [ ] Commit.

```powershell
git add docs/INTEGRATION_TESTS.md docs/TECHNICAL.md
git commit -m "docs: describe local integration tests"
```
