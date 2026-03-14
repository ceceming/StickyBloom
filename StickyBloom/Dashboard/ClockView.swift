import SwiftUI

struct ClockView: View {
    var body: some View {
        TimelineView(.everyMinute) { context in
            let now = context.date
            VStack(spacing: 4) {
                Text(timeString(from: now))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(dateString(from: now))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
