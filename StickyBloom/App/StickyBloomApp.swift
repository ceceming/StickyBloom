import SwiftUI
import AppKit

@main
struct StickyBloomApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No default window — dashboard is managed by AppDelegate
        Settings {
            EmptyView()
        }
    }
}
