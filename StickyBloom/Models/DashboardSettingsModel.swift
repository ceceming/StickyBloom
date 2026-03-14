import Foundation
import CoreGraphics

struct DashboardSettingsModel: Codable {
    var backgroundColor: String
    var opacity: Double
    var secondTimezoneIdentifier: String?
    var frame: CGRectCodable
    var showOnRightSide: Bool

    init(
        backgroundColor: String = "#1E1E2E",
        opacity: Double = 0.85,
        secondTimezoneIdentifier: String? = nil,
        frame: CGRect = CGRect(x: 40, y: 60, width: 320, height: 560),
        showOnRightSide: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.opacity = opacity
        self.secondTimezoneIdentifier = secondTimezoneIdentifier
        self.frame = CGRectCodable(frame)
        self.showOnRightSide = showOnRightSide
    }
}
