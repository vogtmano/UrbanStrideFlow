import Foundation

final class PersistenceService {
    private enum Key {
        static let settings = "urbanstride.settings"
        static let progress = "urbanstride.progress"
        static let activities = "urbanstride.activities"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> AppSettings {
        load(AppSettings.self, forKey: Key.settings) ?? .defaults
    }

    func saveSettings(_ settings: AppSettings) {
        save(settings, forKey: Key.settings)
    }

    func loadProgress() -> UserProgress {
        load(UserProgress.self, forKey: Key.progress) ?? .empty
    }

    func saveProgress(_ progress: UserProgress) {
        save(progress, forKey: Key.progress)
    }

    func loadActivities() -> [DailyActivity] {
        load([DailyActivity].self, forKey: Key.activities) ?? Self.demoHistory
    }

    func saveActivities(_ activities: [DailyActivity]) {
        save(activities.sorted { $0.date > $1.date }, forKey: Key.activities)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static var demoHistory: [DailyActivity] {
        let calendar = Calendar.current
        return (1...5).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            let steps = [7_250, 8_420, 6_980, 9_120, 8_050][offset - 1]
            let breaks = [2, 3, 1, 4, 2][offset - 1]
            return DailyActivity(
                date: date,
                steps: steps,
                flightsClimbed: offset.isMultiple(of: 2) ? 4 : nil,
                completedBreaks: breaks,
                pointsEarned: breaks * 10 + (steps >= 8_000 ? 30 : 0),
                reachedStepGoal: steps >= 8_000,
                awardedStepGoalPoints: steps >= 8_000,
                awardedStairsPoints: offset.isMultiple(of: 2),
                stretchSessions: (0..<breaks).map { sessionOffset in
                    StretchSessionRecord(
                        completedAt: calendar.date(byAdding: .hour, value: 10 + sessionOffset * 2, to: calendar.startOfDay(for: date)) ?? date,
                        exercises: ["Neck stretch", "Shoulder rolls", "Side bends", "Wrist stretch", "Stand and walk"]
                    )
                },
                pointEvents: [
                    PointEvent(date: date, title: "Stretch sessions", points: breaks * 10, kind: .stretchSession)
                ] + (steps >= 8_000 ? [PointEvent(date: date, title: "Daily step goal reached", points: 30, kind: .stepGoal)] : [])
            )
        }
    }
}
