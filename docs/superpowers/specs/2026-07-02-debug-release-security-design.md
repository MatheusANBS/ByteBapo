# Debug/Release Security Design

## Context

The Android manifest currently enables cleartext traffic globally. This is useful for local Ollama servers, but it is too permissive for release builds. Release should prefer HTTPS while still allowing HTTP for LAN/local use after an explicit disclaimer.

## Goals

- Keep HTTP easy in `debug` and `profile`.
- In `release`, allow HTTP only for local/private addresses after explicit user acknowledgement.
- Prefer HTTPS for public or remote access.
- Move Android cleartext policy into build-specific configuration.

## Non-Goals

- Blocking all HTTP in release is not desired.
- Certificate pinning is out of scope.
- Building an in-app VPN is out of scope.

## Android Network Policy

Remove global `android:usesCleartextTraffic="true"` from the main manifest. Add build-specific network security config:

- Debug/profile: cleartext permitted for development.
- Release: cleartext permitted only where Android configuration allows it, with app-level validation enforcing LAN/local hosts before saving or using HTTP servers.

Because Android network security config does not support dynamic arbitrary private IP allowlists cleanly for all user-entered LAN hosts, the app-level validator is the source of truth for release behavior.

## App-Level Validation

Add a security policy service that checks server URLs:

- `https`: allowed.
- `http` in debug/profile: allowed.
- `http` in release: allowed only for private/local hosts after disclaimer acceptance.
- `http` in release for public hosts: rejected.

Private/local hosts include:

- `localhost`
- `127.0.0.0/8`
- `10.0.0.0/8`
- `172.16.0.0/12`
- `192.168.0.0/16`

## UI Behavior

When a release user tries to save or test an HTTP LAN server, show a dialog explaining that HTTP is unencrypted and should only be used on trusted local networks. The acceptance should be stored per server profile.

## Testing

- Unit tests for host classification.
- Unit tests for protocol policy by build mode.
- Widget tests for the disclaimer dialog.
- Existing server validation tests updated for release policy behavior.

## Acceptance Criteria

- Debug/profile still support common LAN Ollama HTTP URLs.
- Release rejects public HTTP URLs.
- Release allows private/local HTTP only after explicit disclaimer acceptance.
- HTTPS remains the recommended path for remote access.
