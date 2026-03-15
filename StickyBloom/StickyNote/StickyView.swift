import SwiftUI
import AppKit

/// Holds a weak reference to the window (avoids retain cycle in struct).
final class WindowProxy {
    weak var window: NSWindow?
    init(_ window: NSWindow) { self.window = window }
}

struct StickyView: View {
    @ObservedObject var appState: AppState
    let stickyID: UUID
    let windowManager: WindowManager
    let windowProxy: WindowProxy

    @State private var attributedText: NSAttributedString = NSAttributedString()
    @State private var title: String = ""

    private var model: StickyNoteModel? {
        appState.sticky(for: stickyID)
    }

    private var backgroundColor: Color {
        guard let model else { return .yellow }
        return Color(NSColor(hex: model.backgroundColor) ?? .systemYellow)
    }

    var body: some View {
        ZStack {
            // Background: .regularMaterial + tinted overlay
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)

            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor.opacity(model?.backgroundOpacity ?? 0.75))

            VStack(spacing: 0) {
                // Header
                StickyHeaderView(
                    title: $title,
                    onClose: {
                        appState.removeSticky(id: stickyID)
                        windowManager.close(stickyID: stickyID)
                    },
                    onDragChanged: { delta in
                        guard let window = windowProxy.window else { return }
                        var origin = window.frame.origin
                        origin.x += delta.width
                        origin.y -= delta.height  // macOS Y is inverted from SwiftUI
                        window.setFrameOrigin(origin)
                    }
                )
                .onChange(of: title) { newTitle in
                    updateModel { $0.title = newTitle }
                }

                Divider().opacity(0.3)

                // Toolbar
                StickyToolbarView(textView: {
                    windowProxy.window?.contentView?.findSubview(ofType: MentionAwareTextView.self)
                })
                .frame(height: 32)

                Divider().opacity(0.3)

                // Rich text editor
                RichTextEditor(
                    attributedText: $attributedText,
                    appState: appState,
                    stickyID: stickyID,
                    onMentionClicked: { uuid in
                        windowManager.bringToFront(stickyID: uuid)
                    }
                )
                .onChange(of: attributedText) { newText in
                    guard let rtf = newText.rtfData else { return }
                    updateModel {
                        $0.rtfData = rtf
                        $0.modifiedAt = Date()
                    }
                }

                // Corner resize handles
                CornerResizeHandlesView(windowProxy: windowProxy)
                    .frame(height: 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        .onAppear {
            let m = appState.sticky(for: stickyID)
            if let m {
                title = m.title
                if !m.rtfData.isEmpty,
                   let attrStr = NSAttributedString(rtfData: m.rtfData) {
                    attributedText = attrStr
                }
            }
            // Save initial frame
            if let w = windowProxy.window, var current = appState.sticky(for: stickyID) {
                current.frame = CGRectCodable(w.frame)
                appState.updateSticky(current)
            }
        }
    }

    private func updateModel(_ mutate: (inout StickyNoteModel) -> Void) {
        guard var m = appState.sticky(for: stickyID) else { return }
        mutate(&m)
        appState.updateSticky(m)
    }
}

// MARK: - Corner Resize Handles

struct CornerResizeHandlesView: View {
    let windowProxy: WindowProxy

    var body: some View {
        HStack {
            // Bottom-left: drag left/right adjusts left edge; drag down expands bottom
            ResizeHandle(icon: "arrow.up.left.and.arrow.down.right") { delta in
                resize(dx: delta.width, dy: -delta.height, dw: -delta.width, dh: delta.height)
            }
            Spacer()
            // Bottom-right: drag left/right adjusts right edge; drag down expands bottom
            ResizeHandle(icon: "arrow.up.right.and.arrow.down.left") { delta in
                resize(dx: 0, dy: -delta.height, dw: delta.width, dh: delta.height)
            }
        }
    }

    private func resize(dx: CGFloat, dy: CGFloat, dw: CGFloat, dh: CGFloat) {
        guard let window = windowProxy.window else { return }
        var frame = window.frame
        let newWidth = frame.size.width + dw
        let newHeight = frame.size.height + dh
        if newWidth >= 200 {
            frame.origin.x += dx
            frame.size.width = newWidth
        }
        if newHeight >= 160 {
            frame.origin.y += dy
            frame.size.height = newHeight
        }
        window.setFrame(frame, display: true, animate: false)
    }
}

private struct ResizeHandle: View {
    let icon: String
    let onDrag: (CGSize) -> Void

    @State private var lastTranslation: CGSize = .zero

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 8))
            .foregroundStyle(.secondary.opacity(0.4))
            .frame(width: 16, height: 16)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = CGSize(
                            width: value.translation.width - lastTranslation.width,
                            height: value.translation.height - lastTranslation.height
                        )
                        lastTranslation = value.translation
                        onDrag(delta)
                    }
                    .onEnded { _ in
                        lastTranslation = .zero
                    }
            )
    }
}

// MARK: - NSView subview search

extension NSView {
    func findSubview<T: NSView>(ofType type: T.Type) -> T? {
        if let casted = self as? T { return casted }
        for sub in subviews {
            if let found = sub.findSubview(ofType: type) { return found }
        }
        return nil
    }
}
