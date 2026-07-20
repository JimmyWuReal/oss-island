# Roadmap

Oss Island is being built in small, auditable layers. Reliability and local control take priority over adapter count.

## 0.1 — Foundation

- [x] Native top-center overlay and menu-bar app
- [x] Local event format and file inbox
- [x] Session list, state changes, and terminal activation
- [x] Apple Silicon app bundle and unsigned DMG
- [x] GitHub Pages, CI, and tagged-release automation

## 0.2 — Agent adapters

- [ ] Versioned adapter protocol
- [ ] Codex CLI adapter with install, repair, and uninstall commands
- [ ] Claude Code adapter with install, repair, and uninstall commands
- [ ] Notifications and configurable sounds
- [ ] Launch-at-login setting

## 0.3 — Safe interaction

- [ ] Permission request presentation
- [ ] Answer routing where the upstream agent exposes a safe API
- [ ] Markdown plan preview
- [ ] Precise terminal tab/pane routing for documented integrations

## Later

- More coding-agent adapters
- Remote-session relay
- Signed and notarized releases
- Universal binaries when Intel demand justifies the added release surface
- Optional Sparkle or Homebrew Cask update channel

Approval automation, quota scraping, and undocumented private APIs will not ship merely to match a feature checklist. Each integration needs an explicit threat model and a maintainable upstream contract.
