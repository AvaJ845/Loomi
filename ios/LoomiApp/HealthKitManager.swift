//
//  HealthKitManager.swift
//  Logs a completed breathing session as a Mindful Session in Apple Health.
//
//  Setup (see README): add the HealthKit capability to the app target and an
//  Info.plist entry "Privacy - Health Update Usage Description"
//  (NSHealthUpdateUsageDescription). No data is read; Loomi only writes
//  mindful minutes, and only if the user grants permission.
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    private var mindfulType: HKCategoryType? {
        HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }

    /// Ask once for permission to write mindful minutes.
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable(), let type = mindfulType else { return }
        store.requestAuthorization(toShare: [type], read: []) { _, _ in }
    }

    /// Save a mindful session covering [start, end].
    func logMindfulSession(start: Date, end: Date) {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = mindfulType,
              end > start else { return }
        let sample = HKCategorySample(type: type,
                                      value: HKCategoryValue.notApplicable.rawValue,
                                      start: start, end: end)
        store.save(sample) { _, _ in }
    }
}
