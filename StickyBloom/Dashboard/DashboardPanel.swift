import AppKit
import SwiftUI

final class DashboardPanel: NSPanel {
    private var hostingView: NSHostingView<DashboardView>?
    private static let collapsedHeight: CGFloat = 860
    private static let settingsHeight: CGFloat = 180

    init(appState: AppState) {
        var savedFrame = appState.dashboardSettings.frame.cgRect
        // Always start at collapsed height so saved expanded-state doesn't persist
        savedFrame.size.height = DashboardPanel.collapsedHeight
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
        collectionBehavior = [.managed, .ignoresCycle]

        var view = DashboardView(appState: appState)
        view.onSettingsToggled = { [weak self] show in
            self?.animateResize(showSettings: show)
        }
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

    private func animateResize(showSettings: Bool) {
        let targetHeight = showSettings
            ? DashboardPanel.collapsedHeight + DashboardPanel.settingsHeight
            : DashboardPanel.collapsedHeight
        var newFrame = frame
        // Keep the top edge fixed; expand/collapse downward
        newFrame.origin.y = newFrame.origin.y + newFrame.size.height - targetHeight
        newFrame.size.height = targetHeight
        setFrame(newFrame, display: true, animate: true)
    }
}
