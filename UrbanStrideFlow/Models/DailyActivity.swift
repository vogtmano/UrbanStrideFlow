import Foundation

struct DailyActivity: Identifiable, Codable, Equatable {
    var id: String { Self.dayKey(for: date) }

    var date: Date
    var steps: Int
    var flightsClimbed: Int?
    var completedBreaks: Int
    var pointsEarned: Int
    var reachedStepGoal: Bool
    var awardedStepGoalPoints: Bool
    var awardedStairsPoints: Bool
    var stretchSessions: [StretchSessionRecord]
    var pointEvents: [PointEvent]

    init(
        date: Date = .now,
        steps: Int = 0,
        flightsClimbed: Int? = nil,
        completedBreaks: Int = 0,
        pointsEarned: Int = 0,
        reachedStepGoal: Bool = false,
        awardedStepGoalPoints: Bool = false,
        awardedStairsPoints: Bool = false,
        stretchSessions: [StretchSessionRecord] = [],
        pointEvents: [PointEvent] = []
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.steps = steps
        self.flightsClimbed = flightsClimbed
        self.completedBreaks = completedBreaks
        self.pointsEarned = pointsEarned
        self.reachedStepGoal = reachedStepGoal
        self.awardedStepGoalPoints = awardedStepGoalPoints
        self.awardedStairsPoints = awardedStairsPoints
        self.stretchSessions = stretchSessions
        self.pointEvents = pointEvents
    }

    var activeMinutes: Int {
        stretchSessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var latestSession: StretchSessionRecord? {
        stretchSessions.sorted { $0.completedAt > $1.completedAt }.first
    }

    enum CodingKeys: String, CodingKey {
        case date
        case steps
        case flightsClimbed
        case completedBreaks
        case pointsEarned
        case reachedStepGoal
        case awardedStepGoalPoints
        case awardedStairsPoints
        case stretchSessions
        case pointEvents
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        steps = try container.decode(Int.self, forKey: .steps)
        flightsClimbed = try container.decodeIfPresent(Int.self, forKey: .flightsClimbed)
        completedBreaks = try container.decode(Int.self, forKey: .completedBreaks)
        pointsEarned = try container.decode(Int.self, forKey: .pointsEarned)
        reachedStepGoal = try container.decode(Bool.self, forKey: .reachedStepGoal)
        awardedStepGoalPoints = try container.decode(Bool.self, forKey: .awardedStepGoalPoints)
        awardedStairsPoints = try container.decode(Bool.self, forKey: .awardedStairsPoints)
        stretchSessions = try container.decodeIfPresent([StretchSessionRecord].self, forKey: .stretchSessions) ?? []
        pointEvents = try container.decodeIfPresent([PointEvent].self, forKey: .pointEvents) ?? []
    }

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
