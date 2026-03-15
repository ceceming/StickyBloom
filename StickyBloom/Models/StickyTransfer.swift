import UniformTypeIdentifiers
import CoreTransferable
import Foundation

extension UTType {
    static let stickyID = UTType(exportedAs: "com.stickybloom.sticky-id")
}

struct StickyTransfer: Transferable, Codable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .stickyID)
    }
}
