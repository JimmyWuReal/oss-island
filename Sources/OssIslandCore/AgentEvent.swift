import Foundation

public enum AgentState: String, Codable, CaseIterable, Sendable {
    case working
    case waiting
    case done
    case error

    public var isActive: Bool {
        self == .working || self == .waiting
    }
}

public struct AgentEvent: Codable, Equatable, Sendable {
    public var id: UUID
    public var sessionID: String
    public var agent: String
    public var title: String
    public var detail: String?
    public var state: AgentState
    public var terminal: String?
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        sessionID: String,
        agent: String,
        title: String,
        detail: String? = nil,
        state: AgentState,
        terminal: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sessionID = sessionID
        self.agent = agent
        self.title = title
        self.detail = detail
        self.state = state
        self.terminal = terminal
        self.timestamp = timestamp
    }
}
