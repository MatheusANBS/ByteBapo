# Debug/Release Security Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prefer HTTPS in release while allowing HTTP only for LAN/local hosts after a user disclaimer.

**Architecture:** Move Android cleartext configuration into build-specific resources and add app-level server security validation before save/test/use.

**Tech Stack:** Flutter, Android network security config, Riverpod, widget tests.

---

## File Structure

- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/debug/AndroidManifest.xml`
- Modify: `android/app/src/profile/AndroidManifest.xml`
- Add: `android/app/src/debug/res/xml/network_security_config.xml`
- Add: `android/app/src/profile/res/xml/network_security_config.xml`
- Add: `android/app/src/main/res/xml/network_security_config.xml`
- Add: `lib/core/security/server_security_policy.dart`
- Modify: `lib/features/servers/domain/entities/server_profile.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Add: `test/core/security/server_security_policy_test.dart`
- Add: `test/features/servers/presentation/server_screen_security_test.dart`

### Task 1: Add Security Policy

**Files:**
- Add: `lib/core/security/server_security_policy.dart`
- Add: `test/core/security/server_security_policy_test.dart`

- [ ] Implement host classification.

```dart
enum ServerSecurityDecision { allowed, requiresDisclaimer, blocked }

class ServerSecurityPolicy {
  const ServerSecurityPolicy({required this.isRelease});

  final bool isRelease;

  ServerSecurityDecision evaluate(Uri uri, {required bool disclaimerAccepted}) {
    if (uri.scheme == 'https') return ServerSecurityDecision.allowed;
    if (uri.scheme != 'http') return ServerSecurityDecision.blocked;
    if (!isRelease) return ServerSecurityDecision.allowed;
    if (!_isPrivateOrLocalHost(uri.host)) return ServerSecurityDecision.blocked;
    return disclaimerAccepted
        ? ServerSecurityDecision.allowed
        : ServerSecurityDecision.requiresDisclaimer;
  }
}
```

- [ ] Test localhost, 127.*, 10.*, 172.16-31.*, 192.168.*, public IPs, and domains.

Run:

```powershell
flutter test test/core/security/server_security_policy_test.dart
```

Expected: policy tests pass.

- [ ] Commit.

```powershell
git add lib/core/security test/core/security
git commit -m "feat: add server security policy"
```

### Task 2: Apply Android Cleartext Config

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/debug/AndroidManifest.xml`
- Modify: `android/app/src/profile/AndroidManifest.xml`
- Add: `android/app/src/main/res/xml/network_security_config.xml`
- Add: `android/app/src/debug/res/xml/network_security_config.xml`
- Add: `android/app/src/profile/res/xml/network_security_config.xml`

- [ ] Remove global `android:usesCleartextTraffic="true"` from main manifest.
- [ ] Add `android:networkSecurityConfig="@xml/network_security_config"` to the application element.
- [ ] Set debug/profile config to permit cleartext.
- [ ] Set release/main config to the strictest policy compatible with app-level LAN validation.

Run:

```powershell
flutter analyze
```

Expected: analyzer passes.

- [ ] Commit.

```powershell
git add android/app/src
git commit -m "build: split android network security by build type"
```

### Task 3: Add Disclaimer UI

**Files:**
- Modify: `lib/features/servers/domain/entities/server_profile.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Add: `test/features/servers/presentation/server_screen_security_test.dart`

- [ ] Add a persisted `cleartextDisclaimerAccepted` field to `ServerProfile`.
- [ ] Before saving/testing release HTTP LAN URLs, show a dialog explaining unencrypted local-only HTTP.
- [ ] Reject release public HTTP with a clear validation message.
- [ ] Add widget tests for accept, cancel, and blocked cases.

Run:

```powershell
flutter test test/features/servers
```

Expected: server tests pass.

- [ ] Commit.

```powershell
git add lib/features/servers test/features/servers
git commit -m "feat: require disclaimer for release http lan servers"
```

### Task 4: Full Verification

```powershell
flutter analyze
flutter test
```

Expected: both pass.
