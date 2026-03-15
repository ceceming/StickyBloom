import AppKit

// Custom attribute key for mention links
extension NSAttributedString.Key {
    static let stickyBloomMentionID = NSAttributedString.Key("StickyBloomMentionID")
}

final class MentionAwareTextView: NSTextView {
    var onMentionClicked: ((UUID) -> Void)?
    var onTodoToggled: ((Int) -> Void)?

    override var mouseDownCanMoveWindow: Bool { true }

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
