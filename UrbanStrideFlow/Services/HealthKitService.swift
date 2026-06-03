import Foundation
import HealthKit

enum HealthPermissionStatus: String {
    case unavailable = "Unavailable"
    case notDetermined = "Not Determined"
    case sharingDenied = "Denied"
    case sharingAuthorized = "Authorized"
}

struct HealthSnapshot {
    let steps: Int
    let flightsClimbed: Int?
    let isDemoData: Bool
}

final class HealthKitService {
    private let store = HKHealthStore()

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func authorizationStatus() -> HealthPermissionStatus {
        guard isHealthDataAvailable, let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return .unavailable
        }

        switch store.authorizationStatus(for: stepType) {
        case .notDetermined:
            return .notDetermined
        case .sharingDenied:
            return .sharingDenied
        case .sharingAuthorized:
            return .sharingAuthorized
        @unknown default:
            return .notDetermined
        }
    }

    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable else { return false }

        var readTypes: Set<HKObjectType> = []
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) {
            readTypes.insert(steps)
        }
        if let flights = HKObjectType.quantityType(forIdentifier: .flightsClimbed) {
            readTypes.insert(flights)
        }

        guard !readTypes.isEmpty else { return false }

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            return authorizationStatus() == .sharingAuthorized
        } catch {
            return false
        }
    }

    func todaySnapshot() async -> HealthSnapshot {
        guard isHealthDataAvailable else {
            return Self.demoSnapshot
        }

        async let steps = quantitySum(for: .stepCount, unit: .count())
        async let flights = quantitySum(for: .flightsClimbed, unit: .count())

        let snapshot = await HealthSnapshot(
            steps: steps ?? Self.demoSnapshot.steps,
            flightsClimbed: flights,
            isDemoData: authorizationStatus() != .sharingAuthorized
        )

        if snapshot.isDemoData {
            return Self.demoSnapshot
        }

        return snapshot
    }

    private func quantitySum(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Int? {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return nil }

        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value.map { Int($0.rounded()) })
            }
            store.execute(query)
        }
    }

    private static var demoSnapshot: HealthSnapshot {
        let hour = Calendar.current.component(.hour, from: .now)
        let steps = min(8_750, max(1_500, hour * 430))
        return HealthSnapshot(steps: steps, flightsClimbed: 3, isDemoData: true)
    }
}
