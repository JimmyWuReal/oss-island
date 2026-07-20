<div align="center">
  <img src="docs/icon.svg" width="112" alt="Oss Island icon">
  <h1>Oss Island</h1>
  <p>A local-first macOS island for your coding agents.</p>

  [Website](https://jimmywureal.github.io/oss-island/) · [Roadmap](ROADMAP.md) · [Contributing](CONTRIBUTING.md)
</div>

> [!IMPORTANT]
> Oss Island is an early development preview. The event protocol, app bundle, and unsigned DMG work today; direct Codex and Claude Code adapters are the next milestone.

Oss Island is an independent, open-source macOS companion for watching local coding agents without leaving your current window. It renders active sessions in a non-activating top-center overlay, keeps data on your Mac, and can jump back to the terminal that owns a session.

Oss Island is not affiliated with Vibe Island. The product and visual identity are independently designed.

## What works

- Native SwiftUI/AppKit menu-bar app for macOS 14+
- Non-activating overlay that works on notched and external displays
- Local newline-delimited JSON event inbox
- Multiple session states: working, waiting, done, and error
- Best-effort terminal activation for Terminal, iTerm2, Ghostty, Warp, WezTerm, Kitty, Alacritty, VS Code, and Cursor
- Demo mode for UI development
- Dependency-free Swift package and core checks
- Ad-hoc-signed, unnotarized DMG packaging for Apple Silicon

The current preview deliberately does not approve agent permissions or answer questions. Those actions need documented, safe adapter contracts; until then, Oss Island focuses the originating terminal.

## Install the development preview

Download the latest DMG from [GitHub Releases](https://github.com/JimmyWuReal/oss-island/releases/latest), drag Oss Island into Applications, then control-click it and choose **Open** on first launch.

The current build is ad-hoc signed but not signed with an Apple Developer ID or notarized. If macOS still blocks it, remove quarantine explicitly:

```bash
xattr -dr com.apple.quarantine "/Applications/Oss Island.app"
```

Only do this for a DMG you downloaded from this repository and whose SHA-256 checksum matches the release.

## Develop

Requirements:

- Apple Silicon Mac running macOS 14 or newer
- Apple Command Line Tools (`xcode-select --install`)
- Swift 6 or newer
- Git

Full Xcode is optional for the current Swift Package Manager workflow.

```bash
git clone https://github.com/JimmyWuReal/oss-island.git
cd oss-island
./scripts/bootstrap.sh
swift run OssIsland
```

The bootstrap runs core checks and creates `dist/Oss-Island-0.1.0-arm64.dmg`.

To install a local build without administrator access:

```bash
./scripts/install-local.sh
open "$HOME/Applications/Oss Island.app"
```

## Send an event

The included CLI appends one event to `~/.oss-island/events.ndjson`:

```bash
swift run oss-island-event working \
  --session setup-1 \
  --agent Codex \
  --title "Set up Oss Island" \
  --detail "Building the release DMG" \
  --terminal Terminal

swift run oss-island-event waiting \
  --session setup-1 \
  --agent Codex \
  --title "Set up Oss Island" \
  --detail "Needs your review" \
  --terminal Terminal

swift run oss-island-event done \
  --session setup-1 \
  --agent Codex \
  --title "Set up Oss Island" \
  --detail "Finished" \
  --terminal Terminal
```

Set `OSS_ISLAND_INBOX` for an isolated inbox during adapter development.

## Event schema

Each line is one JSON object:

```json
{
  "agent": "Codex",
  "detail": "Running checks",
  "id": "50E8C7F1-39C4-4D57-8A16-E23DCF4BB422",
  "sessionID": "setup-1",
  "state": "working",
  "terminal": "Terminal",
  "timestamp": "2026-07-20T20:00:00Z",
  "title": "Set up Oss Island"
}
```

The file transport is intentionally simple and inspectable for the first release. A local socket transport and first-party adapters are tracked in the roadmap.

## Project layout

```text
Sources/OssIsland/           SwiftUI app and AppKit overlay
Sources/OssIslandCore/       Event model, codec, and session reducer
Sources/OssIslandEventCLI/   Local event emitter
Sources/OssIslandCoreChecks/ Dependency-free core checks
packaging/macos/             App bundle metadata
scripts/                     Bootstrap, local install, icon, and DMG tooling
docs/                        GitHub Pages website
```

## Privacy

Oss Island has no accounts, analytics, telemetry, or network service. Agent events are read from a file in your home directory. See [SECURITY.md](SECURITY.md) for the security model and vulnerability reporting.

## License

[MIT](LICENSE) © 2026 Oss Island contributors.
