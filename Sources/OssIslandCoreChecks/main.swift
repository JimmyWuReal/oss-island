import Foundation
import OssIslandCore

enum CheckFailure: Error, CustomStringConvertible {
    case failed(String)

    var description: String {
        switch self {
        case .failed(let message): "Check failed: \(message)"
        }
    }
}

func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else { throw CheckFailure.failed(message) }
}

func checkEventRoundTrip() throws {
    let event = AgentEvent(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        sessionID: "session-1",
        agent: "Codex",
        title: "Set up Oss Island",
        detail: "Running checks",
        state: .working,
        terminal: "Terminal",
        timestamp: Date(timeIntervalSince1970: 1_700_000_000)
    )

    let decoded = EventCodec.decodeLines(try EventCodec.encodeLine(event))
    try require(decoded == [event], "event must survive an NDJSON round trip")
}

func checkInvalidLinesAreSkipped() throws {
    let valid = AgentEvent(
        sessionID: "session-1",
        agent: "Agent",
        title: "Working",
        state: .working,
        timestamp: Date(timeIntervalSince1970: 1_700_000_000)
    )
    var data = Data("not-json\n".utf8)
    data.append(try EventCodec.encodeLine(valid))

    try require(EventCodec.decodeLines(data) == [valid], "invalid lines must not hide later events")
}

func checkReducer() throws {
    let done = AgentEvent(
        sessionID: "done",
        agent: "Agent",
        title: "Finished",
        state: .done,
        timestamp: Date(timeIntervalSince1970: 200)
    )
    let working = AgentEvent(
        sessionID: "active",
        agent: "Agent",
        title: "Working",
        state: .working,
        timestamp: Date(timeIntervalSince1970: 100)
    )
    let updated = AgentEvent(
        sessionID: "active",
        agent: "Agent",
        title: "Waiting",
        state: .waiting,
        timestamp: Date(timeIntervalSince1970: 300)
    )

    var sessions = SessionReducer.applying(done, to: [])
    sessions = SessionReducer.applying(working, to: sessions)
    sessions = SessionReducer.applying(updated, to: sessions)

    try require(sessions.map(\.id) == ["active", "done"], "active sessions must sort first")
    try require(sessions.first?.state == .waiting, "existing sessions must update in place")
    try require(sessions.count == 2, "updates must not duplicate sessions")
}

do {
    try checkEventRoundTrip()
    try checkInvalidLinesAreSkipped()
    try checkReducer()
    print("OssIslandCore checks passed")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
