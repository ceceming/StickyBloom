import SwiftUI
import AppKit

struct ColorPickerDialogView: View {
    @Environment(\.dismiss) var dismiss
    var onColorSelected: (String) -> Void

    private let presets: [(name: String, hex: String)] = [
        ("Sunny", "#FFE066"),
        ("Mint", "#A8F0C6"),
        ("Sky", "#A8D8F0"),
        ("Lavender", "#D4A8F0"),
        ("Peach", "#F0C4A8"),
        ("Rose", "#F0A8B8"),
        ("Sage", "#B8D4A8"),
        ("Cream", "#F5F0E0"),
    ]

    @State private var customColor = Color.yellow

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose a Color")
                .font(.headline)

            // Preset grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(presets, id: \.hex) { preset in
                    Button {
                        onColorSelected(preset.hex)
                        dismiss()
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor(hex: preset.hex) ?? .systemYellow))
                            .frame(height: 44)
                            .overlay(
                                Text(preset.name)
                                    .font(.caption2)
                                    .foregroundStyle(.primary.opacity(0.6))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            HStack {
                ColorPicker("Custom", selection: $customColor, supportsOpacity: false)
                Spacer()
                Button("Use Custom") {
                    if let ns = NSColor(customColor).usingColorSpace(.sRGB) {
                        onColorSelected(ns.hexString)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Cancel") { dismiss() }
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 300)
    }
}

// MARK: - Window controller for color picker dialog

final class ColorPickerDialogWindowController: NSWindowController {
    private let onDismiss: (() -> Void)?

    init(appState: AppState, windowManager: WindowManager, onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "New Sticky Note"
        window.center()

        super.init(window: window)

        let view = ColorPickerDialogView { [weak window] hex in
            Task { @MainActor in
                let model = StickyNoteModel(backgroundColor: hex)
                appState.addSticky(model)
                windowManager.open(model: model, appState: appState, autoFocus: true)
                window?.close()
                onDismiss?()
            }
        }
        window.contentView = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) { fatalError() }
}
