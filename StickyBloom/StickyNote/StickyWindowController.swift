import AppKit
import SwiftUI

final class StickyWindowController: NSWindowController {
    private let stickyID: UUID
    private weak var appState: AppState?
    private weak var windowManager: WindowManager?

    init(model: StickyNoteModel, appState: AppState, windowManager: WindowManager) {
        self.stickyID = model.id
        self.appState = appState
        self.windowManager = windowManager

        let panel = StickyPanel(frame: model.frame.cgRect)
        panel.stickyID = model.id

        super.init(window: panel)

        let proxy = WindowProxy(panel)
        let stickyView = StickyView(
            appState: appState,
            stickyID: model.id,
            windowManager: windowManager,
            windowProxy: proxy
        )
        let hosting = NSHostingView(rootView: stickyView)
        panel.contentView = hosting

        // Save frame on move/resize
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: panel
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: panel
        )
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func windowDidMove() { saveFrame() }
    @objc private func windowDidResize() { saveFrame() }

    private func saveFrame() {
        guard let window, let appState else { return }
        let frame = window.frame
        let id = stickyID
        Task { @MainActor in
            if var model = appState.sticky(for: id) {
                model.frame = CGRectCodable(frame)
                appState.updateSticky(model)
            }
        }
    }
}
