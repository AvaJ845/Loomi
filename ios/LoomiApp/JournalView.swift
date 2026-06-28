//
//  JournalView.swift
//  A private, on-device journal: tag a mood, jot a note, see past entries.
//  Stored locally in UserDefaults (no account, no network, no tracking) —
//  which doubles as a privacy selling point vs. competitors.
//

import SwiftUI

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mood: String
    var text: String
}

struct Mood: Identifiable {
    let id = UUID()
    let key: String
    let emoji: String
    let color: Color
}

let MOODS: [Mood] = [
    Mood(key: "Calm",        emoji: "😌", color: .tan),
    Mood(key: "Okay",        emoji: "🙂", color: .gold),
    Mood(key: "Stressed",    emoji: "😣", color: Color(hex: 0xCC7A3D)),
    Mood(key: "Overwhelmed", emoji: "😵‍💫", color: .brandRed),
]
func moodColor(_ key: String) -> Color { MOODS.first { $0.key == key }?.color ?? .muted }
func moodEmoji(_ key: String) -> String { MOODS.first { $0.key == key }?.emoji ?? "•" }

/// Self-reported outcome of a relief session — "did that help?" — logged locally
/// only, so the app can tell whether the core loop actually works without any
/// analytics backend or tracking.
enum ReliefOutcome: String, Codable { case calmer, better, stillRough }

struct ReliefSession: Identifiable, Codable {
    let id: UUID
    var date: Date
    var outcome: ReliefOutcome
}

final class JournalStore: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    @Published private(set) var reliefSessions: [ReliefSession] = []
    private let key = "loomi.journal.entries.v1"
    private let sessionsKey = "loomi.relief.sessions.v1"

    init() { load() }

    func add(mood: String, text: String) {
        entries.insert(JournalEntry(id: UUID(), date: Date(), mood: mood, text: text), at: 0)
        save()
    }
    func delete(_ e: JournalEntry) {
        entries.removeAll { $0.id == e.id }
        save()
    }
    func logReliefOutcome(_ outcome: ReliefOutcome) {
        reliefSessions.insert(ReliefSession(id: UUID(), date: Date(), outcome: outcome), at: 0)
        saveSessions()
    }
    private func load() {
        if let d = UserDefaults.standard.data(forKey: key),
           let arr = try? JSONDecoder().decode([JournalEntry].self, from: d) {
            entries = arr
        }
        if let d = UserDefaults.standard.data(forKey: sessionsKey),
           let arr = try? JSONDecoder().decode([ReliefSession].self, from: d) {
            reliefSessions = arr
        }
    }
    private func save() {
        if let d = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(d, forKey: key)
        }
    }
    private func saveSessions() {
        if let d = try? JSONEncoder().encode(reliefSessions) {
            UserDefaults.standard.set(d, forKey: sessionsKey)
        }
    }
}

struct JournalView: View {
    var goHome: () -> Void
    var goStats: () -> Void
    @EnvironmentObject private var store: JournalStore
    @State private var mood: String = "Okay"
    @State private var text: String = ""
    @FocusState private var editing: Bool

    private static let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMM d · h:mm a"; return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text("Journal").font(.baloo(24, .heavy)).foregroundColor(.ink)
                Spacer()
                Button(action: goStats) {
                    HStack(spacing: 5) {
                        Image(systemName: "chart.bar.fill").font(.system(size: 13, weight: .bold))
                        Text("Your week").font(.baloo(13, .bold))
                    }
                    .foregroundColor(.redDeep)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.cream).clipShape(Capsule())
                    .shadow(color: .navy.opacity(0.12), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)

            // Composer
            VStack(alignment: .leading, spacing: 12) {
                Text("How are you feeling?").font(.baloo(18, .bold)).foregroundColor(.ink)
                HStack(spacing: 8) {
                    ForEach(MOODS) { m in
                        Button { mood = m.key } label: {
                            HStack(spacing: 5) {
                                Text(m.emoji)
                                Text(m.key).font(.text(13, .semibold))
                            }
                            .foregroundColor(mood == m.key ? .cream : .ink)
                            .padding(.horizontal, 12).padding(.vertical, 9)
                            .background(mood == m.key ? m.color : Color.roseSoft)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16).strokeBorder(Color.roseDeep, lineWidth: 2)
                        .background(Color.cream.clipShape(RoundedRectangle(cornerRadius: 16)))
                    if text.isEmpty {
                        Text("What's on your mind? Just for you.")
                            .font(.text(15)).foregroundColor(.muted)
                            .padding(.horizontal, 16).padding(.vertical, 18)
                    }
                    TextEditor(text: $text)
                        .font(.text(15)).foregroundColor(.ink)
                        .focused($editing)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .frame(minHeight: 110)

                Button {
                    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    store.add(mood: mood, text: t)
                    text = ""; editing = false
                } label: {
                    Text("Save entry").font(.baloo(17, .bold)).foregroundColor(.cream)
                        .frame(maxWidth: .infinity).padding(14)
                        .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.roseDeep : Color.navy)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .card()

            // History
            if store.entries.isEmpty {
                VStack(spacing: 8) {
                    PuppyView(size: 120)
                    Text("Your entries stay on this phone — private to you.")
                        .font(.text(13.5)).foregroundColor(.muted).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(.top, 12)
            } else {
                Text("PAST ENTRIES").font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)
                ForEach(store.entries) { e in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            HStack(spacing: 6) {
                                Text(moodEmoji(e.mood))
                                Text(e.mood).font(.baloo(14, .bold)).foregroundColor(moodColor(e.mood))
                            }
                            Spacer()
                            Text(Self.df.string(from: e.date)).font(.text(12)).foregroundColor(.muted)
                            Button { store.delete(e) } label: {
                                Image(systemName: "trash").font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.muted)
                            }
                            .buttonStyle(.plain)
                        }
                        Text(e.text).font(.text(14.5)).foregroundColor(.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.cream)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .navy.opacity(0.15), radius: 9, x: 0, y: 5)
                }
            }
        }
    }
}
