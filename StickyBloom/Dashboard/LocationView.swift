import SwiftUI

struct LocationView: View {
    @ObservedObject var locationService: LocationService
    let secondTimezoneID: String?

    var body: some View {
        TimelineView(.everyMinute) { context in
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(locationService.cityName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                }

                Text(TimeZone.current.offsetString)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)

                if let tzID = secondTimezoneID,
                   let tz = TimeZone(identifier: tzID) {
                    Divider()
                        .frame(width: 60)
                        .padding(.vertical, 2)

                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(tz.displayName)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    }

                    Text(tz.formattedTime(date: context.date))
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .monospacedDigit()

                    Text(tz.offsetString)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
