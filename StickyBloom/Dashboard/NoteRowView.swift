import SwiftUI
import AppKit

struct NoteRowView: View {
    let sticky: StickyNoteModel
    let appState: AppState

    @State private var isEditing = false
    @State private var draftTitle = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(NSColor(hex: sticky.backgroundColor) ?? .systemYellow))
                .frame(width: 10, height: 10)

            if isEditing {
                TextField(sticky.defaultTitle, text: $draftTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.primary)
                    .focused($isFieldFocused)
                    .onSubmit { commitRename() }
                    .onExitCommand { cancelRename() }
                    .onChange(of: isFieldFocused) { focused in
                        if !focused { commitRename() }
                    }
            } else {
                Text(sticky.displayTitle)
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
        .onTapGesture(count: 2) { beginRename() }
        .onTapGesture {
            guard !isEditing else { return }
            WindowManager.shared.open(model: sticky, appState: appState)
        }
        .contextMenu {
            Button("Rename") { beginRename() }
            if sticky.customTitle != nil {
                Button("Reset to Auto Title") {
                    var updated = sticky
                    updated.customTitle = nil
                    appState.updateSticky(updated)
                }
            }
        }
        .draggable(StickyTransfer(id: sticky.id))
    }

    private func beginRename() {
        draftTitle = sticky.customTitle ?? sticky.displayTitle
        isEditing = true
        // Force the dashboard panel to become key — without this the @FocusState
        // assignment is silently dropped on a non-key window.
        if let window = NSApp.windows.first(where: { $0 is DashboardPanel }) {
            window.makeKeyAndOrderFront(nil)
        }
        DispatchQueue.main.async { isFieldFocused = true }
    }

    private func commitRename() {
        guard isEditing else { return }
        var updated = sticky
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.customTitle = trimmed.isEmpty ? nil : trimmed
        appState.updateSticky(updated)
        isEditing = false
    }

    private func cancelRename() {
        isEditing = false
        draftTitle = ""
    }
}
