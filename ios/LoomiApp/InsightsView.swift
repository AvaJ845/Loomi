//
//  InsightsView.swift
//  Loomi+'s real differentiator: simple pattern recognition over the journal
//  and relief-session history, computed entirely on-device. Nothing here is
//  uploaded anywhere — that's the point, and it's the thing Calm/Headspace's
//  account-based architecture can't credibly claim.
//

import SwiftUI

struct InsightsView: View {
    var goHome: () -> Void
    @EnvironmentObject private var journal: JournalStore
    @EnvironmentObject private var entitlements: EntitlementStore
    @State private var showPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text("Your Insights").font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .padding(.vertical, 4)

            Text("Built entirely from what's already on this phone — your check-ins never leave it.")
                .font(.text(13.5)).foregroundColor(.muted)

            if entitlements.isPlus {
                unlocked
            } else {
                locked
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onClose: { showPaywall = false })
        }
    }

    // MARK: - Unlocked

    @ViewBuilder private var unlocked: some View {
        if !hasEnoughData {
            VStack(spacing: 10) {
                PuppyView(size: 130)
                Text("Not enough check-ins yet.").font(.baloo(17, .bold)).foregroundColor(.ink)
                Text("Use the relief button a few more times and jot a journal entry or two — insights show up once there's a pattern to find.")
                    .font(.text(14)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity).padding(.top, 30)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                if let day = toughestDay {
                    insightCard("📅", "Your toughest day", "\(day) tends to bring up the most stress in your check-ins.")
                }
                if let rate = calmerRate {
                    insightCard("🫧", "Does the relief flow help?", "You've felt calmer or better after \(rate) of your \(journal.reliefSessions.count) relief sessions.")
                }
                if let mood = mostCommonMood {
                    insightCard("💛", "Most logged mood", "\"\(mood)\" shows up most often in your journal.")
                }
            }
        }
    }

    private func insightCard(_ icon: String, _ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(icon).font(.system(size: 22))
            Text(title).font(.baloo(16, .bold)).foregroundColor(.ink)
            Text(body).font(.text(14)).foregroundColor(.muted).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var hasEnoughData: Bool {
        journal.entries.count >= 3 || journal.reliefSessions.count >= 3
    }

    private var toughestDay: String? {
        let stressEntries = journal.entries.filter { $0.mood == "Stressed" || $0.mood == "Overwhelmed" }
        guard !stressEntries.isEmpty else { return nil }
        let fmt = DateFormatter(); fmt.dateFormat = "EEEE"
        let counts = Dictionary(grouping: stressEntries) { fmt.string(from: $0.date) }
        return counts.max { $0.value.count < $1.value.count }?.key
    }

    private var calmerRate: String? {
        guard !journal.reliefSessions.isEmpty else { return nil }
        let helped = journal.reliefSessions.filter { $0.outcome != .stillRough }.count
        let pct = Int((Double(helped) / Double(journal.reliefSessions.count) * 100).rounded())
        return "\(pct)%"
    }

    private var mostCommonMood: String? {
        guard !journal.entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: journal.entries, by: { $0.mood })
        return counts.max { $0.value.count < $1.value.count }?.key
    }

    // MARK: - Locked

    private var locked: some View {
        VStack(spacing: 12) {
            PuppyView(size: 130)
            Text("See your patterns").font(.baloo(18, .bold)).foregroundColor(.ink)
            Text("Loomi+ unlocks on-device insights — your toughest days, whether the relief flow is actually helping, and your full check-in history. Computed on this phone, never uploaded.")
                .font(.text(14)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 320)
            Button {
                showPaywall = true
            } label: {
                Text("Unlock Loomi+").font(.baloo(17, .bold)).foregroundColor(.cream)
                    .frame(maxWidth: .infinity).padding(16)
                    .background(Color.brandRed)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity).padding(.top, 20)
    }
}
