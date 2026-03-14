import AppKit

final class StickyPanel: NSPanel {
    var stickyID: UUID?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(frame: CGRect) {
        super.init(
            contentRect: frame,
            styleMask: [.borderless, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        isMovableByWindowBackground = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        minSize = CGSize(width: 200, height: 160)
    }
}
