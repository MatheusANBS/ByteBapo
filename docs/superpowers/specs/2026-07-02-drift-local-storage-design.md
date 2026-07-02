# SQLite/Drift Local Storage Design

## Context

BytePapo currently persists all local data in `SharedPreferences` using JSON string lists and scalar keys. This is simple, but it does not scale for large chat histories because every list operation reads and rewrites the full dataset. The app should migrate all persisted data to a local SQLite database managed by Drift while preserving existing user data automatically.

## Goals

- Move servers, active server, selected models, conversations, messages, characters, active character, and global instructions from `SharedPreferences` to Drift.
- Run a first-launch migration from existing `SharedPreferences` keys into SQLite.
- Make migration idempotent so reopening the app or reinstalling over existing data does not duplicate records.
- Add repository support for large histories through pagination, text search, and filters.
- Keep Riverpod providers and domain interfaces as the app boundary; UI should not depend directly on Drift.

## Non-Goals

- Cloud sync is out of scope.
- End-to-end encryption of the database is out of scope.
- Redesigning the chat UI beyond search/filter controls is out of scope.

## Data Model

Drift will own the app database in `lib/core/database/app_database.dart`.

Tables:

- `server_profiles`: `id`, `name`, `protocol`, `host`, `port`, `base_path`, `created_at`, `updated_at`, `last_connected_at`.
- `app_settings`: string key/value table for singleton values such as `active_server_id`, `active_character_id`, and `global_instructions`.
- `selected_models`: `server_profile_id`, `model`, `updated_at`.
- `conversations`: current `Conversation` fields.
- `chat_messages`: current `ChatMessage` fields, indexed by `conversation_id` and `created_at`.
- `chat_characters`: current `ChatCharacter` fields.

Headers are intentionally excluded from the database when they contain secret values; the proxy/security specs move those secrets to secure storage. Non-secret header metadata may be represented later by a separate table if needed.

## Migration

A `SharedPreferencesMigration` service will read these legacy keys:

- `servers.profiles.v1`
- `servers.active_id.v1`
- `models.selected.v1` and `models.selected.v1.<serverId>`
- `chat.conversations.v1`
- `chat.messages.v1`
- `chat.characters.v1`
- `chat.active_character.v1`
- global instructions key from `InstructionsRepositoryImpl`

After successful import, it writes a marker such as `migration.shared_preferences_to_drift.v1.completed = true`. It must skip rows that already exist by primary key. It should not delete legacy data during the first implementation.

## Repository Behavior

Existing repository interfaces stay valid for current callers. New history APIs should be added to `ConversationRepository`:

- `listConversationsPage({required int limit, required int offset, String? query, String? serverId, String? model, String? characterId, bool includeArchived = false})`
- `countConversations({String? query, String? serverId, String? model, String? characterId, bool includeArchived = false})`

Search should match conversation title, model, and message content. Filters should cover server, model, character, and archived state.

## UI Changes

`HistoryScreen` should add a search field, filter affordances, loading state for paged data, and clear empty states. The first implementation can use "load more" pagination rather than infinite scrolling.

## Testing

- Unit tests for database DAOs and repositories.
- Migration tests from seeded `SharedPreferences`.
- Existing repository tests should be ported to the Drift-backed implementations.
- Widget tests for history search/filter behavior.

## Acceptance Criteria

- A user upgrading from the current app keeps all saved data.
- Existing screens work through the same providers after migration.
- A history with thousands of messages can be searched and paginated without loading every message into memory.
- `flutter analyze` and `flutter test` pass.
