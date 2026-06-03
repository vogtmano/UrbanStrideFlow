import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let symbolName: String
    var tint: Color = .teal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundStyle(tint)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
