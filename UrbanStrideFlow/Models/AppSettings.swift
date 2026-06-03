import Foundation

struct AppSettings: Codable, Equatable {
    var dailyStepGoal: Int
    var remindersEnabled: Bool
    var workStartHour: Int
    var workStartMinute: Int
    var workEndHour: Int
    var workEndMinute: Int

    static let defaults = AppSettings(
        dailyStepGoal: 8_000,
        remindersEnabled: true,
        workStartHour: 9,
        workStartMinute: 0,
        workEndHour: 17,
        workEndMinute: 0
    )

    var workStartMinutes: Int {
        workStartHour * 60 + workStartMinute
    }

    var workEndMinutes: Int {
        workEndHour * 60 + workEndMinute
    }
}
