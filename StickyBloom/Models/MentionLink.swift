import Foundation

struct MentionLink: Codable, Identifiable {
    var id: UUID
    var targetStickyID: UUID
    var targetTitle: String
    var rangeLocation: Int
    var rangeLength: Int

    var range: NSRange {
        NSRange(location: rangeLocation, length: rangeLength)
    }

    init(
        id: UUID = UUID(),
        targetStickyID: UUID,
        targetTitle: String,
        rangeLocation: Int,
        rangeLength: Int
    ) {
        self.id = id
        self.targetStickyID = targetStickyID
        self.targetTitle = targetTitle
        self.rangeLocation = rangeLocation
        self.rangeLength = rangeLength
    }
}
