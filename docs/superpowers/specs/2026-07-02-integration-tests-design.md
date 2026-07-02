# Integration Tests Design

## Context

BytePapo has unit and widget tests, but no Flutter integration tests for the primary user journey. The first integration suite should run locally with `integration_test` and avoid requiring a real Ollama server.

## Goals

- Add Flutter `integration_test` support.
- Cover the main local journey with fake network responses.
- Keep integration tests local-only for now.
- Document how to run them.

## Non-Goals

- Running integration tests in CI is out of scope initially.
- Testing a real Ollama installation is out of scope.
- Performance/load testing is out of scope.

## Required Flow

The initial suite should cover:

1. Register and test a fake server.
2. Load a fake model list and select a model.
3. Send a chat message and receive a fake streaming response.
4. Open history, search/filter, and reopen the conversation.
5. Create/activate character or global instructions and verify they affect the sent context.

## Testability Design

The app should expose dependency overrides suitable for tests. A test app entry point can wrap `OllamaMobileApp` in `ProviderScope` with:

- temporary local database;
- fake or in-memory secure storage;
- fake `OllamaApiClient` or fake HTTP client;
- deterministic IDs/clocks where needed.

Prefer provider overrides over environment-specific branching inside production widgets.

## Documentation

Add a section to `docs/TECHNICAL.md` or create `docs/INTEGRATION_TESTS.md` explaining:

```powershell
flutter test integration_test
```

and any emulator/device requirements.

## Acceptance Criteria

- `flutter test integration_test` passes locally with no real Ollama server.
- The tested flow exercises navigation from server setup through chat and history.
- CI documentation clearly says integration tests are local-only for now.
