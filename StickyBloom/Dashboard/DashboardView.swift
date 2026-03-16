import SwiftUI
import AppKit

struct DashboardView: View {
    @ObservedObject var appState: AppState
    @StateObject private var locationService = LocationService()
    @State private var showSettings = false
    var onSettingsToggled: ((Bool) -> Void)?

    private var tintColor: Color {
        Color(NSColor(hex: appState.dashboardSettings.backgroundColor) ?? .darkGray)
    }

    var body: some View {
        ZStack {
            // Glass background with tint
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 24)
                .fill(tintColor.opacity(appState.dashboardSettings.opacity * 0.4))

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("StickyBloom")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        showSettings.toggle()
                        onSettingsToggled?(showSettings)
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 14))
                            .rotationEffect(.degrees(showSettings ? 45 : 0))
                            .animation(.easeInOut(duration: 0.2), value: showSettings)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(showSettings ? .primary : .secondary)
                }

                // Clock
                ClockView()

                Divider().opacity(0.3)

                // Plant animation
                PlantAnimationView()
                    .frame(height: 200)
                    .padding(.top, -10)

                Divider().opacity(0.3)

                // New sticky button
                Button {
                    WindowManager.shared.createNewSticky(appState: appState)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Sticky")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)

                Divider().opacity(0.3)

                NotesListView(appState: appState)

                if showSettings {
                    Divider().opacity(0.3)
                    DashboardSettingsView(appState: appState)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            locationService.startUpdating()
        }
    }
}
