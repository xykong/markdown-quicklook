import SwiftUI
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {
    private var updater: SPUUpdater?
    private var userDriver: SPUStandardUserDriver?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupUpdateMechanism()
        
        if CommandLine.arguments.contains("--register-only") {
            NSApplication.shared.terminate(nil)
        }
    }
    
    // MARK: - Update Mechanism
    
    private func setupUpdateMechanism() {
        let appPath = Bundle.main.bundlePath
        let isHomebrewInstall = appPath.contains("/opt/homebrew/Caskroom/") ||
                                appPath.contains("/usr/local/Caskroom/") ||
                                appPath.contains("/Applications") && isInstalledViaHomebrew()
        
        if isHomebrewInstall {
            scheduleHomebrewUpdateCheck()
            print("📦 Detected Homebrew installation. Update checks via brew.")
        } else {
            initializeSparkle()
            print("✨ Sparkle auto-updater initialized for DMG installation.")
        }
    }
    
    private func isInstalledViaHomebrew() -> Bool {
        guard let bundlePath = Bundle.main.bundleURL.resolvingSymlinksInPath().path as String? else {
            return false
        }
        return bundlePath.contains("/Caskroom/")
    }
    
    private func initializeSparkle() {
        let hostBundle = Bundle.main
        userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        updater = SPUUpdater(
            hostBundle: hostBundle,
            applicationBundle: hostBundle,
            userDriver: userDriver!,
            delegate: nil
        )
        
        do {
            try updater?.start()
            print("✅ Sparkle updater started successfully")
        } catch {
            print("❌ Failed to start Sparkle: \(error.localizedDescription)")
        }
    }
    
    private func scheduleHomebrewUpdateCheck() {
        let oneWeekInSeconds: TimeInterval = 604800
        Timer.scheduledTimer(withTimeInterval: oneWeekInSeconds, repeats: true) { [weak self] _ in
            self?.checkGitHubVersion()
        }
        
        let initialCheckDelay: TimeInterval = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + initialCheckDelay) { [weak self] in
            self?.checkGitHubVersion()
        }
    }
    
    private func checkGitHubVersion() {
        guard let url = URL(string: "https://api.github.com/repos/xykong/markdown-quicklook/releases/latest") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let latestTag = json["tag_name"] as? String else {
                return
            }
            
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let latestVersion = latestTag.replacingOccurrences(of: "v", with: "")
            
            if self?.isNewerVersion(latestVersion, than: currentVersion) == true {
                DispatchQueue.main.async {
                    self?.showHomebrewUpdateAlert(newVersion: latestVersion)
                }
            }
        }.resume()
    }
    
    private func isNewerVersion(_ new: String, than current: String) -> Bool {
        return new.compare(current, options: .numeric) == .orderedDescending
    }
    
    private func showHomebrewUpdateAlert(newVersion: String) {
        let alert = NSAlert()
        alert.messageText = "发现新版本 \(newVersion)"
        alert.informativeText = """
        您通过 Homebrew 安装了此应用。
        请在终端运行以下命令更新：
        
        brew upgrade markdown-preview-enhanced
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "知道了")
        alert.addButton(withTitle: "复制命令")
        
        if alert.runModal() == .alertSecondButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString("brew upgrade markdown-preview-enhanced", forType: .string)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get the bundled QuickLook extension URL (for debugging)
    func getQuickLookExtensionURL() -> URL? {
        guard let plugInsURL = Bundle.main.builtInPlugInsURL else { return nil }
        let contents = try? FileManager.default.contentsOfDirectory(
            at: plugInsURL,
            includingPropertiesForKeys: nil
        )
        return contents?.first(where: { $0.pathExtension == "appex" })
    }
}

@main
struct MarkdownApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var preference = AppearancePreference.shared
    
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            MarkdownWebView(content: file.document.text, fileURL: file.fileURL, appearanceMode: preference.currentMode)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity,
                       minHeight: 600, idealHeight: 800, maxHeight: .infinity)
                .environmentObject(preference)
                .background(WindowAccessor())
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: appDelegate.updater)
            }
            
            CommandMenu("View") {
                Menu("Appearance") {
                    ForEach(AppearanceMode.allCases) { mode in
                        Button(action: {
                            preference.currentMode = mode
                        }) {
                            HStack {
                                Text(mode.displayName)
                                if preference.currentMode == mode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CheckForUpdatesView: View {
    let updater: SPUUpdater?
    
    var body: some View {
        if updater != nil {
            Button("检查更新...") {
                updater?.checkForUpdates()
            }
            .keyboardShortcut("u", modifiers: .command)
            Divider()
        }
    }
}
