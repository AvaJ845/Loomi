//
//  ContentView.swift
//  Root shell (top bar + screen switching), Home, and standalone Breathe.
//  Navigation is driven by the shared Router (so widgets / deep links /
//  Shortcuts can change the screen too).
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        ZStack {
            LoomiBackground()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    content
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .frame(maxWidth: 460)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch router.screen {
        case .home:        HomeView(go: { router.screen = $0 })
        case .relief:      ReliefView(goHome: { router.screen = .home })
        case .breathe:     BreatheScreen(goHome: { router.screen = .home })
        case .journal:     JournalView(goHome: { router.screen = .home }, goStats: { router.screen = .stats })
        case .stats:       StatsView(goBack: { router.screen = .journal }, goInsights: { router.screen = .insights })
        case .insights:    InsightsView(goHome: { router.screen = .stats })
        case .understand:  LessonsView(title: "Understand stress", eyebrow: "The basics", items: understandItems, goHome: { router.screen = .home })
        case .techniques:  LessonsView(title: "In-the-moment", eyebrow: "Fast relief", items: techniqueItems, goHome: { router.screen = .home })
        case .resilience:  LessonsView(title: "Build resilience", eyebrow: "Over time", items: resilienceItems, goHome: { router.screen = .home })
        case .support:     SupportView(goHome: { router.screen = .home })
        case .settings:    SettingsView(goHome: { router.screen = .home })
        }
    }

    private var topBar: some View {
        HStack {
            Button { router.screen = .home } label: {
                HStack(spacing: 9) {
                    ZStack {
                        Circle().fill(Color.brandRed).frame(width: 30, height: 30)
                            .shadow(color: .redDeep, radius: 0, x: 0, y: 3)
                        Circle().fill(Color.gold).frame(width: 11, height: 11)
                    }
                    Text("Loomi").font(.baloo(22, .heavy)).foregroundColor(.ink)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if router.screen != .support {
                Button { router.screen = .support } label: {
                    Text("Need support?")
                        .font(.baloo(13, .bold)).foregroundColor(.tealDeep)
                        .padding(.horizontal, 13).padding(.vertical, 7)
                        .background(Color.cream).clipShape(Capsule())
                        .shadow(color: .navy.opacity(0.12), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 6)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Home

struct HomeView: View {
    var go: (Screen) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Rough day? Tap below and we'll get through it together. 🐾")
                .font(.baloo(15, .semibold)).foregroundColor(.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.cream)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .navy.opacity(0.2), radius: 10, x: 0, y: 6)
                .frame(maxWidth: 300)

            PuppyView(size: 196).floating()

            Text("Hi, I'm Loomi.").font(.baloo(34, .heavy)).foregroundColor(.ink)

            Text("Your pocket guardian for stressful moments — here to help you breathe, ground, and feel steady again.")
                .font(.text(16)).foregroundColor(.muted)
                .multilineTextAlignment(.center).frame(maxWidth: 300)

            Button { go(.relief) } label: {
                VStack(spacing: 2) {
                    Text("I'm feeling stressed").font(.baloo(21, .bold))
                    Text("press anytime — I've got you").font(.text(13, .semibold)).opacity(0.9)
                }
                .foregroundColor(.cream)
                .frame(maxWidth: .infinity).padding(20)
                .background(Color.brandRed)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .redDeep, radius: 0, x: 0, y: 6)
                .shadow(color: Color.brandRed.opacity(0.5), radius: 16, x: 0, y: 12)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            navGrid
        }
        .padding(.top, 6)
    }

    private var navGrid: some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: cols, spacing: 12) {
            navCard("🫧", "Breathe", "A calm minute, anytime") { go(.breathe) }
            navCard("📓", "Journal", "Note how you're feeling") { go(.journal) }
            navCard("✨", "Insights", "Patterns from your check-ins") { go(.insights) }
            navCard("🧠", "Understand stress", "What it is & why it happens") { go(.understand) }
            navCard("🌿", "In-the-moment", "Quick ways to feel calmer") { go(.techniques) }
            navCard("🌱", "Build resilience", "Habits that lower stress") { go(.resilience) }
            navCard("💛", "Support", "Resources for when it's a lot") { go(.support) }
            navCard("⚙️", "Settings", "Reminder & app preferences") { go(.settings) }
        }
        .padding(.top, 6)
    }

    private func navCard(_ icon: String, _ title: String, _ desc: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(icon).font(.system(size: 22))
                Text(title).font(.baloo(16, .bold)).foregroundColor(.ink)
                Text(desc).font(.text(12.5)).foregroundColor(.muted)
                    .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.cream)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .navy.opacity(0.2), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Standalone Breathe

struct BreatheScreen: View {
    var goHome: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text("Breathe").font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)

            Text("A minute of slow breathing, anytime — no stress required.")
                .font(.text(14.5)).foregroundColor(.muted)
                .multilineTextAlignment(.center).frame(maxWidth: 320)

            BreathingView(onDone: goHome, onBack: goHome)
                .padding(.top, 6)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Router.shared)
        .environmentObject(JournalStore())
        .environmentObject(EntitlementStore.shared)
}
