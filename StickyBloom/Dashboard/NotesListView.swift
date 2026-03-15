import SwiftUI
import AppKit

/// Transparent NSView that prevents the parent window from treating this area
/// as a draggable background, so SwiftUI's .draggable() gesture fires instead.
private class NonMovableNSView: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

private struct NonMovableBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { NonMovableNSView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// NSTextField that grabs first-responder immediately when added to a window,
/// bypassing SwiftUI @FocusState which doesn't work in non-activating panels.
private class AutoFocusField: NSTextField {
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window else { return }
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(self)
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

private struct ProjectNameField: NSViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> AutoFocusField {
        let field = AutoFocusField()
        field.placeholderString = "Project name…"
        field.isBordered = false
        field.isBezeled = false
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: 12)
        field.focusRingType = .none
        field.delegate = context.coordinator
        field.onCommit = onCommit
        field.onCancel = onCancel
        return field
    }

    func updateNSView(_ nsView: AutoFocusField, context: Context) {
        if nsView.stringValue != text { nsView.stringValue = text }
        nsView.onCommit = onCommit
        nsView.onCancel = onCancel
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: ProjectNameField
        init(_ parent: ProjectNameField) { self.parent = parent }

        func controlTextDidChange(_ obj: Notification) {
            if let f = obj.object as? NSTextField { parent.text = f.stringValue }
        }

        func control(_ control: NSControl, textView: NSTextView,
                     doCommandBy sel: Selector) -> Bool {
            if sel == #selector(NSResponder.insertNewline(_:)) {
                parent.onCommit(); return true
            }
            if sel == #selector(NSResponder.cancelOperation(_:)) {
                parent.onCancel(); return true
            }
            return false
        }
    }
}

struct NotesListView: View {
    @ObservedObject var appState: AppState
    @State private var isUngroupedTargeted = false
    @State private var addProjectController: AddProjectWindowController?

    private var ungroupedNotes: [StickyNoteModel] {
        appState.stickies.filter { $0.projectID == nil }
    }

    private func notes(for project: ProjectModel) -> [StickyNoteModel] {
        appState.stickies.filter { $0.projectID == project.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text("Notes")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    let controller = AddProjectWindowController(appState: appState) { [self] in
                        addProjectController = nil
                    }
                    addProjectController = controller
                    controller.showWindow(nil)
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 2) {
                    // Projects with their notes
                    ForEach(appState.projects) { project in
                        ProjectRowView(project: project, appState: appState)

                        if project.isExpanded {
                            ForEach(notes(for: project)) { sticky in
                                NoteRowView(sticky: sticky, appState: appState)
                                    .padding(.leading, 16)
                            }
                        }
                    }

                    // Ungrouped section header (drop target)
                    HStack {
                        Text("Ungrouped")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isUngroupedTargeted ? Color.accentColor.opacity(0.2) : Color.clear)
                    )
                    .dropDestination(for: StickyTransfer.self) { items, _ in
                        for item in items {
                            appState.assignSticky(id: item.id, toProject: nil)
                        }
                        return true
                    } isTargeted: { targeted in
                        isUngroupedTargeted = targeted
                    }

                    // Ungrouped notes
                    ForEach(ungroupedNotes) { sticky in
                        NoteRowView(sticky: sticky, appState: appState)
                            .padding(.leading, 8)
                    }
                }
            }
            .frame(maxHeight: 180)
            .background(NonMovableBackground())
        }
    }
}
