import Foundation

enum TitleGenerator {
    private static let adjectives = [
        "velvet", "crimson", "amber", "silver", "golden", "azure", "violet", "emerald",
        "midnight", "frosty", "sunny", "stormy", "misty", "rosy", "dusky", "cosmic",
        "gentle", "fierce", "quiet", "wild", "humble", "bright", "shadow", "luminous",
        "wandering", "drifting", "soaring", "still", "restless", "patient", "curious", "bold",
        "feather", "marble", "linen", "honey", "smoky", "glassy", "copper", "jade",
    ]

    private static let nouns = [
        "otter", "fox", "lark", "raven", "moth", "wren", "heron", "stag",
        "willow", "cedar", "fern", "maple", "thistle", "moss", "cove", "glade",
        "harbor", "lantern", "compass", "ember", "spark", "tide", "drift", "echo",
        "meadow", "ridge", "creek", "summit", "valley", "garden", "orchard", "trail",
        "comet", "nebula", "aurora", "horizon", "prism", "cipher", "chime", "feather",
    ]

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMdd-HHmm"
        return f
    }()

    static func generate(at date: Date = Date()) -> String {
        let adj = adjectives.randomElement() ?? "quiet"
        let noun = nouns.randomElement() ?? "note"
        return "\(adj)-\(noun)-\(dateFormatter.string(from: date))"
    }
}
