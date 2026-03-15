import SwiftUI
import AppKit

struct StickyToolbarView: View {
    let textView: () -> NSTextView?
    @State private var tableInsertController: TableInsertWindowController?
    @State private var showFontPicker = false
    @State private var fontSize: Double = 14

    var body: some View {
        HStack(spacing: 6) {
            // Bold
            ToolbarButton(icon: "bold", tooltip: "Bold") {
                applyFormat(.bold)
            }
            // Italic
            ToolbarButton(icon: "italic", tooltip: "Italic") {
                applyFormat(.italic)
            }
            // Underline
            ToolbarButton(icon: "underline", tooltip: "Underline") {
                applyFormat(.underline)
            }
            // Strikethrough
            ToolbarButton(icon: "strikethrough", tooltip: "Strikethrough") {
                applyFormat(.strikethrough)
            }

            Divider().frame(height: 16)

            // Font size stepper
            HStack(spacing: 2) {
                Button {
                    fontSize = max(8, fontSize - 1)
                    applyFontSize(fontSize)
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)

                Text(String(format: "%.0f", fontSize))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(width: 20)

                Button {
                    fontSize = min(72, fontSize + 1)
                    applyFontSize(fontSize)
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }

            Divider().frame(height: 16)

            // Text color
            ToolbarButton(icon: "paintbrush.fill", tooltip: "Text Color") {
                NSApp.orderFrontColorPanel(nil)
            }

            Divider().frame(height: 16)

            // Table
            ToolbarButton(icon: "tablecells", tooltip: "Insert Table") {
                guard let tv = textView() else { return }
                let controller = TableInsertWindowController(textView: tv) { [self] in
                    tableInsertController = nil
                }
                tableInsertController = controller
                controller.showWindow(nil)
            }

            // Todo checkbox
            ToolbarButton(icon: "checkmark.square", tooltip: "Todo Item") {
                insertTodo()
            }

            // Calendar item
            ToolbarButton(icon: "calendar", tooltip: "Calendar Item") {
                insertCalendarItem()
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
    }

    // MARK: - Formatting

    private enum Format { case bold, italic, underline, strikethrough }

    private func applyFormat(_ format: Format) {
        guard let tv = textView(), tv.selectedRange().length > 0 else { return }
        let range = tv.selectedRange()
        let storage = tv.textStorage!

        switch format {
        case .bold:
            let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont
                ?? NSFont.systemFont(ofSize: fontSize)
            let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.bold)
            let newFont = isBold
                ? NSFont.systemFont(ofSize: currentFont.pointSize)
                : NSFont.boldSystemFont(ofSize: currentFont.pointSize)
            storage.addAttribute(.font, value: newFont, range: range)

        case .italic:
            let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont
                ?? NSFont.systemFont(ofSize: fontSize)
            let isItalic = currentFont.fontDescriptor.symbolicTraits.contains(.italic)
            let newFont: NSFont
            if isItalic {
                newFont = NSFont.systemFont(ofSize: currentFont.pointSize)
            } else {
                newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
            }
            storage.addAttribute(.font, value: newFont, range: range)

        case .underline:
            let existing = storage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int
            let newValue = (existing ?? 0) == 0 ? NSUnderlineStyle.single.rawValue : 0
            storage.addAttribute(.underlineStyle, value: newValue, range: range)

        case .strikethrough:
            let existing = storage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int
            let newValue = (existing ?? 0) == 0 ? NSUnderlineStyle.single.rawValue : 0
            storage.addAttribute(.strikethroughStyle, value: newValue, range: range)
        }
    }

    private func applyFontSize(_ size: Double) {
        guard let tv = textView(), tv.selectedRange().length > 0 else { return }
        let range = tv.selectedRange()
        let storage = tv.textStorage!
        let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont
            ?? NSFont.systemFont(ofSize: 14)
        let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: size) ?? NSFont.systemFont(ofSize: size)
        storage.addAttribute(.font, value: newFont, range: range)
    }

    private func insertTodo() {
        guard let tv = textView() else { return }
        let cell = TodoCheckboxCell()
        let attachment = NSTextAttachment()
        attachment.attachmentCell = cell

        let attrStr = NSMutableAttributedString(attachment: attachment)
        attrStr.append(NSAttributedString(string: " "))

        let insertRange = tv.selectedRange()
        tv.textStorage?.replaceCharacters(in: insertRange, with: attrStr)
        tv.setSelectedRange(NSRange(location: insertRange.location + 2, length: 0))
    }

    private func insertCalendarItem() {
        guard let tv = textView() else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: Date())

        let calStr = NSAttributedString(
            string: "📅 \(dateStr)\n",
            attributes: [
                .font: NSFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: NSColor.systemBlue,
                .backgroundColor: NSColor.systemBlue.withAlphaComponent(0.10)
            ]
        )
        let insertRange = tv.selectedRange()
        tv.textStorage?.replaceCharacters(in: insertRange, with: calStr)
        tv.setSelectedRange(NSRange(location: insertRange.location + calStr.length, length: 0))
    }
}

private struct ToolbarButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 24, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}
