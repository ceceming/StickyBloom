import SwiftUI

struct ClockView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var locationService: LocationService

    private var primaryTimeZone: TimeZone {
        if let id = appState.dashboardSettings.primaryTimezoneIdentifier,
           let tz = TimeZone(identifier: id) {
            return tz
        }
        if let id = locationService.detectedTimeZoneIdentifier,
           let tz = TimeZone(identifier: id) {
            return tz
        }
        return .current
    }

    private var primaryCityLabel: String {
        if let name = appState.dashboardSettings.primaryCityName,
           !name.trimmingCharacters(in: .whitespaces).isEmpty {
            return name
        }
        if let detected = locationService.cityName,
           !detected.isEmpty {
            return detected
        }
        return primaryTimeZone.displayName
    }

    private var secondTimeZone: TimeZone? {
        appState.dashboardSettings.secondTimezoneIdentifier.flatMap { TimeZone(identifier: $0) }
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let now = context.date
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(primaryCityLabel)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    if let secondTz = secondTimeZone {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        HStack(spacing: 3) {
                            Image(systemName: "globe")
                                .font(.system(size: 10))
                            Text(secondTz.displayName)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                            Text(timeString(from: now, in: secondTz))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .foregroundStyle(.secondary)

                Text(timeString(from: now, in: primaryTimeZone))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(dateString(from: now, in: primaryTimeZone))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func timeString(from date: Date, in tz: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = tz
        return formatter.string(from: date)
    }

    private func dateString(from date: Date, in tz: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.timeZone = tz
        return formatter.string(from: date)
    }
}
