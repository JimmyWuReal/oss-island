import AppKit
import OssIslandCore
import SwiftUI

struct IslandView: View {
    @ObservedObject var model: AppModel
    @State private var expanded = false

    private var activeCount: Int {
        model.sessions.filter(\.state.isActive).count
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(OssPalette.mint.opacity(0.18))
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OssPalette.mint)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 1) {
                    Text("OSS ISLAND")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.2)
                    Text(summaryText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                if let waiting = model.sessions.first(where: { $0.state == .waiting }) {
                    StateBadge(state: waiting.state)
                } else if activeCount > 0 {
                    Text("\(activeCount) LIVE")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(OssPalette.mint)
                }

                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.snappy(duration: 0.25)) { expanded.toggle() } }

            if expanded {
                Divider().overlay(Color.white.opacity(0.08))
                sessionList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .foregroundStyle(Color.white)
        .background(
            RoundedRectangle(cornerRadius: expanded ? 24 : 22, style: .continuous)
                .fill(OssPalette.deep)
                .overlay(
                    RoundedRectangle(cornerRadius: expanded ? 24 : 22, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
        .frame(width: expanded ? 410 : 320, alignment: .top)
        .padding(.top, 2)
        .animation(.snappy(duration: 0.25), value: expanded)
        .onHover { hovering in
            guard hovering, !expanded, !model.sessions.isEmpty else { return }
            withAnimation(.snappy(duration: 0.25)) { expanded = true }
        }
    }

    private var sessionList: some View {
        VStack(spacing: 8) {
            if model.sessions.isEmpty {
                ContentUnavailableView(
                    "The shore is quiet",
                    systemImage: "water.waves",
                    description: Text("Agent events will appear here.")
                )
                .frame(height: 180)
            } else {
                ForEach(model.sessions.prefix(4)) { session in
                    SessionRow(session: session) {
                        model.activateTerminal(for: session)
                    }
                }
            }

            HStack {
                Text("Local only")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                if model.sessions.contains(where: { !$0.state.isActive }) {
                    Button("Clear finished") { model.clearCompleted() }
                        .buttonStyle(.plain)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(OssPalette.sky)
                }
            }
            .padding(.top, 2)
        }
        .padding(12)
        .frame(maxHeight: 286)
    }

    private var summaryText: String {
        if let waiting = model.sessions.first(where: { $0.state == .waiting }) {
            return "\(waiting.agent) needs attention"
        }
        if activeCount > 0 {
            return "\(activeCount) agent\(activeCount == 1 ? "" : "s") working"
        }
        return model.sessions.isEmpty ? "Waiting for agents" : "All caught up"
    }
}

private struct SessionRow: View {
    let session: AgentSession
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 11) {
                Circle()
                    .fill(color.opacity(0.22))
                    .overlay(Circle().fill(color).frame(width: 6, height: 6))
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(session.agent)
                            .font(.system(size: 12, weight: .semibold))
                        Text(session.state.rawValue.uppercased())
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(color)
                    }
                    Text(session.title)
                        .font(.system(size: 12))
                        .lineLimit(1)
                    if let detail = session.detail {
                        Text(detail)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                if session.terminal != nil {
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var color: Color {
        switch session.state {
        case .working: OssPalette.mint
        case .waiting: OssPalette.sun
        case .done: OssPalette.sky
        case .error: OssPalette.coral
        }
    }
}

private struct StateBadge: View {
    let state: AgentState

    var body: some View {
        Text("ATTENTION")
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(OssPalette.deep)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(OssPalette.sun, in: Capsule())
    }
}

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section("Preview") {
                Toggle("Show demo sessions", isOn: $model.isDemoMode)
            }
            Section("Local event inbox") {
                Text(model.inboxURL.path)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                Text("Oss Island watches this newline-delimited JSON file. Nothing is uploaded.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: 280)
    }
}

enum OssPalette {
    static let deep = Color(red: 0.025, green: 0.085, blue: 0.12)
    static let mint = Color(red: 0.31, green: 0.91, blue: 0.72)
    static let sky = Color(red: 0.35, green: 0.72, blue: 0.96)
    static let sun = Color(red: 1.0, green: 0.78, blue: 0.34)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.42)
}
