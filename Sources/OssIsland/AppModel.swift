import AppKit
import Foundation
import OssIslandCore

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var sessions: [AgentSession] = []
    @Published var isDemoMode = false {
        didSet {
            if isDemoMode {
                loadDemoSessions()
            } else {
                sessions.removeAll { $0.id.hasPrefix("demo-") }
            }
        }
    }
    @Published private(set) var lastReadError: String?

    let inboxURL: URL
    private var timer: Timer?
    private var readOffset: UInt64 = 0

    init(inboxURL: URL = EventInbox.defaultURL) {
        self.inboxURL = inboxURL
    }

    func start() {
        EventInbox.prepare(at: inboxURL)
        pollInbox()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollInbox()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func clearCompleted() {
        sessions.removeAll { !$0.state.isActive }
    }

    func activateTerminal(for session: AgentSession) {
        guard let terminal = session.terminal else { return }
        TerminalLauncher.activate(named: terminal)
    }

    private func pollInbox() {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: inboxURL.path)
            let fileSize = (attributes[.size] as? NSNumber)?.uint64Value ?? 0
            if fileSize < readOffset {
                readOffset = 0
            }
            guard fileSize > readOffset else { return }

            let handle = try FileHandle(forReadingFrom: inboxURL)
            try handle.seek(toOffset: readOffset)
            let data = try handle.readToEnd() ?? Data()
            try handle.close()
            readOffset += UInt64(data.count)

            for event in EventCodec.decodeLines(data) {
                sessions = SessionReducer.applying(event, to: sessions)
            }
            lastReadError = nil
        } catch {
            lastReadError = error.localizedDescription
        }
    }

    private func loadDemoSessions() {
        let events = [
            AgentEvent(
                sessionID: "demo-codex",
                agent: "Codex",
                title: "Build the settings screen",
                detail: "Running Swift tests",
                state: .working,
                terminal: "Terminal"
            ),
            AgentEvent(
                sessionID: "demo-claude",
                agent: "Claude Code",
                title: "Review the event adapter",
                detail: "Needs your attention",
                state: .waiting,
                terminal: "iTerm"
            ),
            AgentEvent(
                sessionID: "demo-local",
                agent: "Local agent",
                title: "Refresh documentation",
                detail: "Finished successfully",
                state: .done,
                terminal: "Ghostty"
            )
        ]

        for event in events {
            sessions = SessionReducer.applying(event, to: sessions)
        }
    }
}

enum EventInbox {
    static var defaultURL: URL {
        if let override = ProcessInfo.processInfo.environment["OSS_ISLAND_INBOX"], !override.isEmpty {
            return URL(fileURLWithPath: NSString(string: override).expandingTildeInPath)
        }
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".oss-island", isDirectory: true)
            .appendingPathComponent("events.ndjson")
    }

    static func prepare(at url: URL) {
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
    }
}

@MainActor
enum TerminalLauncher {
    private static let bundleIdentifiers: [String: String] = [
        "terminal": "com.apple.Terminal",
        "iterm": "com.googlecode.iterm2",
        "iterm2": "com.googlecode.iterm2",
        "ghostty": "com.mitchellh.ghostty",
        "warp": "dev.warp.Warp-Stable",
        "wezterm": "com.github.wez.wezterm",
        "kitty": "net.kovidgoyal.kitty",
        "alacritty": "org.alacritty",
        "vscode": "com.microsoft.VSCode",
        "cursor": "com.todesktop.230313mzl4w4u92"
    ]

    static func activate(named name: String) {
        guard let identifier = bundleIdentifiers[name.lowercased()],
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier)
        else { return }

        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
}
