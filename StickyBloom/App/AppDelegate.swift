import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var appState: AppState!
    let windowManager = WindowManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = AppState()

        // Show dashboard
        windowManager.showDashboard(appState: appState)

        // Restore saved stickies
        windowManager.restoreAllStickies(appState: appState)

        setupMenuBar()

        // Activate app
        NSApp.setActivationPolicy(.regular)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowManager.showDashboard(appState: appState)
        return true
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(NSMenuItem(title: "About StickyBloom", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Quit StickyBloom", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(NSMenuItem(title: "New Sticky", action: #selector(newSticky), keyEquivalent: "n"))
        fileMenu.addItem(NSMenuItem(title: "Show Dashboard", action: #selector(showDashboard), keyEquivalent: "d"))

        NSApp.mainMenu = mainMenu
    }

    @objc private func newSticky() {
        windowManager.createNewSticky(appState: appState)
    }

    @objc private func showDashboard() {
        windowManager.showDashboard(appState: appState)
    }
}
