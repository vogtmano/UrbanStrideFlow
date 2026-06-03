import Foundation

struct StretchCompletionResult: Equatable {
    let pointsAwarded: Int
    let totalPoints: Int
    let level: Int
    let completedBreaksToday: Int
    let newlyUnlockedBadges: [Badge]
}
