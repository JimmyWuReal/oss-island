import AppKit
import SwiftUI

@main
struct OssIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Oss Island", systemImage: "water.waves") {
            VStack(alignment: .leading, spacing: 12) {
                Text("OSS ISLAND")
                    .font(.system(size: 12, weight: .bold, design: .rounded))

                Text(appDelegate.model.sessions.isEmpty
                     ? "No agent sessions yet"
                     : "\(appDelegate.model.sessions.count) recent session(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Button("Show or hide island") {
                    appDelegate.panelController?.toggle()
                }
                Toggle(
                    "Demo sessions",
                    isOn: Binding(
                        get: { appDelegate.model.isDemoMode },
                        set: { appDelegate.model.isDemoMode = $0 }
                    )
                )
                SettingsLink { Text("Settings…") }

                Divider()

                Button("Quit Oss Island") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(12)
            .frame(width: 240)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: appDelegate.model)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()
    var panelController: IslandPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        model.start()
        panelController = IslandPanelController(model: model)
        panelController?.show()
    }

    func applicationWillTerminate(_ notification: Notification) {
        model.stop()
    }
}
