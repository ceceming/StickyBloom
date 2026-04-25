import Foundation
import CoreGraphics
import AppKit

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
    var defaultTitle: String          // immutable name set at creation, used for .txt filename
    var customTitle: String?          // optional user override (set via dashboard rename)
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
        defaultTitle: String = TitleGenerator.generate(),
        customTitle: String? = nil,
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
        self.defaultTitle = defaultTitle
        self.customTitle = customTitle
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

    /// Label shown in the dashboard list and used by @mention matching.
    /// Order: explicit user override → first three words of body → auto default.
    var displayTitle: String {
        if let c = customTitle, !c.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return c
        }
        if !rtfData.isEmpty,
           let attr = NSAttributedString(rtfData: rtfData) {
            let plain = attr.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !plain.isEmpty {
                let words = plain.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
                return words.prefix(3).joined(separator: " ")
            }
        }
        return defaultTitle
    }

    // MARK: - Codable (handles legacy `title` field)

    private enum CodingKeys: String, CodingKey {
        case id, defaultTitle, customTitle, rtfData, backgroundColor, backgroundOpacity
        case frame, zIndex, createdAt, modifiedAt, mentionLinks, projectID
        case title  // legacy
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        rtfData = try c.decode(Data.self, forKey: .rtfData)
        backgroundColor = try c.decode(String.self, forKey: .backgroundColor)
        backgroundOpacity = try c.decode(Double.self, forKey: .backgroundOpacity)
        frame = try c.decode(CGRectCodable.self, forKey: .frame)
        zIndex = try c.decode(Int.self, forKey: .zIndex)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        modifiedAt = try c.decode(Date.self, forKey: .modifiedAt)
        mentionLinks = try c.decodeIfPresent([MentionLink].self, forKey: .mentionLinks) ?? []
        projectID = try c.decodeIfPresent(UUID.self, forKey: .projectID)

        // New fields with migration from legacy `title`.
        if let stored = try c.decodeIfPresent(String.self, forKey: .defaultTitle) {
            defaultTitle = stored
        } else {
            defaultTitle = TitleGenerator.generate(at: createdAt)
        }
        // Per migration choice, the legacy `title` is intentionally NOT promoted
        // to `customTitle` — derivation takes over for old stickies.
        customTitle = try c.decodeIfPresent(String.self, forKey: .customTitle)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(defaultTitle, forKey: .defaultTitle)
        try c.encodeIfPresent(customTitle, forKey: .customTitle)
        try c.encode(rtfData, forKey: .rtfData)
        try c.encode(backgroundColor, forKey: .backgroundColor)
        try c.encode(backgroundOpacity, forKey: .backgroundOpacity)
        try c.encode(frame, forKey: .frame)
        try c.encode(zIndex, forKey: .zIndex)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(modifiedAt, forKey: .modifiedAt)
        try c.encode(mentionLinks, forKey: .mentionLinks)
        try c.encodeIfPresent(projectID, forKey: .projectID)
    }
}
