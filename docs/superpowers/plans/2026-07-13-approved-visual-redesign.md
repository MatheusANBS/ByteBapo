# Approved Visual Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans task-by-task.

**Goal:** Make the BytePapo Flutter UI match the approved redesign images for chat, servers, models, settings, characters and navigation.

**Architecture:** Centralize visual tokens in the app theme and small shared presentation widgets. Keep data/network behavior unchanged; screens compose the existing providers into the approved hierarchy.

**Tech Stack:** Flutter Material 3, Riverpod, go_router, flutter_test.

## Global Constraints

- Use the approved images in `docs/assets/bytepapo-redesign-approved.png` and `docs/assets/bytepapo-settings-approved.png` as production specifications.
- Keep exactly four bottom destinations: Chat, Servidores, Modelos and Histórico.
- Settings opens from the three-dot menu; do not add a fifth navigation destination.
- Preserve existing clean boundaries and user flows; no HTTP or SQL in widgets.
- Add widget/golden-style viewport coverage and run `dart format lib test`, `flutter analyze`, and `flutter test`.

---

### Task 1: Shared visual foundation and navigation shell

**Files:**
- Modify: `lib/app/theme.dart`, `lib/app/app_navigation_shell.dart`
- Create: `lib/shared/presentation/app_surface.dart`
- Test: `test/app/app_navigation_shell_test.dart`

- [ ] Define explicit dark palette, typography, 8px radii, cyan selection color, navigation height and dense card/input styles from the references.
- [ ] Render the four bottom destinations in the approved order and selected state.
- [ ] Add tests asserting labels, order, selection and no Settings destination.

### Task 2: Chat, server and model reference layouts

**Files:**
- Modify: `lib/features/chat/presentation/chat_screen.dart`, `lib/features/chat/presentation/widgets/chat_composer.dart`, `lib/features/servers/presentation/server_screen.dart`, `lib/features/models/presentation/models_screen.dart`
- Test: `test/features/chat/presentation/chat_screen_test.dart`, `test/widget_test.dart`

- [ ] Match the BytePapo header, contextual menu, compact cards, search fields, inline server actions, provider filter, model cards and pagination hierarchy.
- [ ] Keep existing model/server selection and chat send actions wired.
- [ ] Add widget assertions for the visible reference controls.

### Task 3: Settings, character management and editor reference layouts

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`, `lib/features/settings/presentation/widgets/character_list.dart`
- Test: `test/features/settings/presentation/widgets/character_list_test.dart`

- [ ] Build settings hub with global prompt, active character, navigation to management, and the reference action rows.
- [ ] Present character list/editor with circular avatar, search, inline edit/delete and bottom primary action.
- [ ] Preserve photo picker, confirmation and active-character behavior.

### Task 4: Visual QA and regression coverage

**Files:**
- Create: `test/visual/approved_layout_test.dart`
- Modify: relevant tests from Tasks 1-3

- [ ] Pump reference viewport-size screens with representative fake data and assert key layout structure.
- [ ] Capture/inspect the Android viewport when Java/device tooling is available.
- [ ] Run full format, analysis, tests and debug APK build.
