import SwiftUI

@main
struct PlainPasteApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isEnabled ? "doc.plaintext.fill" : "doc.plaintext")
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Image(systemName: "doc.plaintext.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(appState.isEnabled ? Color.accentColor : Color.secondary)

                Text("Plain Paste")
                    .font(.system(size: 15, weight: .semibold))

                Text(appState.isEnabled ? "All pastes are plain text" : "Paused — formatting preserved")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 14)

            Divider()

            // Toggle
            HStack {
                Toggle(isOn: $appState.isEnabled) {
                    Label("Strip Formatting", systemImage: "textformat.size.smaller")
                        .font(.system(size: 13, weight: .medium))
                }
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Strips today")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Text("\(appState.stripsToday)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("All time")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Text("\(appState.stripsTotal)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Launch at login + Quit
            HStack {
                Toggle(isOn: $appState.launchAtLogin) {
                    Text("Launch at Login")
                        .font(.system(size: 12))
                }
                .toggleStyle(.checkbox)
                .controlSize(.small)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Text("Quit Plain Paste")
                        .font(.system(size: 12))
                    Spacer()
                    Text("\u{2318}Q")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .keyboardShortcut("q", modifiers: .command)
        }
        .frame(width: 240)
    }
}

class AppState: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
            isEnabled ? monitor.start() : monitor.stop()
        }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            // In a shipping app, use SMAppService.mainApp.register()/unregister()
        }
    }
    @Published var stripsToday: Int = 0
    @Published var stripsTotal: Int = 0

    private let monitor = PasteboardMonitor()
    private var countingMonitor: Timer?

    init() {
        self.isEnabled = UserDefaults.standard.object(forKey: "isEnabled") as? Bool ?? true
        self.launchAtLogin = UserDefaults.standard.object(forKey: "launchAtLogin") as? Bool ?? false

        loadStats()

        if isEnabled {
            monitor.start()
        }

        // Track strip counts by watching pasteboard alongside the monitor
        startCountingMonitor()
    }

    private var lastSeenChangeCount: Int = 0

    private func startCountingMonitor() {
        lastSeenChangeCount = NSPasteboard.general.changeCount
        countingMonitor = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isEnabled else { return }
            let current = NSPasteboard.general.changeCount
            // The monitor does 2 changes per strip (clear + set), so detect the jump
            if current > self.lastSeenChangeCount + 1 {
                self.stripsToday += 1
                self.stripsTotal += 1
                self.saveStats()
            }
            self.lastSeenChangeCount = current
        }
    }

    private func loadStats() {
        stripsTotal = UserDefaults.standard.integer(forKey: "stripsTotal")
        let savedDate = UserDefaults.standard.string(forKey: "stripsDate") ?? ""
        let today = todayString()
        if savedDate == today {
            stripsToday = UserDefaults.standard.integer(forKey: "stripsToday")
        } else {
            stripsToday = 0
        }
    }

    private func saveStats() {
        UserDefaults.standard.set(stripsToday, forKey: "stripsToday")
        UserDefaults.standard.set(stripsTotal, forKey: "stripsTotal")
        UserDefaults.standard.set(todayString(), forKey: "stripsDate")
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
