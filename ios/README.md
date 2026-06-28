# Loomi — iOS (SwiftUI)

A native SwiftUI port of the Loomi stress-relief app. Loomi is a pocket calm
companion: one big button you press when stress hits, and he walks you through
breathing, grounding, and unpacking what's on your mind — plus learning sections
and support resources.

## Files

| File | What's in it |
|------|--------------|
| `LoomiApp.swift` | App entry point (`@main`). |
| `Theme.swift` | Color palette (from the puppy artwork), fonts, background, card style, animation modifiers, shared buttons. |
| `PuppyView.swift` | Loomi the Doberman, drawn with SwiftUI `Canvas`. Blinks; has a `happy` variant. |
| `ContentView.swift` | Root shell (top bar + screen switching) and the Home screen. |
| `ReliefView.swift` | The stress-relief flow: intro → breathing orb → 5-4-3-2-1 grounding → reframe → done. |
| `LearnView.swift` | The three learning sections + the Support screen with crisis resources. |

## Run it

1. Open Xcode → **File ▸ New ▸ Project ▸ App** (Interface: SwiftUI, Language: Swift).
2. Delete the auto-generated `ContentView.swift` and the `…App.swift` file.
3. Drag all six `.swift` files above into the project (check *Copy items if needed*).
4. Set the deployment target to **iOS 16.0** or later.
5. Build & run (⌘R). The SwiftUI previews at the bottom of `PuppyView.swift`
   and `ContentView.swift` also work without launching the simulator.

## Notes

- **Fonts:** the app uses the system *rounded* design as a stand-in for Baloo 2,
  so there are no font files to bundle. To match the web version exactly, add the
  `Baloo 2` and `Nunito Sans` `.ttf` files to the project, register them in
  Info.plist (`Fonts provided by application`), and update the `baloo`/`text`
  helpers in `Theme.swift`.
- **Mascot:** Loomi is drawn in code (vector), so he scales crisply and animates.
  If you'd rather use the original PNG, drop it in `Assets.xcassets` and replace
  `PuppyView` with an `Image`.
- **Not a medical tool.** This is a self-help companion. The Support screen lists
  crisis resources (988 Suicide & Crisis Lifeline, Crisis Text Line). Keep those
  current for your release region.

---

## Update: Journal + standalone Breathe

Two Rootd-gap features added:

| File | What |
|------|------|
| `JournalView.swift` | *(new)* Private on-device journal — tag a mood, write a note, browse past entries. Stored in `UserDefaults` as JSON; no account, no network, no tracking. |
| `ContentView.swift` | *(updated)* Home grid is now 6 tiles including **Breathe** (jumps straight into the breathing exercise) and **Journal**. |

Just add `JournalView.swift` to the target — no setup, no permissions. See
`../docs/Loomi-Roadmap.md` for the full feature-gap plan and what to build next
(widget + Action button, stats, Health sync, emergency contact).

---

## Update: Roadmap build-out (deep links, widget, Shortcuts, Stats, contact, Health)

New/changed files:

| File | What |
|------|------|
| `Router.swift` | *(new)* Shared navigation + `loomi://` deep-link parsing. Holds the `Screen` enum. |
| `LoomiApp.swift` | *(updated)* Injects `Router` + `JournalStore`, handles `onOpenURL`. |
| `ContentView.swift` | *(updated)* Drives navigation from `Router`; adds the Stats route. |
| `JournalView.swift` | *(updated)* Uses the shared store; adds a "Your week" button. |
| `StatsView.swift` | *(new)* Weekly check-in stats from journal data (Swift Charts). |
| `Intents.swift` | *(new)* App Intents for Shortcuts / Action button. |
| `HealthKitManager.swift` | *(new)* Logs completed breathing as a Mindful Session. |
| `ReliefView.swift` | *(updated)* Logs a mindful minute when a breathing session ends. |
| `LearnView.swift` | *(updated)* Emergency contact (save + one-tap call) in Support. |
| `LoomiWidget/LoomiWidget.swift`, `LoomiWidgetBundle.swift` | *(new)* Home/Lock Screen widget → `loomi://relief`. |

### Required Xcode setup

**1. URL scheme (enables deep links + widget):**
Target ▸ Info ▸ *URL Types* ▸ add one with **URL Schemes = `loomi`**.

**2. App Intents (Shortcuts + Action button):** nothing to configure — adding
`Intents.swift` to the app target is enough. "Stress relief" / "Breathe" then
appear in Shortcuts and can be assigned to the Action button (Settings ▸ Action
Button ▸ Shortcut).

**3. Home Screen widget (new target):**
File ▸ New ▸ Target ▸ **Widget Extension** (name it `LoomiWidget`, *uncheck*
"Include Configuration Intent"). Delete its template file and add
`LoomiWidget/LoomiWidget.swift` + `LoomiWidgetBundle.swift` to that **widget
target** (not the app). The widget is self-contained, so no shared files or App
Group are needed (it only deep-links).

**4. HealthKit (mindful minutes — optional but nice):**
App target ▸ Signing & Capabilities ▸ **+ Capability ▸ HealthKit**. Then in Info
add **Privacy - Health Update Usage Description**
(`NSHealthUpdateUsageDescription`), e.g. "Loomi logs your breathing sessions as
mindful minutes in Apple Health." If you skip this, the app still builds and runs;
it just won't write to Health.

**5. Loomi+ paywall (StoreKit 2 — needed before "Try Loomi+" shows real prices):**
`PaywallView.swift` + `EntitlementStore.swift` fetch three In-App Purchase
products by ID: `loomi.plus.monthly`, `loomi.plus.annual`, `loomi.plus.lifetime`.
1. App Store Connect ▸ your app ▸ **In-App Purchases** ▸ create an
   auto-renewable subscription (monthly), an auto-renewable subscription
   (annual), and a non-consumable (lifetime) with those exact product IDs.
2. For local testing without App Store Connect: Xcode ▸ File ▸ New ▸ File ▸
   **StoreKit Configuration File**, add the same three products there, then
   select it under Product ▸ Scheme ▸ Edit Scheme ▸ Run ▸ Options ▸ StoreKit
   Configuration.
3. Until products are configured, `store.products` stays empty and the
   paywall just shows a spinner — the app still builds and runs fine.
- **Don't ship the paywall live until there's real content behind it**
  (full lesson library, visualizations, sleep sounds) — see the caveat in
  `../docs/Loomi-Roadmap.md`.

### Notes
- Stats and the emergency contact are **local-only** (UserDefaults) — consistent
  with the no-tracking privacy stance in `../docs/Loomi-Roadmap.md`.
- Next from the roadmap: visualizations/sleep audio and localization.
