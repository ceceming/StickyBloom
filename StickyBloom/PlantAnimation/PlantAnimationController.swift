import SwiftUI

struct PlantAnimationController {
    static func gradientColors(for stage: PlantStage, progress: Double) -> (stem: Color, leaf: Color, flower: Color?) {
        switch stage {
        case .seedling:
            return (Color(red: 0.4, green: 0.28, blue: 0.12), Color(red: 0.55, green: 0.42, blue: 0.18), nil)
        case .sprout:
            return (Color(red: 0.25, green: 0.52, blue: 0.22), Color(red: 0.35, green: 0.68, blue: 0.28), nil)
        case .sapling:
            return (Color(red: 0.22, green: 0.55, blue: 0.20), Color(red: 0.32, green: 0.72, blue: 0.25), nil)
        case .budding:
            let g = Color(red: 0.20, green: 0.58, blue: 0.18)
            let bud = Color(red: 0.85, green: 0.65, blue: 0.75)
            return (g, g, bud)
        case .bloomed:
            let g = Color(red: 0.18, green: 0.60, blue: 0.16)
            let petal = Color(red: 1.0, green: 0.75, blue: 0.85)
            return (g, g, petal)
        }
    }

    /// A full day progress value (0–1) mapped to a descriptive emoji + text
    static func statusText(stage: PlantStage, progress: Double) -> String {
        switch stage {
        case .seedling: return "🌱 Resting..."
        case .sprout:   return "🌿 Growing..."
        case .sapling:  return "🌳 Reaching up..."
        case .budding:  return "🌸 Almost there..."
        case .bloomed:  return "🌺 In full bloom!"
        }
    }
}
