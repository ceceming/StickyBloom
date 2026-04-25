import Foundation

struct MentionMatch {
    let range: NSRange
    let title: String
    let stickyID: UUID
}

struct MentionParser {
    static let mentionPattern = try! NSRegularExpression(
        pattern: "@([A-Za-z0-9 _\\-]{1,50})",
        options: []
    )

    /// Find all @mention matches in `text`, resolving against `stickies` by title.
    static func findMatches(in text: String, stickies: [StickyNoteModel]) -> [MentionMatch] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let results = mentionPattern.matches(in: text, options: [], range: range)
        var matches: [MentionMatch] = []

        for result in results {
            guard result.numberOfRanges > 1 else { continue }
            let titleRange = result.range(at: 1)
            let mentionTitle = nsText.substring(with: titleRange).trimmingCharacters(in: .whitespaces)

            // Case-insensitive title match
            if let sticky = stickies.first(where: {
                $0.displayTitle.lowercased() == mentionTitle.lowercased() && !$0.displayTitle.isEmpty
            }) {
                matches.append(MentionMatch(
                    range: result.range,
                    title: sticky.displayTitle,
                    stickyID: sticky.id
                ))
            }
        }
        return matches
    }

    /// Detect a partial @mention at `location` in `text` for autocomplete.
    static func partialMention(in text: String, at location: Int) -> String? {
        let nsText = text as NSString
        guard location > 0 else { return nil }

        // Walk backwards from cursor to find '@'
        var idx = location - 1
        var partial = ""
        while idx >= 0 {
            let ch = nsText.substring(with: NSRange(location: idx, length: 1))
            if ch == "@" {
                return partial.isEmpty ? nil : partial
            }
            if ch == " " || ch == "\n" { return nil }
            partial = ch + partial
            idx -= 1
        }
        return nil
    }
}
