import Foundation

struct StretchSessionRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var completedAt: Date
    var durationSeconds: Int
    var exercises: [String]

    init(
        id: UUID = UUID(),
        completedAt: Date = .now,
        durationSeconds: Int = 180,
        exercises: [String]
    ) {
        self.id = id
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.exercises = exercises
    }
}
