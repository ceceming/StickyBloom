import AppKit
import SwiftUI

final class AddProjectWindowController: NSWindowController {
    private let onDismiss: () -> Void

    init(appState: AppState, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 100),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "New Project"
        window.center()

        super.init(window: window)

        let view = AddProjectView(
            onAdd: { [weak self] name in
                let trimmed = name.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    Task { @MainActor in
                        appState.addProject(ProjectModel(name: trimmed))
                    }
                }
                self?.close()
                onDismiss()
            },
            onCancel: { [weak self] in
                self?.close()
                onDismiss()
            }
        )
        window.contentView = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) { fatalError() }
}

private struct AddProjectView: View {
    @State private var name = ""
    @FocusState private var focused: Bool
    let onAdd: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("Project name", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .onSubmit { onAdd(name) }
                .onExitCommand { onCancel() }

            HStack {
                Button("Cancel") { onCancel() }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("Add") { onAdd(name) }
                    .keyboardShortcut(.return, modifiers: [])
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .onAppear { focused = true }
    }
}
