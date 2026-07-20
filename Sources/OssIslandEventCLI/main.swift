import Foundation
import OssIslandCore

struct Arguments {
    var state: AgentState
    var sessionID = "default"
    var agent = "Agent"
    var title = "Agent update"
    var detail: String?
    var terminal: String?

    init(_ values: [String]) throws {
        guard let first = values.first, let parsedState = AgentState(rawValue: first) else {
            throw CLIError.usage
        }
        state = parsedState

        var index = 1
        while index < values.count {
            guard index + 1 < values.count else { throw CLIError.usage }
            let key = values[index]
            let value = values[index + 1]
            switch key {
            case "--session": sessionID = value
            case "--agent": agent = value
            case "--title": title = value
            case "--detail": detail = value
            case "--terminal": terminal = value
            default: throw CLIError.usage
            }
            index += 2
        }
    }
}

enum CLIError: Error {
    case usage
}

func inboxURL() -> URL {
    if let override = ProcessInfo.processInfo.environment["OSS_ISLAND_INBOX"], !override.isEmpty {
        return URL(fileURLWithPath: NSString(string: override).expandingTildeInPath)
    }
    return FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".oss-island", isDirectory: true)
        .appendingPathComponent("events.ndjson")
}

func append(_ event: AgentEvent, to url: URL) throws {
    let directory = url.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    if !FileManager.default.fileExists(atPath: url.path) {
        FileManager.default.createFile(atPath: url.path, contents: nil)
    }

    let handle = try FileHandle(forWritingTo: url)
    try handle.seekToEnd()
    try handle.write(contentsOf: EventCodec.encodeLine(event))
    try handle.close()
}

do {
    let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
    let event = AgentEvent(
        sessionID: arguments.sessionID,
        agent: arguments.agent,
        title: arguments.title,
        detail: arguments.detail,
        state: arguments.state,
        terminal: arguments.terminal
    )
    try append(event, to: inboxURL())
} catch {
    FileHandle.standardError.write(Data("""
    Usage: oss-island-event <working|waiting|done|error> [options]

      --session <id>      Stable session identifier
      --agent <name>      Agent name, for example Codex
      --title <text>      Short task title
      --detail <text>     Optional current activity
      --terminal <name>   Terminal, iTerm, Ghostty, Warp, WezTerm, Kitty, Alacritty, VSCode, or Cursor

    """.utf8))
    exit(2)
}
