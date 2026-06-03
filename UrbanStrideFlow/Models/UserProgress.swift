import Foundation

struct UserProgress: Codable, Equatable {
    var totalPoints: Int
    var currentStreak: Int
    var lastQualifiedStreakDayKey: String?
    var totalStretchSessions: Int
    var unlockedBadgeIDs: Set<BadgeID>
    var badgeUnlockDates: [BadgeID: Date]

    static let empty = UserProgress(
        totalPoints: 0,
        currentStreak: 0,
        lastQualifiedStreakDayKey: nil,
        totalStretchSessions: 0,
        unlockedBadgeIDs: [],
        badgeUnlockDates: [:]
    )

    var level: Int {
        max(1, totalPoints / 100 + 1)
    }

    var pointsIntoCurrentLevel: Int {
        totalPoints % 100
    }

    var pointsToNextLevel: Int {
        100 - pointsIntoCurrentLevel
    }

    enum CodingKeys: String, CodingKey {
        case totalPoints
        case currentStreak
        case lastQualifiedStreakDayKey
        case totalStretchSessions
        case unlockedBadgeIDs
        case badgeUnlockDates
    }

    init(
        totalPoints: Int,
        currentStreak: Int,
        lastQualifiedStreakDayKey: String?,
        totalStretchSessions: Int,
        unlockedBadgeIDs: Set<BadgeID>,
        badgeUnlockDates: [BadgeID: Date]
    ) {
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.lastQualifiedStreakDayKey = lastQualifiedStreakDayKey
        self.totalStretchSessions = totalStretchSessions
        self.unlockedBadgeIDs = unlockedBadgeIDs
        self.badgeUnlockDates = badgeUnlockDates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        lastQualifiedStreakDayKey = try container.decodeIfPresent(String.self, forKey: .lastQualifiedStreakDayKey)
        totalStretchSessions = try container.decode(Int.self, forKey: .totalStretchSessions)
        unlockedBadgeIDs = try container.decode(Set<BadgeID>.self, forKey: .unlockedBadgeIDs)
        badgeUnlockDates = try container.decodeIfPresent([BadgeID: Date].self, forKey: .badgeUnlockDates) ?? [:]
    }
}
