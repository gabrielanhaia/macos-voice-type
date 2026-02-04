import AppKit
import SwiftUI

class FloatingPanel: NSPanel {
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 140, height: 40),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.contentView = contentView
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false

        positionBelowMenuBar()
    }

    func positionBelowMenuBar() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y

        let panelWidth: CGFloat = 140
        let panelHeight: CGFloat = 40
        let topPadding: CGFloat = 8

        let x = (screenFrame.width - panelWidth) / 2
        let y = screenFrame.height - menuBarHeight - panelHeight - topPadding

        setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: true)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

class FloatingPanelController: ObservableObject {
    private var panel: FloatingPanel?
    private var hostingView: NSHostingView<FloatingIndicatorView>?

    func showPanel() {
        if panel == nil {
            let indicatorView = FloatingIndicatorView()
            let hostingView = NSHostingView(rootView: indicatorView)
            hostingView.frame = NSRect(x: 0, y: 0, width: 140, height: 40)
            self.hostingView = hostingView

            panel = FloatingPanel(contentView: hostingView)
        }

        panel?.positionBelowMenuBar()
        panel?.orderFrontRegardless()
    }

    func hidePanel() {
        panel?.orderOut(nil)
    }

    func updateVisibility(isVisible: Bool) {
        if isVisible {
            showPanel()
        } else {
            hidePanel()
        }
    }
}
