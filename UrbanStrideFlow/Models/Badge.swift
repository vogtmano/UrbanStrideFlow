import Foundation

enum BadgeID: String, CaseIterable, Codable {
    case firstBreak
    case threeDayStreak
    case tenStretchSessions
    case stepGoalHero
    case stairsInsteadOfElevator
}

struct Badge: Identifiable, Codable, Equatable {
    let id: BadgeID
    let title: String
    let symbolName: String
    let detail: String
    var isUnlocked: Bool

    static let catalog: [Badge] = [
        Badge(id: .firstBreak, title: "First Break", symbolName: "figure.cooldown", detail: "Complete your first stretch session.", isUnlocked: false),
        Badge(id: .threeDayStreak, title: "3-Day Streak", symbolName: "flame.fill", detail: "Keep moving for three days in a row.", isUnlocked: false),
        Badge(id: .tenStretchSessions, title: "10 Stretch Sessions", symbolName: "10.circle.fill", detail: "Finish ten guided movement breaks.", isUnlocked: false),
        Badge(id: .stepGoalHero, title: "Step Goal Hero", symbolName: "shoeprints.fill", detail: "Reach your daily step goal.", isUnlocked: false),
        Badge(id: .stairsInsteadOfElevator, title: "Stairs Instead of Elevator", symbolName: "stairs", detail: "Log flights climbed.", isUnlocked: false)
    ]
}
