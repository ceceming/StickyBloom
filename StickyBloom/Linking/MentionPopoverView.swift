import SwiftUI
import AppKit

struct MentionPopoverView: View {
    let candidates: [StickyNoteModel]
    let onSelect: (StickyNoteModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(candidates) { sticky in
                Button {
                    onSelect(sticky)
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(NSColor(hex: sticky.backgroundColor) ?? .systemYellow))
                            .frame(width: 10, height: 10)
                        Text(sticky.title.isEmpty ? "Untitled" : sticky.title)
                            .font(.system(size: 13))
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(Color.clear)

                if sticky.id != candidates.last?.id {
                    Divider()
                }
            }
        }
        .frame(minWidth: 180)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

/// Manages the @mention autocomplete NSPopover
@MainActor
final class MentionPopoverController {
    private var popover: NSPopover?

    func show(
        candidates: [StickyNoteModel],
        relativeTo rect: NSRect,
        of view: NSView,
        onSelect: @escaping (StickyNoteModel) -> Void
    ) {
        dismiss()
        guard !candidates.isEmpty else { return }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false

        let content = MentionPopoverView(candidates: candidates, onSelect: { [weak self] sticky in
            self?.dismiss()
            onSelect(sticky)
        })
        popover.contentViewController = NSHostingController(rootView: content)
        popover.show(relativeTo: rect, of: view, preferredEdge: .minY)
        self.popover = popover
    }

    func dismiss() {
        popover?.close()
        popover = nil
    }

    var isShowing: Bool { popover != nil }
}
