import SwiftUI
import AppKit
import Combine

@main
struct VoiceTypeIndicatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController?
    private var cancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panelController = FloatingPanelController()

        NotificationListener.shared.startListening()

        cancellable = IndicatorStateManager.shared.$isVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.panelController?.updateVisibility(isVisible: isVisible)
            }
    }

    func applicationWillTerminate(_ notification: Notification) {
        NotificationListener.shared.stopListening()
    }
}
