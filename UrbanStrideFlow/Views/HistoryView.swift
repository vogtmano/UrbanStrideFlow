import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    weeklySummary
                }

                Section("Today") {
                    NavigationLink {
                        HistoryDetailView(activity: viewModel.today, stepGoal: viewModel.settings.dailyStepGoal)
                    } label: {
                        HistoryRow(activity: viewModel.today)
                    }
                }

                Section("Previous Days") {
                    if viewModel.priorHistory.isEmpty {
                        ContentUnavailableView("No history yet", systemImage: "calendar.badge.clock", description: Text("Complete breaks and refresh steps to build your activity log."))
                    } else {
                        ForEach(viewModel.priorHistory) { activity in
                            NavigationLink {
                                HistoryDetailView(activity: activity, stepGoal: viewModel.settings.dailyStepGoal)
                            } label: {
                                HistoryRow(activity: activity)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private var weeklySummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 days")
                .font(.headline)
            HStack {
                summaryMetric("Avg steps", "\(viewModel.weeklyStepAverage.formatted())", "shoeprints.fill")
                summaryMetric("Breaks", "\(viewModel.weeklyBreakTotal)", "figure.cooldown")
                summaryMetric("Best", "\(viewModel.bestStepDay?.steps.formatted() ?? "0")", "chart.bar.fill")
            }
        }
        .padding(.vertical, 4)
    }

    private func summaryMetric(_ title: String, _ value: String, _ symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(.teal)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HistoryRow: View {
    let activity: DailyActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(activity.date, style: .date)
                    .font(.headline)
                Spacer()
                Image(systemName: activity.reachedStepGoal ? "checkmark.seal.fill" : "circle")
                    .foregroundStyle(activity.reachedStepGoal ? .green : .secondary)
            }

            HStack {
                Label("\(activity.steps.formatted())", systemImage: "shoeprints.fill")
                Spacer()
                Label("\(activity.completedBreaks)", systemImage: "figure.cooldown")
                Spacer()
                Label("\(activity.pointsEarned)", systemImage: "star.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let latestSession = activity.latestSession {
                Text("Last break: \(latestSession.completedAt, style: .time)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct HistoryDetailView: View {
    let activity: DailyActivity
    let stepGoal: Int

    private var progressRatio: Double {
        min(1, Double(activity.steps) / Double(max(stepGoal, 1)))
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text(activity.date, style: .date)
                        .font(.title3.weight(.bold))
                    ProgressView(value: progressRatio)
                        .tint(.teal)
                    Text("\(activity.steps.formatted()) of \(stepGoal.formatted()) steps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Daily totals") {
                LabeledContent("Completed breaks", value: "\(activity.completedBreaks)")
                LabeledContent("Active break minutes", value: "\(activity.activeMinutes)")
                LabeledContent("Flights climbed", value: "\(activity.flightsClimbed ?? 0)")
                LabeledContent("Points earned", value: "\(activity.pointsEarned)")
                LabeledContent("Step goal", value: activity.reachedStepGoal ? "Reached" : "Not reached")
            }

            Section("Stretch sessions") {
                if activity.stretchSessions.isEmpty {
                    ContentUnavailableView("No sessions", systemImage: "figure.cooldown")
                } else {
                    ForEach(activity.stretchSessions.sorted { $0.completedAt > $1.completedAt }) { session in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.completedAt, style: .time)
                                .font(.headline)
                            Text("\(session.durationSeconds / 60) min • \(session.exercises.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Point events") {
                if activity.pointEvents.isEmpty {
                    ContentUnavailableView("No point events", systemImage: "star")
                } else {
                    ForEach(activity.pointEvents.sorted { $0.date > $1.date }) { event in
                        HStack {
                            Label(event.title, systemImage: symbol(for: event.kind))
                            Spacer()
                            Text("+\(event.points)")
                                .font(.headline)
                                .foregroundStyle(.teal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Day Detail")
    }

    private func symbol(for kind: PointEventKind) -> String {
        switch kind {
        case .stretchSession:
            "figure.cooldown"
        case .stepGoal:
            "shoeprints.fill"
        case .stairs:
            "stairs"
        }
    }
}
