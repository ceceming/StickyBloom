import SwiftUI
import AppKit

struct DashboardSettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var locationService: LocationService
    @State private var showPrimaryTimezonePicker = false
    @State private var showSecondTimezonePicker = false
    @State private var pickedColor: Color
    @State private var primaryCityDraft: String

    init(appState: AppState, locationService: LocationService) {
        self.appState = appState
        self.locationService = locationService
        _pickedColor = State(initialValue: Color(NSColor(hex: appState.dashboardSettings.backgroundColor) ?? .darkGray))
        _primaryCityDraft = State(initialValue: appState.dashboardSettings.primaryCityName ?? "")
    }

    private var primaryTimezoneLabel: String {
        if let id = appState.dashboardSettings.primaryTimezoneIdentifier,
           let tz = TimeZone(identifier: id) {
            return tz.displayName
        }
        if let id = locationService.detectedTimeZoneIdentifier,
           let tz = TimeZone(identifier: id) {
            return "Detected · \(tz.displayName)"
        }
        return "Detected · \(TimeZone.current.displayName)"
    }

    private var detectedCityPlaceholder: String {
        locationService.cityName ?? "Detected city"
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

            Divider()

            HStack {
                Text("Primary Timezone")
                Spacer()
                Button {
                    showPrimaryTimezonePicker = true
                } label: {
                    Text(primaryTimezoneLabel)
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Text("Primary City")
                Spacer()
                TextField(detectedCityPlaceholder, text: $primaryCityDraft)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 160)
                    .onSubmit { commitPrimaryCity() }
                    .onChange(of: primaryCityDraft) { _ in commitPrimaryCity() }
            }

            HStack {
                Text("Second Timezone")
                Spacer()
                Button {
                    showSecondTimezonePicker = true
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
        .sheet(isPresented: $showPrimaryTimezonePicker) {
            TimezonePickerView(
                title: "Primary Timezone",
                selectedIdentifier: $appState.dashboardSettings.primaryTimezoneIdentifier,
                noneOptionTitle: "Use detected location"
            )
        }
        .sheet(isPresented: $showSecondTimezonePicker) {
            TimezonePickerView(
                title: "Second Timezone",
                selectedIdentifier: $appState.dashboardSettings.secondTimezoneIdentifier,
                noneOptionTitle: "No second timezone"
            )
        }
    }

    private func commitPrimaryCity() {
        let trimmed = primaryCityDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        appState.dashboardSettings.primaryCityName = trimmed.isEmpty ? nil : trimmed
    }
}
