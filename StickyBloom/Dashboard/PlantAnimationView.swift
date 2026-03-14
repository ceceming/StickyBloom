import SwiftUI

struct PlantAnimationView: View {
    @State private var animatedProgress: Double = PlantStage.overallProgress()
    @State private var currentStage: PlantStage = PlantStage.current().stage

    var body: some View {
        TimelineView(.animation(minimumInterval: 60, paused: false)) { context in
            let now = context.date
            let (stage, _) = PlantStage.current(date: now)
            let overallProgress = PlantStage.overallProgress(date: now)

            VStack(spacing: 8) {
                ZStack {
                    // Plant layers
                    let (stemColor, leafColor, flowerColor) = PlantAnimationController.gradientColors(
                        for: stage,
                        progress: overallProgress
                    )

                    // Stem and soil
                    PlantShape(animatableData: animatedProgress)
                        .fill(stemColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Leaves layer (slightly different color)
                    PlantShape(animatableData: animatedProgress)
                        .fill(leafColor.opacity(0.7))
                        .blendMode(.overlay)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Flower color
                    if let fc = flowerColor {
                        PlantShape(animatableData: animatedProgress)
                            .fill(fc.opacity(0.9))
                            .blendMode(.screen)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 180)
                .onChange(of: overallProgress) { newValue in
                    withAnimation(.easeInOut(duration: 2.0)) {
                        animatedProgress = newValue
                    }
                    currentStage = stage
                }

                Text(PlantAnimationController.statusText(stage: stage, progress: overallProgress))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .animation(.easeInOut, value: stage.rawValue)
            }
        }
        .onAppear {
            let progress = PlantStage.overallProgress()
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
    }
}
