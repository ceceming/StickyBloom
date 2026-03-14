import Foundation

extension TimeZone {
    var displayName: String {
        let parts = identifier.split(separator: "/")
        if parts.count >= 2 {
            return parts.last.map(String.init)?.replacingOccurrences(of: "_", with: " ") ?? identifier
        }
        return identifier
    }

    var offsetString: String {
        let seconds = secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds / 60) % 60
        let sign = seconds >= 0 ? "+" : "-"
        if minutes == 0 {
            return "GMT\(sign)\(abs(hours))"
        } else {
            return String(format: "GMT%@%d:%02d", sign, abs(hours), minutes)
        }
    }

    func formattedTime(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = self
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
