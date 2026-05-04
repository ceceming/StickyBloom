import AppKit
import Foundation

@MainActor
final class WindowManager: ObservableObject {
    static let shared = WindowManager()

    private var controllers: [UUID: StickyWindowController] = [:]
    private var dashboardPanel: DashboardPanel?
    private var colorPickerControllers: [ColorPickerDialogWindowController] = []

    private init() {}

    // MARK: - Dashboard

    func showDashboard(appState: AppState) {
        if let existing = dashboardPanel {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let panel = DashboardPanel(appState: appState)
        dashboardPanel = panel
        panel.makeKeyAndOrderFront(nil)
    }

    // MARK: - Sticky Notes

    func createNewSticky(appState: AppState) {
        var picker: ColorPickerDialogWindowController?
        picker = ColorPickerDialogWindowController(appState: appState, windowManager: self) { [weak self] in
            guard let self, let p = picker else { return }
            self.colorPickerControllers.removeAll { $0 === p }
        }
        if let picker { colorPickerControllers.append(picker) }
        picker?.showWindow(nil)
    }

    func open(model: StickyNoteModel, appState: AppState, autoFocus: Bool = false) {
        if let existing = controllers[model.id] {
            existing.window?.makeKeyAndOrderFront(nil)
            return
        }
        let controller = StickyWindowController(model: model, appState: appState, windowManager: self)
        controllers[model.id] = controller
        if autoFocus {
            // .nonactivatingPanel won't auto-promote a click into firstResponder
            // for the inner NSTextView, leaving newly-spawned stickies un-typeable
            // until the user clicks twice. Force key + firstResponder once the
            // hosting view has had a runloop tick to materialize the text view.
            controller.window?.makeKeyAndOrderFront(nil)
            DispatchQueue.main.async { [weak controller] in
                guard let w = controller?.window,
                      let tv = w.contentView?.findSubview(ofType: MentionAwareTextView.self)
                else { return }
                w.makeFirstResponder(tv)
            }
        } else {
            controller.showWindow(nil)
        }
    }

    func close(stickyID: UUID) {
        controllers[stickyID]?.close()
        controllers.removeValue(forKey: stickyID)
    }

    func bringToFront(stickyID: UUID) {
        guard let controller = controllers[stickyID], let window = controller.window else { return }
        window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue + 1)
        window.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            window.level = .normal
        }
    }

    func restoreAllStickies(appState: AppState) {
        for model in appState.stickies {
            open(model: model, appState: appState)
        }
    }

    func isOpen(stickyID: UUID) -> Bool {
        controllers[stickyID] != nil
    }
}
