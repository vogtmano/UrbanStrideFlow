import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: 14)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(colors: [.teal, .green], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.title.weight(.bold))
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 150, height: 150)
        .accessibilityElement(children: .combine)
    }
}
