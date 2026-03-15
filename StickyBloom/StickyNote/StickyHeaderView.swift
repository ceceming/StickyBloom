import SwiftUI
import AppKit

struct StickyHeaderView: View {
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 10))
                .foregroundStyle(.secondary.opacity(0.5))
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
                .overlay(WindowDragArea())

            Spacer()
                .overlay(WindowDragArea())

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.7)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}

// MARK: - Native Window Drag

private struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> DragView { DragView() }
    func updateNSView(_ nsView: DragView, context: Context) {}

    final class DragView: NSView {
        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
        override var acceptsFirstResponder: Bool { false }
    }
}

/// Overlays a view. Clicks pass through to the view underneath; drags move the window.
struct ClickThroughWindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> ClickThroughDragView { ClickThroughDragView() }
    func updateNSView(_ nsView: ClickThroughDragView, context: Context) {}

    final class ClickThroughDragView: NSView {
        private let dragThreshold: CGFloat = 4

        override func mouseDown(with event: NSEvent) {
            let origin = event.locationInWindow
            // Peek at subsequent events to decide: click or drag
            while let next = window?.nextEvent(matching: [.leftMouseDragged, .leftMouseUp],
                                               until: .distantFuture,
                                               inMode: .default,
                                               dequeue: true) {
                if next.type == .leftMouseUp {
                    // It was a click — forward original mouseDown then mouseUp to next responder
                    nextResponder?.mouseDown(with: event)
                    nextResponder?.mouseUp(with: next)
                    return
                }
                let dx = next.locationInWindow.x - origin.x
                let dy = next.locationInWindow.y - origin.y
                if dx * dx + dy * dy > dragThreshold * dragThreshold {
                    // It was a drag — hand off to window drag
                    window?.performDrag(with: event)
                    return
                }
            }
        }

        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
        override var acceptsFirstResponder: Bool { false }
    }
}
