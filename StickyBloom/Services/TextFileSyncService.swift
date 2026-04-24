import Foundation
import AppKit

@MainActor
final class TextFileSyncService {
    static let shared = TextFileSyncService()

    private let notesDirectory: URL
    private var lastFilenameByID: [UUID: String] = [:]

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        notesDirectory = documents
            .appendingPathComponent("StickyBloom", isDirectory: true)
            .appendingPathComponent("Notes", isDirectory: true)
        try? FileManager.default.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
    }

    func sync(stickies: [StickyNoteModel]) {
        let currentIDs = Set(stickies.map { $0.id })
        var nextFilenameByID: [UUID: String] = [:]

        for sticky in stickies {
            let filename = filename(for: sticky)
            nextFilenameByID[sticky.id] = filename

            let target = notesDirectory.appendingPathComponent(filename)

            if let previous = lastFilenameByID[sticky.id], previous != filename {
                let oldURL = notesDirectory.appendingPathComponent(previous)
                try? FileManager.default.removeItem(at: oldURL)
            }

            let plainText = plainText(from: sticky.rtfData)
            do {
                try plainText.write(to: target, atomically: true, encoding: .utf8)
            } catch {
                print("TextFileSyncService: failed to write \(filename): \(error)")
            }
        }

        for (id, oldFilename) in lastFilenameByID where !currentIDs.contains(id) {
            let oldURL = notesDirectory.appendingPathComponent(oldFilename)
            try? FileManager.default.removeItem(at: oldURL)
        }

        deleteOrphanFiles(expectedFilenames: Set(nextFilenameByID.values))

        lastFilenameByID = nextFilenameByID
    }

    private func deleteOrphanFiles(expectedFilenames: Set<String>) {
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: notesDirectory,
            includingPropertiesForKeys: nil
        ) else { return }

        for url in entries where url.pathExtension == "txt" {
            if expectedFilenames.contains(url.lastPathComponent) { continue }
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func filename(for sticky: StickyNoteModel) -> String {
        let shortID = String(sticky.id.uuidString.prefix(4))
        let sanitized = sanitize(sticky.title)
        let base = sanitized.isEmpty ? "Untitled" : sanitized
        return "\(base)-\(shortID).txt"
    }

    private func sanitize(_ raw: String) -> String {
        let illegal = CharacterSet(charactersIn: "/\\:*?\"<>|").union(.controlCharacters)
        let collapsed = raw
            .components(separatedBy: illegal)
            .joined(separator: " ")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return String(collapsed.prefix(80))
    }

    private func plainText(from rtfData: Data) -> String {
        guard !rtfData.isEmpty,
              let attributed = NSAttributedString(rtfData: rtfData) else {
            return ""
        }
        return attributed.string
    }
}
