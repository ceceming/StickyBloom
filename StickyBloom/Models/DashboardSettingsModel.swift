import Foundation
import CoreGraphics

struct DashboardSettingsModel: Codable {
    var backgroundColor: String
    var opacity: Double
    var primaryTimezoneIdentifier: String?
    var primaryCityName: String?
    var secondTimezoneIdentifier: String?
    var frame: CGRectCodable
    var showOnRightSide: Bool

    init(
        backgroundColor: String = "#1E1E2E",
        opacity: Double = 0.85,
        primaryTimezoneIdentifier: String? = nil,
        primaryCityName: String? = nil,
        secondTimezoneIdentifier: String? = nil,
        frame: CGRect = CGRect(x: 40, y: 60, width: 320, height: 860),
        showOnRightSide: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.opacity = opacity
        self.primaryTimezoneIdentifier = primaryTimezoneIdentifier
        self.primaryCityName = primaryCityName
        self.secondTimezoneIdentifier = secondTimezoneIdentifier
        self.frame = CGRectCodable(frame)
        self.showOnRightSide = showOnRightSide
    }

    enum CodingKeys: String, CodingKey {
        case backgroundColor, opacity
        case primaryTimezoneIdentifier, primaryCityName
        case secondTimezoneIdentifier
        case frame, showOnRightSide
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try c.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#1E1E2E"
        opacity = try c.decodeIfPresent(Double.self, forKey: .opacity) ?? 0.85
        primaryTimezoneIdentifier = try c.decodeIfPresent(String.self, forKey: .primaryTimezoneIdentifier)
        primaryCityName = try c.decodeIfPresent(String.self, forKey: .primaryCityName)
        secondTimezoneIdentifier = try c.decodeIfPresent(String.self, forKey: .secondTimezoneIdentifier)
        frame = try c.decodeIfPresent(CGRectCodable.self, forKey: .frame)
            ?? CGRectCodable(CGRect(x: 40, y: 60, width: 320, height: 860))
        showOnRightSide = try c.decodeIfPresent(Bool.self, forKey: .showOnRightSide) ?? false
    }
}
