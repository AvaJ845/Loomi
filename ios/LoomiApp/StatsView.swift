//
//  StatsView.swift
//  A gentle weekly view built entirely from local journal data — no new data
//  collection. Framing stays neutral and encouraging (never "you were stressed
//  a lot = bad"); it's a check-in, not a scorecard.
//

import SwiftUI
import Charts

struct DayBucket: Identifiable {
    let id = UUID()
    let date: Date
    let label: String       // "Mon"
    let count: Int
    let topMood: String?
}

struct StatsView: View {
    var goBack: () -> Void
    var goInsights: () -> Void
    @EnvironmentObject private var store: JournalStore

    private var cal: Calendar { Calendar.current }

    // last 7 days, oldest → today
    private var week: [DayBucket] {
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        return (0..<7).reversed().map { back in
            let day = cal.date(byAdding: .day, value: -back, to: today)!
            let dayEntries = store.entries.filter { cal.isDate($0.date, inSameDayAs: day) }
            let top = Dictionary(grouping: dayEntries, by: { $0.mood })
                .max { $0.value.count < $1.value.count }?.key
            return DayBucket(date: day, label: fmt.string(from: day),
                             count: dayEntries.count, topMood: top)
        }
    }
    private var weekTotal: Int { week.reduce(0) { $0 + $1.count } }
    private var daysJournaled: Int { week.filter { $0.count > 0 }.count }
    private var streak: Int {
        var s = 0
        for b in week.reversed() { if b.count > 0 { s += 1 } else { break } }
        return s
    }
    private var moodCounts: [(Mood, Int)] {
        MOODS.map { m in
            (m, store.entries.filter { week.first!.date <= $0.date && $0.mood == m.key }.count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                BackButton(action: goBack)
                Text("Your week").font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .padding(.vertical, 4)

            if weekTotal == 0 {
                VStack(spacing: 10) {
                    PuppyView(size: 140)
                    Text("No check-ins yet this week.").font(.baloo(18, .bold)).foregroundColor(.ink)
                    Text("Jot a quick note in the Journal and your week will show up here.")
                        .font(.text(14)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 300)
                }
                .frame(maxWidth: .infinity).padding(.top, 30)
            } else {
                HStack(spacing: 12) {
                    statTile("\(weekTotal)", "check-ins")
                    statTile("\(daysJournaled)/7", "days")
                    statTile("\(streak)", "day streak")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("CHECK-INS PER DAY").font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)
                    Chart(week) { b in
                        BarMark(
                            x: .value("Day", b.label),
                            y: .value("Check-ins", b.count)
                        )
                        .foregroundStyle(b.topMood.map(moodColor) ?? Color.roseDeep)
                        .cornerRadius(6)
                    }
                    .chartYAxis { AxisMarks(values: .automatic(desiredCount: 3)) }
                    .frame(height: 170)
                }
                .card()

                VStack(alignment: .leading, spacing: 10) {
                    Text("HOW IT FELT").font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)
                    ForEach(moodCounts, id: \.0.id) { m, n in
                        HStack(spacing: 10) {
                            Text(m.emoji)
                            Text(m.key).font(.baloo(15, .bold)).foregroundColor(.ink)
                            Spacer()
                            Text("\(n)").font(.baloo(15, .bold)).foregroundColor(m.color)
                        }
                        if m.key != MOODS.last?.key { Divider().opacity(0.4) }
                    }
                }
                .card()

                Text("However the week looked, showing up for yourself counts. 🐾")
                    .font(.text(14)).foregroundColor(.muted)
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 2)
            }

            Button(action: goInsights) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Insights").font(.baloo(16, .bold)).foregroundColor(.ink)
                        Text("Patterns from your check-ins, found on this phone").font(.text(12.5)).foregroundColor(.muted)
                    }
                    Spacer()
                    Text("→").font(.baloo(18, .bold)).foregroundColor(.redDeep)
                }
                .padding(16)
                .background(Color.cream)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .navy.opacity(0.15), radius: 9, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    private func statTile(_ big: String, _ small: String) -> some View {
        VStack(spacing: 2) {
            Text(big).font(.baloo(28, .heavy)).foregroundColor(.brandRed)
            Text(small).font(.text(12.5, .semibold)).foregroundColor(.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .navy.opacity(0.15), radius: 9, x: 0, y: 5)
    }
}
