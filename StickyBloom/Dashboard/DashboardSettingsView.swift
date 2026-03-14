import SwiftUI
import AppKit

struct DashboardSettingsView: View {
    @ObservedObject var appState: AppState
    @State private var showTimezonePicker = false
    @State private var pickedColor: Color

    init(appState: AppState) {
        self.appState = appState
        _pickedColor = State(initialValue: Color(NSColor(hex: appState.dashboardSettings.backgroundColor) ?? .darkGray))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dashboard Settings")
                .font(.headline)
                .padding(.bottom, 4)

            HStack {
                Text("Background")
                Spacer()
                ColorPicker("", selection: $pickedColor, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: pickedColor) { color in
                        let nsColor = NSColor(color)
                        if let srgb = nsColor.usingColorSpace(.sRGB) {
                            appState.dashboardSettings.backgroundColor = srgb.hexString
                        }
                    }
            }

            HStack {
                Text("Opacity")
                Spacer()
                Slider(
                    value: $appState.dashboardSettings.opacity,
                    in: 0.3...1.0,
                    step: 0.05
                )
                .frame(width: 120)
                Text(String(format: "%.0f%%", appState.dashboardSettings.opacity * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .trailing)
            }

            HStack {
                Text("Second Timezone")
                Spacer()
                Button {
                    showTimezonePicker = true
                } label: {
                    Text(appState.dashboardSettings.secondTimezoneIdentifier.flatMap {
                        TimeZone(identifier: $0)?.displayName
                    } ?? "None")
                    .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .sheet(isPresented: $showTimezonePicker) {
            SecondTimezonePickerView(
                selectedIdentifier: $appState.dashboardSettings.secondTimezoneIdentifier
            )
        }
    }
}
