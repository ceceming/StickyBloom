import SwiftUI
import AppKit

struct StickyHeaderView: View {
    @Binding var title: String
    var onClose: () -> Void
    var onDragChanged: (CGSize) -> Void

    var body: some View {
        HStack(spacing: 6) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 10))
                .foregroundStyle(.secondary.opacity(0.5))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            onDragChanged(value.translation)
                        }
                )

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
