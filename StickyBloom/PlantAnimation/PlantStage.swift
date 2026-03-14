import Foundation

enum PlantStage: Int, CaseIterable {
    case seedling   // 12am–6am
    case sprout     // 6am–10am
    case sapling    // 10am–2pm
    case budding    // 2pm–5pm
    case bloomed    // 5pm onward

    var displayName: String {
        switch self {
        case .seedling: return "Seedling"
        case .sprout:   return "Sprout"
        case .sapling:  return "Sapling"
        case .budding:  return "Budding"
        case .bloomed:  return "Bloomed"
        }
    }

    /// Returns the hour range [start, end) for each stage
    var hourRange: Range<Int> {
        switch self {
        case .seedling: return 0..<6
        case .sprout:   return 6..<10
        case .sapling:  return 10..<14
        case .budding:  return 14..<17
        case .bloomed:  return 17..<24
        }
    }

    /// The total hours in this stage
    var duration: Double {
        Double(hourRange.upperBound - hourRange.lowerBound)
    }

    static func current(date: Date = Date()) -> (stage: PlantStage, progress: Double) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let fractionalHour = Double(hour) + Double(minute) / 60.0

        for stage in PlantStage.allCases {
            let range = stage.hourRange
            if fractionalHour >= Double(range.lowerBound) && fractionalHour < Double(range.upperBound) {
                let elapsed = fractionalHour - Double(range.lowerBound)
                let progress = min(elapsed / stage.duration, 1.0)
                return (stage, progress)
            }
        }
        return (.bloomed, 1.0)
    }

    /// Overall bloom progress (0–1 across the whole day)
    static func overallProgress(date: Date = Date()) -> Double {
        let (stage, stageProgress) = current(date: date)
        let stagesCompleted = Double(stage.rawValue)
        let totalStages = Double(PlantStage.allCases.count)
        return (stagesCompleted + stageProgress) / totalStages
    }
}
