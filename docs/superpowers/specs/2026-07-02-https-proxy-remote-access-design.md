# HTTPS Proxy Remote Access Design

## Context

BytePapo currently connects directly to Ollama via configured HTTP or HTTPS URLs. Users who want access outside the LAN need a safer remote access path. The first implementation should support an HTTPS proxy URL with optional custom authorization header stored securely.

## Goals

- Support normal `https://...` server URLs for reverse proxies and tunnels.
- Allow one custom header name and value per server profile.
- Store header secret values in `flutter_secure_storage`.
- Document remote access options such as reverse proxy, Cloudflare Tunnel, Tailscale, or ZeroTier.

## Non-Goals

- Managing VPN connections inside the app is out of scope.
- Multiple headers per server are out of scope for the first version.
- Certificate pinning and custom CA management are out of scope.

## Data Design

`ServerProfile` should store non-secret connection metadata:

- protocol, host, port, base path;
- optional auth header name;
- boolean indicating whether a secure value exists.

The secret header value should be stored under a key derived from the server id, such as `server.<id>.auth_header_value`, using `flutter_secure_storage`.

When an existing profile is deleted, its secure value must be deleted too.

## Runtime Behavior

`OllamaApiClient` should receive request headers from a resolver that can combine:

- static non-secret profile headers, if retained;
- secure auth header from secure storage.

The UI should label this as an optional proxy/auth header, not as an Ollama feature. It should allow custom names such as `Authorization`, `X-Api-Key`, or `CF-Access-Client-Secret`.

## Documentation

Add docs for:

- using Caddy/Nginx as HTTPS reverse proxy;
- using Cloudflare Tunnel;
- using Tailscale/ZeroTier as VPN alternatives;
- why exposing Ollama directly to the internet is discouraged;
- how to choose HTTPS over HTTP outside LAN.

## Testing

- Unit tests for secure header storage.
- Repository tests verifying delete cleans up secure values.
- Network tests verifying headers are sent for list models and chat streaming.
- Widget tests for custom header name/value inputs.

## Acceptance Criteria

- A user can save an HTTPS server with a custom header name/value.
- Secret values are not stored in `SharedPreferences` or Drift.
- Requests to Ollama include the resolved custom header.
- Remote access docs explain proxy/VPN options and risks.
