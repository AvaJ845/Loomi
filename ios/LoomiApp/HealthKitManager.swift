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

    /// Save a mindful session covering [start, end]. Requests authorization
    /// first if it hasn't been granted yet, so a save right after the first
    /// breathing session doesn't silently lose the prompt race.
    func logMindfulSession(start: Date, end: Date) {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = mindfulType,
              end > start else { return }
        let sample = HKCategorySample(type: type,
                                      value: HKCategoryValue.notApplicable.rawValue,
                                      start: start, end: end)
        if store.authorizationStatus(for: type) == .notDetermined {
            store.requestAuthorization(toShare: [type], read: []) { [store] _, _ in
                store.save(sample) { _, _ in }
            }
        } else {
            store.save(sample) { _, _ in }
        }
    }
}
