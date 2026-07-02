# Loomi — Claude Code context

## What this project is
- **Loomi**: a SwiftUI iOS stress-relief app (companion + calm tools), iOS 16+

## Project layout

```
BrunoProject/
├── CLAUDE.md                         ← you are here
├── ios/
│   ├── LoomiApp/                     ← app target (drag all *.swift into Xcode)
│   │   ├── LoomiApp.swift            ← @main entry, injects Router + JournalStore
│   │   ├── Router.swift              ← shared nav state + loomi:// deep-link parsing
│   │   ├── Theme.swift               ← colors, fonts, shared view modifiers
│   │   ├── ContentView.swift         ← root shell + HomeView + BreatheScreen
│   │   ├── PuppyView.swift           ← Loomi SVG mascot (Canvas, blinks, happy variant)
│   │   ├── ReliefView.swift          ← stress-relief flow: intro→breathe→ground→reframe→done
│   │   ├── LearnView.swift           ← Understand / In-the-moment / Resilience lessons + SupportView
│   │   ├── JournalView.swift         ← private on-device mood journal (UserDefaults JSON)
│   │   ├── StatsView.swift           ← weekly stats (Swift Charts) from journal data
│   │   ├── HealthKitManager.swift    ← logs completed breathing as HKMindfulSession
│   │   ├── Intents.swift             ← AppIntents for Shortcuts + Action button
│   │   ├── EntitlementStore.swift    ← StoreKit 2 purchases/entitlement for Loomi+
│   │   ├── PaywallView.swift         ← Loomi+ upsell, leads with lifetime plan
│   │   ├── NotificationManager.swift ← opt-in daily reminder (no dark patterns)
│   │   └── SettingsView.swift        ← reminder toggle/time + Loomi+ link
│   ├── LoomiWidget/                  ← Widget Extension target (separate in Xcode)
│   │   ├── LoomiWidget.swift         ← small/medium home screen widget → loomi://relief
│   │   └── LoomiWidgetBundle.swift   ← @main for widget target
│   └── README.md                     ← Xcode project setup
├── web/
│   └── Loomi.jsx                     ← React prototype (reference; iOS is canonical)
└── docs/
    └── Loomi-Roadmap.md              ← feature gap vs Rootd, free/paid tiers, build order
```

## Architecture notes

### Navigation (iOS)
All screen routing flows through `Router` (a singleton `ObservableObject`).
`LoomiApp` injects it + `JournalStore` as `@EnvironmentObject`. Deep links
(`loomi://relief`, `loomi://breathe`, `loomi://journal`) call
`Router.shared.open(url)`. The widget taps `loomi://relief`.

### Screens (`Screen` enum in `Router.swift`)
`home | relief | breathe | journal | stats | understand | techniques | resilience | support`

### Data
- **Journal**: `JournalStore` (ObservableObject) stores `[JournalEntry]` as JSON
  in `UserDefaults` key `loomi.journal.entries.v1`. No network. No tracking.
- **Emergency contact**: `@AppStorage("loomi.ec.name")` + `("loomi.ec.phone")`.
- **High score**: in-memory in the JS game only.


## Xcode setup (required before building)

See `ios/README.md` for step-by-step. Summary:
1. New project → App (SwiftUI, Swift) + a second target → Widget Extension named `LoomiWidget`.
2. Add all `ios/LoomiApp/*.swift` to the **app target**.
3. Add `ios/LoomiWidget/*.swift` to the **widget target only**.
4. Info ▸ URL Types ▸ add scheme `loomi`.
5. Signing & Capabilities ▸ add **HealthKit** (optional but recommended).
6. Info.plist: add `NSHealthUpdateUsageDescription`.

## Testing without Xcode

SwiftUI itself only compiles/runs on macOS, so there's no way to build or run
`ios/LoomiApp` without a Mac + Xcode. For a quick way to click through the
app's flow, copy, and palette without that (e.g. on Windows, or for a fast
design review), `web/Loomi.jsx` is a matching React prototype:

```
cd web
npm install
npm run dev      # opens a Vite dev server; visit the printed localhost URL
```

It shares Loomi's palette/typography and mirrors the core screens (home,
breathe, journal, stats, support), but it is a reference stand-in, not a 1:1
port — business logic (StoreKit, HealthKit, notifications) lives only in the
Swift app. Treat it as a UX/copy preview, not a substitute for on-device
testing before release.

## Common tasks for Claude Code

- **Add a new screen**: add a case to `Screen` enum in `Router.swift`, add a
  `@ViewBuilder` case in `ContentView`, create the view file.
- **Change the breathing pattern**: edit `breathPhases` array in `ReliefView.swift`.
- **Add a new lesson section**: add an `[Lesson]` array in `LearnView.swift` and
  a nav tile in `HomeView`.
- **Edit game mechanics**: edit `game/Dobbie.html` directly and test in browser —
  it's no longer copied into the iOS app.
- **Add audio to the game**: drop `.mp3` files next to `Dobbie.html`; replace
  `function playSfx(){ }` with a lookup + `new Audio(clips[name]).play()`.
- **Style changes**: all iOS colors in `Theme.swift` (`Color` extension at top).
  Game palette in the `const C = {...}` and `COLS` blocks in `Dobbie.html`.
- **Widget changes**: edit `ios/LoomiWidget/LoomiWidget.swift` — it's self-contained
  (own color vars, no imports from the app target).

## Roadmap (next items)
See `docs/Loomi-Roadmap.md`. Top of the queue:
1. **Distribution experiment** (pre-launch, zero users — the actual bottleneck;
   pick one cheap test before sinking more time into content)
2. Sleep / ambient sound screen
3. Visualization / body scan screen
4. HealthKit streak reading (show "X mindful days" in Stats)
5. Localization (Localizable.strings pass)
6. App Store assets (screenshots, preview video, privacy label)
7. Re-test the Loomi+ paywall tiers now that Dobbie is no longer part of the
   app at all (see Free vs Paid note in the roadmap doc)

## Key decisions (don't change without reason)
- **No tracking, no ads, no accounts** — privacy is a positioning advantage.
- **Crisis resources always free** — Support screen and the "Need support?" pill
  are never behind a paywall.
- **In-the-moment relief always free** — the big red button and breathing stay free.
- **Dobbie was removed from the iOS app.** It previously lived in the app as a
  "take a break" distraction; that conflated a stress-relief tool with an
  arcade dopamine loop, which undercut both. `GameView.swift` and the bundled
  `dobbie.html` were deleted, and `Router`'s `showGame` state and `loomi://game`
  deep link were removed. Dobbie continues to exist only as the standalone
  `game/Dobbie.html` — don't re-embed it in the app without revisiting that
  decision deliberately.
- **Game (Dobbie) uses Canvas not WebGL** — keeps it one file, no build chain.
- **Sprites baked at startup** — not drawn each frame — keeps the game 60fps on
  older iPhones.
- **No dark-pattern engagement mechanics.** Retention features (the daily
  reminder in `SettingsView.swift`/`NotificationManager.swift`) are
  deliberately opt-in, off by default, fixed-time (not algorithmically timed
  for "optimal" compulsion), and have no badge counts or urgency framing.
  Variable reward schedules, infinite scroll, and engagement-maximizing
  personalization were explicitly considered and rejected — they conflict
  with Loomi's purpose (calming a stressed user, not generating compulsive
  use) and with the privacy/honesty stance above.
