import SwiftUI
import AppKit

struct NoteRowView: View {
    let sticky: StickyNoteModel
    let appState: AppState

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(NSColor(hex: sticky.backgroundColor) ?? .systemYellow))
                .frame(width: 10, height: 10)

            if sticky.title.isEmpty {
                Text("Untitled")
                    .font(.system(size: 12))
                    .italic()
                    .foregroundStyle(.secondary)
            } else {
                Text(sticky.title)
                    .font(.system(size: 12))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture {
            WindowManager.shared.open(model: sticky, appState: appState)
        }
        .draggable(StickyTransfer(id: sticky.id))
    }
}
