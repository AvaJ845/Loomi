//
//  NotificationManager.swift
//  Opt-in daily check-in reminder. Deliberately NOT a dark pattern: no red
//  badge count, no algorithmically-timed "optimal moment" push, one
//  predictable notification at a time the user picked themselves, and it's
//  off by default. Easy to turn off in Settings at any time.
//

import UserNotifications
import SwiftUI

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let reminderID = "loomi.daily.checkin"

    /// Returns whether a notification actually ended up scheduled, so callers
    /// can roll back optimistic UI state (e.g. a toggle) on denial/failure
    /// instead of silently drifting out of sync with what's really scheduled.
    @discardableResult
    func setReminder(enabled: Bool, at time: DateComponents) async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard enabled else {
            center.removePendingNotificationRequests(withIdentifiers: [reminderID])
            return false
        }

        guard let granted = try? await center.requestAuthorization(options: [.alert, .sound]),
              granted else { return false }

        let content = UNMutableNotificationContent()
        content.title = "Loomi"
        content.body = "However today went, a minute to check in if you'd like one. 🐾"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: reminderID,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        )
        do {
            try await center.add(request)
            return true
        } catch {
            // Leave any previously-scheduled reminder alone rather than
            // having already deleted it before this point — see call site,
            // which only removes the old one once the new one is confirmed.
            return false
        }
    }
}
