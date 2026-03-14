import SwiftUI

/// A shape that morphs between plant growth stages using Bezier path interpolation.
struct PlantShape: Shape {
    /// 0.0 = seedling, 1.0 = fully bloomed
    var animatableData: Double

    func path(in rect: CGRect) -> Path {
        let t = max(0, min(1, animatableData))
        let points = interpolatedPoints(t: t, in: rect)
        return buildPath(from: points, in: rect)
    }

    // MARK: - Keyframe definitions (normalized 0–1 coordinates)

    private struct PlantKeyframe {
        let stem: [CGPoint]       // stem control points
        let leaves: [[CGPoint]]   // each leaf as array of points
        let flower: [CGPoint]     // flower petals center + radius encoded
    }

    private func keyframe(for stage: Int) -> PlantKeyframe {
        switch stage {
        case 0: // seedling
            return PlantKeyframe(
                stem: [CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.5, y: 0.82)],
                leaves: [],
                flower: []
            )
        case 1: // sprout
            return PlantKeyframe(
                stem: [CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.5, y: 0.72)],
                leaves: [
                    [CGPoint(x: 0.5, y: 0.80), CGPoint(x: 0.35, y: 0.74), CGPoint(x: 0.3, y: 0.68)]
                ],
                flower: []
            )
        case 2: // sapling
            return PlantKeyframe(
                stem: [CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.5, y: 0.55)],
                leaves: [
                    [CGPoint(x: 0.5, y: 0.80), CGPoint(x: 0.32, y: 0.73), CGPoint(x: 0.25, y: 0.64)],
                    [CGPoint(x: 0.5, y: 0.70), CGPoint(x: 0.68, y: 0.63), CGPoint(x: 0.72, y: 0.54)]
                ],
                flower: []
            )
        case 3: // budding
            return PlantKeyframe(
                stem: [CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.5, y: 0.45)],
                leaves: [
                    [CGPoint(x: 0.5, y: 0.80), CGPoint(x: 0.30, y: 0.73), CGPoint(x: 0.22, y: 0.62)],
                    [CGPoint(x: 0.5, y: 0.68), CGPoint(x: 0.70, y: 0.61), CGPoint(x: 0.75, y: 0.50)],
                    [CGPoint(x: 0.5, y: 0.56), CGPoint(x: 0.35, y: 0.50), CGPoint(x: 0.30, y: 0.42)]
                ],
                flower: [CGPoint(x: 0.5, y: 0.38), CGPoint(x: 0.06, y: 0.0)]  // center + radius
            )
        default: // bloomed
            return PlantKeyframe(
                stem: [CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.5, y: 0.42)],
                leaves: [
                    [CGPoint(x: 0.5, y: 0.80), CGPoint(x: 0.28, y: 0.72), CGPoint(x: 0.20, y: 0.60)],
                    [CGPoint(x: 0.5, y: 0.67), CGPoint(x: 0.72, y: 0.60), CGPoint(x: 0.78, y: 0.48)],
                    [CGPoint(x: 0.5, y: 0.55), CGPoint(x: 0.33, y: 0.48), CGPoint(x: 0.28, y: 0.38)]
                ],
                flower: [CGPoint(x: 0.5, y: 0.30), CGPoint(x: 0.12, y: 0.0)]
            )
        }
    }

    private struct InterpolatedPlant {
        var stemTop: CGPoint
        var stemBottom: CGPoint
        var leaves: [[CGPoint]]
        var flowerCenter: CGPoint?
        var flowerRadius: CGFloat?
        var petalCount: Int
    }

    private func interpolatedPoints(t: Double, in rect: CGRect) -> InterpolatedPlant {
        let stageCount = 5
        let stageF = t * Double(stageCount - 1)
        let stage = min(Int(stageF), stageCount - 2)
        let progress = stageF - Double(stage)

        let kf0 = keyframe(for: stage)
        let kf1 = keyframe(for: min(stage + 1, stageCount - 1))

        func lerp(_ a: CGPoint, _ b: CGPoint, _ p: Double) -> CGPoint {
            CGPoint(x: a.x + (b.x - a.x) * p, y: a.y + (b.y - a.y) * p)
        }

        func toScreen(_ pt: CGPoint) -> CGPoint {
            CGPoint(x: pt.x * rect.width + rect.minX, y: pt.y * rect.height + rect.minY)
        }

        let stemTop = toScreen(lerp(kf0.stem[1], kf1.stem[1], progress))
        let stemBottom = toScreen(lerp(kf0.stem[0], kf1.stem[0], progress))

        // Interpolate leaves
        var leaves: [[CGPoint]] = []
        let leafCount = max(kf0.leaves.count, kf1.leaves.count)
        for i in 0..<leafCount {
            let l0 = i < kf0.leaves.count ? kf0.leaves[i] : kf0.leaves.last ?? []
            let l1 = i < kf1.leaves.count ? kf1.leaves[i] : kf1.leaves.last ?? []
            guard !l0.isEmpty && !l1.isEmpty else { continue }
            let leafAlpha = i < kf0.leaves.count ? 1.0 : progress
            _ = leafAlpha // used for future alpha blending
            var leaf: [CGPoint] = []
            for j in 0..<min(l0.count, l1.count) {
                leaf.append(toScreen(lerp(l0[j], l1[j], progress)))
            }
            if !leaf.isEmpty { leaves.append(leaf) }
        }

        // Flower
        var flowerCenter: CGPoint? = nil
        var flowerRadius: CGFloat? = nil
        let petalCount: Int

        if !kf1.flower.isEmpty {
            let fc0 = kf0.flower.isEmpty ? kf1.flower[0] : kf0.flower[0]
            let fc1 = kf1.flower[0]
            let fr0: CGPoint = kf0.flower.count > 1 ? kf0.flower[1] : CGPoint(x: 0.02, y: 0)
            let fr1: CGPoint = kf1.flower.count > 1 ? kf1.flower[1] : CGPoint(x: 0.02, y: 0)
            flowerCenter = toScreen(lerp(fc0, fc1, progress))
            flowerRadius = (fr0.x + (fr1.x - fr0.x) * progress) * rect.width
            petalCount = stage >= 3 ? 8 : 0
        } else {
            petalCount = 0
        }

        return InterpolatedPlant(
            stemTop: stemTop,
            stemBottom: stemBottom,
            leaves: leaves,
            flowerCenter: flowerCenter,
            flowerRadius: flowerRadius,
            petalCount: petalCount
        )
    }

    private func buildPath(from plant: InterpolatedPlant, in rect: CGRect) -> Path {
        var path = Path()

        // Soil mound
        let soilY = plant.stemBottom.y
        path.addEllipse(in: CGRect(
            x: plant.stemBottom.x - 20,
            y: soilY - 6,
            width: 40,
            height: 12
        ))

        // Stem
        path.move(to: plant.stemBottom)
        path.addLine(to: plant.stemTop)

        // Leaves
        for leaf in plant.leaves {
            guard leaf.count >= 3 else { continue }
            path.move(to: leaf[0])
            path.addQuadCurve(to: leaf[2], control: leaf[1])
            path.addQuadCurve(to: leaf[0], control: CGPoint(
                x: leaf[1].x + (leaf[0].x - leaf[2].x) * 0.15,
                y: leaf[1].y - 6
            ))
        }

        // Flower
        if let center = plant.flowerCenter, let radius = plant.flowerRadius, plant.petalCount > 0 {
            let petalRadius = radius * 0.6
            for i in 0..<plant.petalCount {
                let angle = (Double(i) / Double(plant.petalCount)) * .pi * 2
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * radius * 0.7,
                    y: center.y + sin(angle) * radius * 0.7
                )
                path.addEllipse(in: CGRect(
                    x: petalCenter.x - petalRadius,
                    y: petalCenter.y - petalRadius,
                    width: petalRadius * 2,
                    height: petalRadius * 2
                ))
            }
            // Center disc
            path.addEllipse(in: CGRect(
                x: center.x - radius * 0.4,
                y: center.y - radius * 0.4,
                width: radius * 0.8,
                height: radius * 0.8
            ))
        } else if let center = plant.flowerCenter, let radius = plant.flowerRadius {
            // Bud
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius * 1.4,
                width: radius * 2,
                height: radius * 2.8
            ))
        }

        return path
    }
}
