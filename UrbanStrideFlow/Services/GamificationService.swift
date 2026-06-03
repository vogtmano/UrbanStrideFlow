import Foundation

struct GamificationService {
    let stretchPoints = 10
    let stepGoalPoints = 30
    let stairsPoints = 15

    func completeStretch(activity: inout DailyActivity, progress: inout UserProgress, record: StretchSessionRecord) {
        activity.completedBreaks += 1
        activity.stretchSessions.append(record)
        activity.pointsEarned += stretchPoints
        activity.pointEvents.append(PointEvent(title: "Stretch session completed", points: stretchPoints, kind: .stretchSession))
        progress.totalPoints += stretchPoints
        progress.totalStretchSessions += 1
        unlockBadges(activity: activity, progress: &progress)
    }

    func evaluateActivity(activity: inout DailyActivity, progress: inout UserProgress, settings: AppSettings) {
        activity.reachedStepGoal = activity.steps >= settings.dailyStepGoal

        if activity.reachedStepGoal, !activity.awardedStepGoalPoints {
            activity.awardedStepGoalPoints = true
            activity.pointsEarned += stepGoalPoints
            activity.pointEvents.append(PointEvent(title: "Daily step goal reached", points: stepGoalPoints, kind: .stepGoal))
            progress.totalPoints += stepGoalPoints
        }

        if let flights = activity.flightsClimbed, flights > 0, !activity.awardedStairsPoints {
            activity.awardedStairsPoints = true
            activity.pointsEarned += stairsPoints
            activity.pointEvents.append(PointEvent(title: "Used stairs", points: stairsPoints, kind: .stairs))
            progress.totalPoints += stairsPoints
        }

        updateStreak(activity: activity, progress: &progress, settings: settings)
        unlockBadges(activity: activity, progress: &progress)
    }

    func badges(for progress: UserProgress) -> [Badge] {
        Badge.catalog.map { badge in
            var updated = badge
            updated.isUnlocked = progress.unlockedBadgeIDs.contains(badge.id)
            return updated
        }
    }

    private func updateStreak(activity: DailyActivity, progress: inout UserProgress, settings: AppSettings) {
        let dayKey = DailyActivity.dayKey(for: activity.date)
        guard progress.lastQualifiedStreakDayKey != dayKey else { return }

        let stepRatio = Double(activity.steps) / Double(max(settings.dailyStepGoal, 1))
        guard activity.completedBreaks > 0, stepRatio >= 0.7 else { return }

        if let lastKey = progress.lastQualifiedStreakDayKey,
           let lastDate = Self.dayFormatter.date(from: lastKey),
           Calendar.current.isDate(lastDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: activity.date) ?? activity.date) {
            progress.currentStreak += 1
        } else {
            progress.currentStreak = 1
        }

        progress.lastQualifiedStreakDayKey = dayKey
    }

    private func unlockBadges(activity: DailyActivity, progress: inout UserProgress) {
        if progress.totalStretchSessions >= 1 {
            unlock(.firstBreak, progress: &progress)
        }
        if progress.currentStreak >= 3 {
            unlock(.threeDayStreak, progress: &progress)
        }
        if progress.totalStretchSessions >= 10 {
            unlock(.tenStretchSessions, progress: &progress)
        }
        if activity.reachedStepGoal {
            unlock(.stepGoalHero, progress: &progress)
        }
        if (activity.flightsClimbed ?? 0) > 0 {
            unlock(.stairsInsteadOfElevator, progress: &progress)
        }
    }

    private func unlock(_ badgeID: BadgeID, progress: inout UserProgress) {
        let inserted = progress.unlockedBadgeIDs.insert(badgeID).inserted
        if inserted {
            progress.badgeUnlockDates[badgeID] = .now
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
