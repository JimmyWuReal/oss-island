import Foundation

public struct AgentSession: Identifiable, Equatable, Sendable {
    public var id: String
    public var agent: String
    public var title: String
    public var detail: String?
    public var state: AgentState
    public var terminal: String?
    public var updatedAt: Date

    public init(event: AgentEvent) {
        id = event.sessionID
        agent = event.agent
        title = event.title
        detail = event.detail
        state = event.state
        terminal = event.terminal
        updatedAt = event.timestamp
    }

    public mutating func apply(_ event: AgentEvent) {
        agent = event.agent
        title = event.title
        detail = event.detail
        state = event.state
        terminal = event.terminal ?? terminal
        updatedAt = event.timestamp
    }
}

public enum SessionReducer {
    public static func applying(_ event: AgentEvent, to sessions: [AgentSession]) -> [AgentSession] {
        var result = sessions

        if let index = result.firstIndex(where: { $0.id == event.sessionID }) {
            result[index].apply(event)
        } else {
            result.append(AgentSession(event: event))
        }

        return result.sorted { lhs, rhs in
            if lhs.state.isActive != rhs.state.isActive {
                return lhs.state.isActive
            }
            return lhs.updatedAt > rhs.updatedAt
        }
    }
}
