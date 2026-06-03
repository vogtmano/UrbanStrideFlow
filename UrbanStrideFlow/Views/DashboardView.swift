import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    progressCard
                    metricsGrid
                    stretchButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("UrbanStride & Flow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refreshHealthData() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh health data")
                }
            }
            .task {
                await viewModel.refreshHealthData()
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Move a little. Feel better.")
                    .font(.title2.weight(.bold))
                Text("Short breaks and steady steps help reset your workday.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "figure.walk.motion")
                .font(.largeTitle)
                .foregroundStyle(.teal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            ProgressRing(progress: viewModel.progressRatio, label: "Daily goal")

            VStack(spacing: 8) {
                Text("\(viewModel.today.steps.formatted()) steps")
                    .font(.title.weight(.bold))
                Text("Goal: \(viewModel.settings.dailyStepGoal.formatted()) steps")
                    .foregroundStyle(.secondary)

                if viewModel.healthStatus != .sharingAuthorized {
                    Label("Using demo movement data", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Progress", value: "\(viewModel.progressPercent)%", symbolName: "chart.line.uptrend.xyaxis", tint: .green)
            MetricCard(title: "Breaks Today", value: "\(viewModel.today.completedBreaks)", symbolName: "figure.cooldown", tint: .blue)
            MetricCard(title: "Current Streak", value: "\(viewModel.progress.currentStreak) days", symbolName: "flame.fill", tint: .orange)
            MetricCard(title: "Points", value: "\(viewModel.progress.totalPoints)", symbolName: "star.fill", tint: .yellow)
            MetricCard(title: "Level", value: "\(viewModel.progress.level)", symbolName: "trophy.fill", tint: .purple)
            MetricCard(title: "Flights", value: "\(viewModel.today.flightsClimbed ?? 0)", symbolName: "stairs", tint: .mint)
        }
    }

    private var stretchButton: some View {
        NavigationLink {
            StretchSessionView {
                viewModel.completeStretchSession(exercises: $0, durationSeconds: $1)
            }
        } label: {
            Label("Start 3-Min Stretch", systemImage: "play.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.teal)
    }
}
