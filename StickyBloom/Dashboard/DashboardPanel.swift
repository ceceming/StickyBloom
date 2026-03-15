import AppKit
import SwiftUI

final class DashboardPanel: NSPanel {
    private var hostingView: NSHostingView<DashboardView>?

    init(appState: AppState) {
        let savedFrame = appState.dashboardSettings.frame.cgRect
        super.init(
            contentRect: savedFrame,
            styleMask: [.nonactivatingPanel, .borderless, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .normal
        isMovableByWindowBackground = true
        collectionBehavior = [.stationary, .ignoresCycle]

        let view = DashboardView(appState: appState)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: savedFrame.size)
        contentView = hosting
        self.hostingView = hosting

        // Save frame on move/resize
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(frameDidChange),
            name: NSWindow.didMoveNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(frameDidChange),
            name: NSWindow.didResizeNotification,
            object: self
        )

        self.appState = appState
    }

    private weak var appState: AppState?

    @objc private func frameDidChange() {
        guard let appState else { return }
        Task { @MainActor in
            appState.dashboardSettings.frame = CGRectCodable(self.frame)
        }
    }
}
