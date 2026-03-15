import SwiftUI
import AppKit

struct StickyHeaderView: View {
    @Binding var title: String
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            // Drag handle — uses native AppKit performDrag so it works on nonactivatingPanel
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 10))
                .foregroundStyle(.secondary.opacity(0.5))
                .frame(width: 20, height: 24)
                .contentShape(Rectangle())
                .overlay(WindowDragArea())

            // Title field
            TextField("Title...", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

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
        .padding(.vertical, 6)
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
