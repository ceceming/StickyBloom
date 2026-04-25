import AppKit

@MainActor
final class RichTextCoordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
    var onTextChange: ((NSAttributedString) -> Void)?
    var onMentionClicked: ((UUID) -> Void)?
    var appState: AppState?
    var stickyID: UUID?
    weak var textView: MentionAwareTextView?
    private let mentionPopover = MentionPopoverController()
    private var isApplyingMentions = false
    var isUserEditing = false

    // MARK: - NSTextViewDelegate

    func textDidBeginEditing(_ notification: Notification) {
        isUserEditing = true
    }

    func textDidEndEditing(_ notification: Notification) {
        isUserEditing = false
    }

    func textDidChange(_ notification: Notification) {
        isUserEditing = true
        guard let tv = notification.object as? NSTextView else { return }
        onTextChange?(tv.attributedString())
        checkForMentionAutocomplete(in: tv)
    }

    // MARK: - NSTextStorageDelegate

    func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard !isApplyingMentions,
              editedMask.contains(.editedCharacters),
              let appState else { return }
        applyMentionAttributes(to: textStorage, appState: appState)
    }

    private func applyMentionAttributes(to textStorage: NSTextStorage, appState: AppState) {
        isApplyingMentions = true
        defer { isApplyingMentions = false }

        let fullText = textStorage.string
        let matches = MentionParser.findMatches(in: fullText, stickies: appState.stickies)
        let fullRange = NSRange(location: 0, length: textStorage.length)

        // Collect only ranges that currently carry mention styling — never touch
        // table-cell content or unrelated text.
        var oldMentionRanges: [NSRange] = []
        textStorage.enumerateAttribute(.stickyBloomMentionID, in: fullRange, options: []) { value, range, _ in
            if value != nil { oldMentionRanges.append(range) }
        }

        // Strip old mention styling only from ranges that actually had it —
        // avoids invalidating the full layout (critical for table cells).
        for range in oldMentionRanges {
            textStorage.removeAttribute(.stickyBloomMentionID, range: range)
            textStorage.removeAttribute(.foregroundColor, range: range)
            textStorage.removeAttribute(.underlineStyle, range: range)
        }

        // Apply new mention styling
        for match in matches {
            guard match.range.upperBound <= textStorage.length else { continue }
            textStorage.addAttribute(.stickyBloomMentionID, value: match.stickyID.uuidString, range: match.range)
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: match.range)
            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
        }

        // Update mention links in model
        if let stickyID, let idx = appState.stickies.firstIndex(where: { $0.id == stickyID }) {
            let links = matches.map { m in
                MentionLink(
                    targetStickyID: m.stickyID,
                    targetTitle: m.title,
                    rangeLocation: m.range.location,
                    rangeLength: m.range.length
                )
            }
            appState.stickies[idx].mentionLinks = links
        }
    }

    // MARK: - Autocomplete

    private func checkForMentionAutocomplete(in textView: NSTextView) {
        guard let appState else { return }
        let selectedRange = textView.selectedRange()
        let location = selectedRange.location
        let text = textView.string

        if let partial = MentionParser.partialMention(in: text, at: location) {
            let candidates = appState.stickies.filter {
                !$0.displayTitle.isEmpty &&
                $0.displayTitle.lowercased().hasPrefix(partial.lowercased())
            }

            if candidates.isEmpty {
                mentionPopover.dismiss()
                return
            }

            // Find cursor rect for popover placement
            guard let layoutManager = textView.layoutManager,
                  let container = textView.textContainer else { return }
            let charRange = NSRange(location: max(0, location - partial.count - 1), length: 1)
            let glyphRange = layoutManager.glyphRange(forCharacterRange: charRange, actualCharacterRange: nil)
            let cursorRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: container)
            let screenRect = textView.convert(cursorRect, to: nil)

            mentionPopover.show(
                candidates: Array(candidates.prefix(8)),
                relativeTo: screenRect,
                of: textView
            ) { [weak self, weak textView] sticky in
                self?.insertMention(sticky, partialText: partial, in: textView, at: location)
            }
        } else {
            mentionPopover.dismiss()
        }
    }

    private func insertMention(_ sticky: StickyNoteModel, partialText: String, in textView: NSTextView?, at location: Int) {
        guard let textView, let storage = textView.textStorage else { return }
        // Replace @partial with @Title
        let replaceRange = NSRange(location: location - partialText.count - 1, length: partialText.count + 1)
        guard replaceRange.location >= 0 && replaceRange.upperBound <= storage.length else { return }
        let replacement = "@\(sticky.displayTitle)"
        storage.replaceCharacters(in: replaceRange, with: replacement)
        textView.setSelectedRange(NSRange(location: replaceRange.location + replacement.count, length: 0))
    }
}
