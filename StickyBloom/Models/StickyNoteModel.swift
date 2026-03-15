import Foundation
import CoreGraphics

struct CGRectCodable: Codable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    init(_ rect: CGRect) {
        x = rect.origin.x
        y = rect.origin.y
        width = rect.size.width
        height = rect.size.height
    }
}

struct StickyNoteModel: Identifiable, Codable {
    var id: UUID
    var title: String
    var rtfData: Data
    var backgroundColor: String       // hex e.g. "#FFE066"
    var backgroundOpacity: Double     // 0.0–0.9
    var frame: CGRectCodable
    var zIndex: Int
    var createdAt: Date
    var modifiedAt: Date
    var mentionLinks: [MentionLink]
    var projectID: UUID?

    init(
        id: UUID = UUID(),
        title: String = "",
        rtfData: Data = Data(),
        backgroundColor: String = "#FFE066",
        backgroundOpacity: Double = 0.85,
        frame: CGRect = CGRect(x: 200, y: 200, width: 320, height: 280),
        zIndex: Int = 0,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        mentionLinks: [MentionLink] = [],
        projectID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.rtfData = rtfData
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.frame = CGRectCodable(frame)
        self.zIndex = zIndex
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.mentionLinks = mentionLinks
        self.projectID = projectID
    }
}
