//
//  SettingsView.swift
//  One screen: the opt-in daily reminder (off by default, one fixed time,
//  no badge/urgency tricks) and a quiet link to Loomi+. Both are easy to
//  ignore or turn off — retention without manipulation.
//

import SwiftUI

struct SettingsView: View {
    var goHome: () -> Void

    @AppStorage("loomi.reminder.enabled") private var reminderEnabled = false
    @AppStorage("loomi.reminder.hour")    private var reminderHour = 20
    @AppStorage("loomi.reminder.minute")  private var reminderMinute = 0
    @State private var scheduleTask: Task<Void, Never>?
    @EnvironmentObject private var entitlements: EntitlementStore
    @State private var showPaywall = false

    private var reminderDateComponents: DateComponents {
        DateComponents(hour: reminderHour, minute: reminderMinute)
    }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: reminderDateComponents) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = c.hour ?? 20
                reminderMinute = c.minute ?? 0
                if reminderEnabled { scheduleReminder() }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text("Settings").font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 10) {
                Toggle("Daily check-in reminder", isOn: $reminderEnabled)
                    .font(.baloo(16, .bold)).foregroundColor(.ink)
                    .tint(.brandRed)
                    .onChange(of: reminderEnabled) { _ in scheduleReminder() }

                Text("One quiet notification a day, at a time you choose. No badges, no nagging — off by default, and you can turn it off here any time.")
                    .font(.text(13)).foregroundColor(.muted)
                    .fixedSize(horizontal: false, vertical: true)

                if reminderEnabled {
                    DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .font(.baloo(15, .bold)).foregroundColor(.ink)
                        .datePickerStyle(.compact)
                }
            }
            .card()

            VStack(alignment: .leading, spacing: 6) {
                Text("Tips for staying calm").font(.baloo(16, .bold)).foregroundColor(.ink)
                Text("Use the reminder, journal, and support tools to make Loomi part of your calm routine.")
                    .font(.text(13)).foregroundColor(.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color.cream)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .navy.opacity(0.15), radius: 9, x: 0, y: 5)

            Button { showPaywall = true } label: {
                HStack {
                    Text(entitlements.isPlus ? "You're Loomi+ 🐾" : "Get Loomi+")
                        .font(.baloo(16, .bold)).foregroundColor(.ink)
                    Spacer()
                    if !entitlements.isPlus {
                        Text("→").font(.baloo(16, .bold)).foregroundColor(.redDeep)
                    }
                }
                .padding(16)
                .background(Color.cream)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .navy.opacity(0.15), radius: 9, x: 0, y: 5)
            }
            .buttonStyle(.plain)

            PuppyView(size: 110).frame(maxWidth: .infinity).padding(.top, 8)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onClose: { showPaywall = false })
        }
        // No onAppear reschedule: a successfully-scheduled UNCalendarNotificationTrigger
        // (repeats: true) persists on its own, so there's nothing to redo on
        // every visit — only actual enable/disable/time changes call this.
    }

    private func scheduleReminder() {
        scheduleTask?.cancel()
        let wantsEnabled = reminderEnabled
        let time = reminderDateComponents
        scheduleTask = Task {
            let succeeded = await NotificationManager.shared.setReminder(enabled: wantsEnabled, at: time)
            guard !Task.isCancelled else { return }
            // Roll back optimistic UI state if enabling failed (denied
            // permission or a scheduling error) — don't leave the toggle
            // showing "on" when nothing was actually scheduled.
            if wantsEnabled && !succeeded {
                reminderEnabled = false
            }
        }
    }
}
