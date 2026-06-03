import Foundation
import UserNotifications

final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let reminderPrefix = "urbanstride.move."

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func scheduleMovementReminders(settings: AppSettings) async {
        await removeMovementReminders()
        guard settings.remindersEnabled else { return }

        _ = await requestPermission()

        let times = reminderTimes(from: settings)
        for (index, minutes) in times.enumerated() {
            var components = DateComponents()
            components.hour = minutes / 60
            components.minute = minutes % 60

            let content = UNMutableNotificationContent()
            content.title = "Time to move"
            content.body = "Take a 3-minute UrbanStride & Flow break."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "\(reminderPrefix)\(index)", content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    func removeMovementReminders() async {
        let requests = await center.pendingNotificationRequests()
        let ids = requests.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func reminderTimes(from settings: AppSettings) -> [Int] {
        guard settings.workEndMinutes > settings.workStartMinutes else { return [] }

        var times: [Int] = []
        var current = settings.workStartMinutes
        while current < settings.workEndMinutes {
            times.append(current)
            current += 90
        }
        return times
    }
}
