import SwiftUI

struct BadgesView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    levelCard
                    progressStats
                    weeklyChart
                    badgesGrid
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }

    private var levelCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
            Text("Level \(viewModel.progress.level)")
                .font(.title.weight(.bold))
            Text("\(viewModel.progress.totalPoints) total points")
                .foregroundStyle(.secondary)
            ProgressView(value: Double(viewModel.progress.pointsIntoCurrentLevel), total: 100)
                .tint(.teal)
            Text("\(viewModel.progress.pointsToNextLevel) points to next level")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var progressStats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Stretch Sessions", value: "\(viewModel.progress.totalStretchSessions)", symbolName: "figure.cooldown", tint: .teal)
            MetricCard(title: "Current Streak", value: "\(viewModel.progress.currentStreak) days", symbolName: "flame.fill", tint: .orange)
            MetricCard(title: "7-Day Breaks", value: "\(viewModel.weeklyBreakTotal)", symbolName: "calendar", tint: .blue)
            MetricCard(title: "Avg Steps", value: "\(viewModel.weeklyStepAverage.formatted())", symbolName: "shoeprints.fill", tint: .green)
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step trend")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.weeklyActivities) { activity in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(activity.reachedStepGoal ? Color.green : Color.teal)
                            .frame(height: max(8, CGFloat(min(activity.steps, viewModel.settings.dailyStepGoal)) / CGFloat(max(viewModel.settings.dailyStepGoal, 1)) * 120))
                        Text(activity.date, format: .dateTime.weekday(.narrow))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150)

            Text("Bars cap at your daily goal of \(viewModel.settings.dailyStepGoal.formatted()) steps.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var badgesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(viewModel.badges) { badge in
                NavigationLink {
                    BadgeDetailView(
                        badge: badge,
                        unlockedAt: viewModel.progress.badgeUnlockDates[badge.id],
                        progress: viewModel.progress
                    )
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: badge.symbolName)
                            .font(.title)
                            .foregroundStyle(badge.isUnlocked ? .teal : .secondary)
                        Text(badge.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text(badge.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text(badge.isUnlocked ? "Unlocked" : "Locked")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(badge.isUnlocked ? .green : .secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 170)
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .opacity(badge.isUnlocked ? 1 : 0.62)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct BadgeDetailView: View {
    let badge: Badge
    let unlockedAt: Date?
    let progress: UserProgress

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    Image(systemName: badge.symbolName)
                        .font(.system(size: 58))
                        .foregroundStyle(badge.isUnlocked ? .teal : .secondary)
                    Text(badge.title)
                        .font(.title2.weight(.bold))
                    Text(badge.detail)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Text(badge.isUnlocked ? "Unlocked" : "Locked")
                        .font(.headline)
                        .foregroundStyle(badge.isUnlocked ? .green : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Progress") {
                LabeledContent("Total points", value: "\(progress.totalPoints)")
                LabeledContent("Level", value: "\(progress.level)")
                LabeledContent("Stretch sessions", value: "\(progress.totalStretchSessions)")
                LabeledContent("Current streak", value: "\(progress.currentStreak) days")
                if let unlockedAt {
                    LabeledContent("Unlocked", value: unlockedAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
        }
        .navigationTitle("Badge")
    }
}
