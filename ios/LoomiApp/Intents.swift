//
//  Intents.swift
//  App Intents — surface "I'm stressed" and "Breathe" in the Shortcuts app,
//  Spotlight, and the iPhone Action button. They open the app and route via
//  the shared Router (same instance LoomiApp uses).
//

import AppIntents

@available(iOS 16.0, *)
struct OpenReliefIntent: AppIntent {
    static var title: LocalizedStringResource = "Loomi — I'm stressed"
    static var description = IntentDescription("Open Loomi straight to the stress-relief flow.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Router.shared.screen = .relief
        return .result()
    }
}

@available(iOS 16.0, *)
struct BreatheIntent: AppIntent {
    static var title: LocalizedStringResource = "Loomi — Breathe"
    static var description = IntentDescription("Open Loomi's breathing exercise.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Router.shared.screen = .breathe
        return .result()
    }
}

@available(iOS 16.0, *)
struct LoomiShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenReliefIntent(),
            phrases: ["I'm stressed in \(.applicationName)",
                      "Open \(.applicationName) relief"],
            shortTitle: "Stress relief",
            systemImageName: "heart.fill"
        )
        AppShortcut(
            intent: BreatheIntent(),
            phrases: ["Breathe with \(.applicationName)"],
            shortTitle: "Breathe",
            systemImageName: "wind"
        )
    }
}
