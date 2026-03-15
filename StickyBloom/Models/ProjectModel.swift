import Foundation

struct ProjectModel: Identifiable, Codable {
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#A8D8EA",
        createdAt: Date = Date(),
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.isExpanded = isExpanded
    }
}
