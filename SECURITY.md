# Security policy

## Supported versions

Oss Island is pre-1.0. Security fixes are applied to the latest release only.

## Report a vulnerability

Do not open a public issue for a vulnerability. Use [GitHub private vulnerability reporting](https://github.com/JimmyWuReal/oss-island/security/advisories/new). Include affected versions, reproduction steps, impact, and any suggested mitigation.

## Current security model

- Events stay on the local Mac and are read from `~/.oss-island/events.ndjson` by default.
- The preview performs no network requests and includes no analytics or telemetry.
- The event inbox is untrusted input. Malformed lines are skipped.
- Terminal activation opens a known application by bundle identifier. The preview does not inject commands or keystrokes.
- Releases are ad-hoc signed and not notarized. Verify the published SHA-256 checksum before bypassing Gatekeeper.

The file inbox is a development protocol, not an authorization boundary. Do not place secrets in event titles or details. Future interactive adapters must authenticate local peers and protect approval responses against confused-deputy attacks.
