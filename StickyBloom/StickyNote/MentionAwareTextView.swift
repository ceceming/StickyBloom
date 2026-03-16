import AppKit

// Custom attribute key for mention links
extension NSAttributedString.Key {
    static let stickyBloomMentionID = NSAttributedString.Key("StickyBloomMentionID")
}

final class MentionAwareTextView: NSTextView {
    var onMentionClicked: ((UUID) -> Void)?
    var onTodoToggled: ((Int) -> Void)?

    override var mouseDownCanMoveWindow: Bool { true }

    // MARK: - Table Deletion

    override func deleteBackward(_ sender: Any?) {
        let loc = selectedRange().location
        let prevIsTable = loc > 0 && tableAt(index: loc - 1) != nil
        let curIsTable  = loc < (textStorage?.length ?? 0) && tableAt(index: loc) != nil
        // Delete the whole table only when cursor is OUTSIDE the table (after it)
        if prevIsTable && !curIsTable, let table = tableAt(index: loc - 1) {
            deleteTable(table)
            return
        }
        super.deleteBackward(sender)
    }

    override func deleteForward(_ sender: Any?) {
        let loc = selectedRange().location
        let nextIsTable = loc < (textStorage?.length ?? 0) && tableAt(index: loc) != nil
        let prevIsTable = loc > 0 && tableAt(index: loc - 1) != nil
        // Delete the whole table only when cursor is OUTSIDE the table (before it)
        if nextIsTable && !prevIsTable, let table = tableAt(index: loc) {
            deleteTable(table)
            return
        }
        super.deleteForward(sender)
    }

    private func tableAt(index: Int) -> NSTextTable? {
        guard let storage = textStorage, index < storage.length else { return nil }
        let para = storage.attribute(.paragraphStyle, at: index, effectiveRange: nil) as? NSParagraphStyle
        return para?.textBlocks.compactMap { $0 as? NSTextTableBlock }.first?.table
    }

    private func deleteTable(_ table: NSTextTable) {
        guard let storage = textStorage else { return }
        var start = storage.length
        var end = 0
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.enumerateAttribute(.paragraphStyle, in: fullRange, options: []) { value, range, _ in
            guard let para = value as? NSParagraphStyle,
                  para.textBlocks.compactMap({ $0 as? NSTextTableBlock }).contains(where: { $0.table === table })
            else { return }
            start = min(start, range.location)
            end = max(end, range.upperBound)
        }
        guard start < end else { return }
        let tableRange = NSRange(location: start, length: end - start)
        storage.replaceCharacters(in: tableRange, with: "")
        setSelectedRange(NSRange(location: start, length: 0))
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if handleMentionClick(at: point) { return }
        if handleTodoClick(at: point) { return }
        super.mouseDown(with: event)
    }

    private func handleMentionClick(at point: NSPoint) -> Bool {
        guard let layout = layoutManager,
              let container = textContainer else { return false }

        let glyphIndex = layout.glyphIndex(for: point, in: container, fractionOfDistanceThroughGlyph: nil)
        let charIndex = layout.characterIndexForGlyph(at: glyphIndex)

        guard charIndex < textStorage?.length ?? 0 else { return false }
        let range = NSRange(location: charIndex, length: 1)

        if let idString = textStorage?.attribute(.stickyBloomMentionID, at: charIndex, effectiveRange: nil) as? String,
           let uuid = UUID(uuidString: idString) {
            _ = range
            onMentionClicked?(uuid)
            return true
        }
        return false
    }

    private func handleTodoClick(at point: NSPoint) -> Bool {
        guard let layout = layoutManager,
              let container = textContainer else { return false }

        let glyphIndex = layout.glyphIndex(for: point, in: container, fractionOfDistanceThroughGlyph: nil)
        let charIndex = layout.characterIndexForGlyph(at: glyphIndex)
        guard charIndex < textStorage?.length ?? 0 else { return false }

        if let attachment = textStorage?.attribute(.attachment, at: charIndex, effectiveRange: nil) as? NSTextAttachment,
           attachment.attachmentCell is TodoCheckboxCell {
            onTodoToggled?(charIndex)
            return true
        }
        return false
    }
}

// MARK: - Todo Checkbox Cell

final class TodoCheckboxCell: NSTextAttachmentCell {
    var isChecked: Bool = false {
        didSet { controlView?.needsDisplay = true }
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        let rect = cellFrame.insetBy(dx: 1, dy: 1)
        let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)

        if isChecked {
            NSColor.systemGreen.setFill()
            path.fill()
            NSColor.white.setStroke()
            let check = NSBezierPath()
            check.move(to: NSPoint(x: rect.minX + 3, y: rect.midY))
            check.line(to: NSPoint(x: rect.midX - 1, y: rect.maxY - 3))
            check.line(to: NSPoint(x: rect.maxX - 2, y: rect.minY + 3))
            check.lineWidth = 1.5
            check.stroke()
        } else {
            NSColor.clear.setFill()
            path.fill()
            NSColor.secondaryLabelColor.setStroke()
            path.lineWidth = 1.0
            path.stroke()
        }
    }

    override func cellSize() -> NSSize {
        NSSize(width: 14, height: 14)
    }
}
