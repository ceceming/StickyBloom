import SwiftUI

struct ClockView: View {
    private let torontoTZ = TimeZone(identifier: "America/Toronto")!
    private let istanbulTZ = TimeZone(identifier: "Europe/Istanbul")!

    var body: some View {
        TimelineView(.everyMinute) { context in
            let now = context.date
            VStack(spacing: 4) {
                // City labels on top
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text("Toronto")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    Text("·")
                        .foregroundStyle(.tertiary)
                    HStack(spacing: 3) {
                        Image(systemName: "globe")
                            .font(.system(size: 10))
                        Text("Istanbul")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                        Text(timeString(from: now, in: istanbulTZ))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.tertiary)
                    }
                }
                .foregroundStyle(.secondary)

                // Large local time
                Text(timeString(from: now, in: .current))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(dateString(from: now, in: .current))
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

    private func gmtOffset(for tz: TimeZone, date: Date) -> String {
        let seconds = tz.secondsFromGMT(for: date)
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        if minutes == 0 {
            return hours >= 0 ? "GMT+\(hours)" : "GMT\(hours)"
        } else {
            return hours >= 0 ? "GMT+\(hours):\(String(format: "%02d", minutes))" : "GMT\(hours):\(String(format: "%02d", minutes))"
        }
    }
}
