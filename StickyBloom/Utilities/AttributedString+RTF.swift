import AppKit

extension NSAttributedString {
    var rtfData: Data? {
        let range = NSRange(location: 0, length: length)
        return try? data(
            from: range,
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
    }

    convenience init?(rtfData: Data) {
        try? self.init(
            data: rtfData,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        )
    }
}

extension NSMutableAttributedString {
    func applyDefaultFont() {
        let range = NSRange(location: 0, length: length)
        addAttribute(.font, value: NSFont.systemFont(ofSize: 14), range: range)
    }
}
