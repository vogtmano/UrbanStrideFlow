import Foundation
import Combine
import UserNotifications

@MainActor
final class AppViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var today: DailyActivity
    @Published var history: [DailyActivity]
    @Published var progress: UserProgress
    @Published var healthStatus: HealthPermissionStatus = .notDetermined
    @Published var notificationStatusText = "Not checked"
    @Published var isLoadingHealth = false

    private let persistence: PersistenceService
    private let healthKit: HealthKitService
    private let notifications: NotificationService
    private let gamification: GamificationService

    init(
        persistence: PersistenceService? = nil,
        healthKit: HealthKitService? = nil,
        notifications: NotificationService? = nil,
        gamification: GamificationService? = nil
    ) {
        self.persistence = persistence ?? PersistenceService()
        self.healthKit = healthKit ?? HealthKitService()
        self.notifications = notifications ?? NotificationService()
        self.gamification = gamification ?? GamificationService()

        let loadedSettings = self.persistence.loadSettings()
        let loadedHistory = self.persistence.loadActivities()
        self.settings = loadedSettings
        self.history = loadedHistory
        self.progress = self.persistence.loadProgress()
        self.today = loadedHistory.first { Calendar.current.isDateInToday($0.date) } ?? DailyActivity()
        self.healthStatus = self.healthKit.authorizationStatus()
    }

    var progressRatio: Double {
        min(1, Double(today.steps) / Double(max(settings.dailyStepGoal, 1)))
    }

    var progressPercent: Int {
        Int((progressRatio * 100).rounded())
    }

    var badges: [Badge] {
        gamification.badges(for: progress)
    }

    var priorHistory: [DailyActivity] {
        history
            .filter { !Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    var weeklyActivities: [DailyActivity] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            return history.first { calendar.isDate($0.date, inSameDayAs: date) } ?? DailyActivity(date: date)
        }
        .sorted { $0.date < $1.date }
    }

    var weeklyStepAverage: Int {
        let activities = weeklyActivities
        guard !activities.isEmpty else { return 0 }
        return activities.reduce(0) { $0 + $1.steps } / activities.count
    }

    var weeklyBreakTotal: Int {
        weeklyActivities.reduce(0) { $0 + $1.completedBreaks }
    }

    var bestStepDay: DailyActivity? {
        history.max { $0.steps < $1.steps }
    }

    func refreshHealthData() async {
        isLoadingHealth = true
        healthStatus = healthKit.authorizationStatus()
        let snapshot = await healthKit.todaySnapshot()

        today.steps = snapshot.steps
        today.flightsClimbed = snapshot.flightsClimbed
        gamification.evaluateActivity(activity: &today, progress: &progress, settings: settings)
        persistToday()

        if snapshot.isDemoData {
            healthStatus = healthKit.isHealthDataAvailable ? .sharingDenied : .unavailable
        } else {
            healthStatus = healthKit.authorizationStatus()
        }
        isLoadingHealth = false
    }

    func requestHealthPermissions() async {
        _ = await healthKit.requestAuthorization()
        healthStatus = healthKit.authorizationStatus()
        await refreshHealthData()
    }

    func completeStretchSession(exercises: [String], durationSeconds: Int = 180) -> StretchCompletionResult {
        let oldBadges = progress.unlockedBadgeIDs
        let record = StretchSessionRecord(durationSeconds: durationSeconds, exercises: exercises)

        gamification.completeStretch(activity: &today, progress: &progress, record: record)
        gamification.evaluateActivity(activity: &today, progress: &progress, settings: settings)
        persistToday()

        let newBadgeIDs = progress.unlockedBadgeIDs.subtracting(oldBadges)
        let unlockedBadges = badges.filter { newBadgeIDs.contains($0.id) }
        return StretchCompletionResult(
            pointsAwarded: gamification.stretchPoints,
            totalPoints: progress.totalPoints,
            level: progress.level,
            completedBreaksToday: today.completedBreaks,
            newlyUnlockedBadges: unlockedBadges
        )
    }

    func saveSettings() {
        if settings.dailyStepGoal < 1_000 {
            settings.dailyStepGoal = 1_000
        }
        if settings.workEndMinutes <= settings.workStartMinutes {
            settings.workEndHour = min(23, settings.workStartHour + 1)
            settings.workEndMinute = settings.workStartMinute
        }

        gamification.evaluateActivity(activity: &today, progress: &progress, settings: settings)
        persistence.saveSettings(settings)
        persistToday()
    }

    func updateReminders(enabled: Bool) async {
        settings.remindersEnabled = enabled
        saveSettings()
        if enabled {
            await scheduleReminders()
        } else {
            await notifications.removeMovementReminders()
        }
        await refreshNotificationStatus()
    }

    func scheduleReminders() async {
        saveSettings()
        await notifications.scheduleMovementReminders(settings: settings)
        await refreshNotificationStatus()
    }

    func refreshNotificationStatus() async {
        let status = await notifications.notificationStatus()
        switch status {
        case .notDetermined:
            notificationStatusText = "Not Determined"
        case .denied:
            notificationStatusText = "Denied"
        case .authorized:
            notificationStatusText = "Authorized"
        case .provisional:
            notificationStatusText = "Provisional"
        case .ephemeral:
            notificationStatusText = "Ephemeral"
        @unknown default:
            notificationStatusText = "Unknown"
        }
    }

    private func persistToday() {
        var updated = history.filter { !Calendar.current.isDate($0.date, inSameDayAs: today.date) }
        updated.append(today)
        history = updated.sorted { $0.date > $1.date }
        persistence.saveActivities(history)
        persistence.saveProgress(progress)
    }
}
