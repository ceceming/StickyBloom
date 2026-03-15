import SwiftUI
import AppKit

struct ProjectRowView: View {
    let project: ProjectModel
    let appState: AppState
    @State private var isHovered = false
    @State private var isTargeted = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: project.isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 12)

            Circle()
                .fill(Color(NSColor(hex: project.colorHex) ?? .systemBlue))
                .frame(width: 10, height: 10)

            Text(project.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()

            if isHovered {
                Button {
                    appState.removeProject(id: project.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isTargeted ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            var updated = project
            updated.isExpanded.toggle()
            appState.updateProject(updated)
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .dropDestination(for: StickyTransfer.self) { items, _ in
            for item in items {
                appState.assignSticky(id: item.id, toProject: project.id)
            }
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }
}
