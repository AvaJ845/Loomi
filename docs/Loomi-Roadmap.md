# Loomi — product roadmap

## Build freeze (2026-06-28 — repo-state council review)

The repo had accumulated several rounds of strategy churn (pricing model
changed, a paywall promo banner added then removed, a full game built then
deleted) with zero TestFlight builds and no committed, buildable Xcode
project — i.e. decisions were being revisited based on AI-roleplay critique
of a product no real person had touched yet. **Freeze:** no further
pricing/paywall/feature-direction changes until a TestFlight build exists and
at least one person outside the dev has used it. Bug fixes and the scaffolding
below are exempt from the freeze.

**What's actually needed to produce that first TestFlight build** (all of
this requires a Mac + Xcode + an Apple Developer Program account — none of
which exist in this environment, so it's a checklist for whoever has access,
not something an agent can complete remotely):

1. `cd ios && xcodegen generate` (see `ios/README.md`) → open `Loomi.xcodeproj`,
   confirm it builds and runs in the simulator.
2. Add a real 1024×1024 app icon to `Assets.xcassets/AppIcon.appiconset`
   (placeholder structure exists, no image yet).
3. Set a signing team (Apple Developer Program membership required) and a
   real bundle ID if `com.loomi.app` isn't yours to use.
4. Create the three IAP products in App Store Connect with the exact IDs
   `loomi.plus.monthly` / `loomi.plus.annual` / `loomi.plus.lifetime`
   (`ios/Loomi.storekit` already lets you test the flow locally without this
   step, but real purchases need it).
5. Product ▸ Archive ▸ Distribute App ▸ TestFlight, invite a small group of
   real testers (the shift-worker niche in `Distribution-Draft.md` is the
   suggested first audience).
6. Only after step 5 produces actual feedback: resume iterating on
   pricing/paywall/feature direction, now grounded in real usage instead of
   another roleplay round.

A stress-first, privacy-respecting, mascot-led companion — a focused calm-tools
app, no game bundled inside it. Rootd (4.8★, ~10K ratings, Apple Editors' Choice)
is useful market context, not the strategy: a new, zero-review solo app can't
out-incumbent an Editors' Choice pick on its own turf, so the plan below leans
on doing the calm-tools job well and cleanly rather than matching its feature
list point-for-point.

## Positioning (own a wedge Rootd doesn't have, don't just match it)

- **Dobbie is not part of Loomi.** The game was removed from the iOS app (see
  Key decisions in `CLAUDE.md`) — pairing a calming tool with an arcade
  dopamine loop in the same product undercut both. Dobbie lives on only as the
  standalone `game/Dobbie.html`, a separate thing entirely.
- **A focused mascot, not a feature checklist.** Loomi the character (calm,
  reacts, has your back) is still the differentiator from Rootd's generic
  "Ron" — the wedge is the character and the craft of the calm-tools flow
  itself, not a bundled game.
- **Stress-first, not panic-first.** Stress is a bigger everyday audience than
  panic attacks specifically — own it in copy, ASO keywords, and screenshots,
  independent of how Rootd positions itself.
- **Privacy as a feature, stated plainly.** Data stays **on-device, no
  tracking** (the journal already does). True regardless of what any
  competitor does — say so because it's real, not as a Rootd dig.
- **Honest framing.** Don't claim "clinically validated / therapist-approved"
  unless/until it's true. "Self-help companion" + real crisis resources is the
  trustworthy lane.

## Feature gap vs Rootd

| Feature | Rootd | Loomi | Notes |
|---|---|---|---|
| In-the-moment relief button | ✅ Rootr | ✅ "I'm feeling stressed" flow | parity |
| Guided breathing | ✅ | ✅ (+ standalone Breathe now) | parity |
| Lessons (short/long term) | ✅ | ✅ Understand / In-the-moment / Resilience | parity |
| Grounding (5-4-3-2-1) | ➖ | ✅ | Loomi extra |
| Mascot | ✅ Ron | ✅ Loomi | Loomi advantage |
| **Journal** | ✅ | ✅ **(built now, on-device)** | parity + privacy edge |
| Mood tagging / check-in | ✅ weekly questionnaire | ✅ journal moods + StatsView | parity |
| Personal stats / streaks | ✅ | ✅ **(built — `StatsView.swift`)** | parity |
| Home Screen widget | ✅ panic widget | ⏳ | high-value quick win |
| Action-button / lock-screen shortcut | ✅ (iOS 18) | ⏳ | App Intent, small effort |
| Apple Health sync | ✅ (mindful minutes) | ⏳ | HealthKit write on breathe |
| Emergency contact (call a person) | ✅ | ⏳ | trivial: tel: link + picker |
| Visualizations / body scan | ✅ | ⏳ | content + audio |
| Sleep sounds / stories | ✅ | ⏳ | content + audio, heavier |
| Localization (12 langs) | ✅ | ⏳ | later; English-first |

## Free vs. Paid (suggested)

Keep **in-the-moment relief free forever** (it's the ethical core and the install hook).

**Free**
- The stress-relief flow, standalone Breathe, grounding, Journal, Support,
  the core lessons.

**Loomi+ (subscription)**
- On-device Insights — local pattern recognition over journal + relief-session
  history (e.g. toughest day of the week, how often breathing actually helped).
  Computed entirely on-device, nothing leaves the phone — the thing Calm/
  Headspace structurally can't credibly offer. **Built — `InsightsView.swift`.**
- Full check-in history + streaks (the free tier only shows the current week).
- Visualizations + sleep sounds — **not built yet, not sold yet** (see caveat
  below). Add to the paywall only once real content exists behind it.
- Custom Loomi (collar colors, names) — not built yet.
- Suggested pricing band (match category): ~$4.99/mo, ~$29.99/yr, ~$79.99 lifetime.
  Undercut Rootd's $6.99/mo slightly; lifetime converts well for this category.

> Never paywall crisis resources or the panic/stress button. Ever.

**Reshape (2026-06-28 council review): sell what's real, not a roadmap.**
The paywall used to promise a "full lesson library, visualizations, sleep
sounds" — none of which existed yet — while the only feature with a proven
mechanism (breathing/grounding) was already free. That's an inverted bet: it
risks refund requests and reviews calling out vaporware before a single
feature ships. Fix: `PaywallView.swift` copy now sells only what's built
(on-device Insights + full history). Visualizations/sleep sounds stay off the
paywall copy entirely until they exist.

**Paywall — ✅ built, leads with lifetime.** `PaywallView.swift` +
`EntitlementStore.swift` (StoreKit 2, on-device entitlement check, no server)
present all three plans but visually default to **lifetime** as the
recommended choice, not monthly — per the council's reshape verdict: a
handful of lifetime sales clears the $500/mo bar with zero churn risk, which
is the realistic path at zero installs/zero marketing budget. Monthly/yearly
still exist as options. Requires creating the three IAP products in App
Store Connect (see `ios/README.md`) before it can fetch real prices.

## Build order (highest value ÷ effort first)

1. **Journal** — ✅ done (on-device, private).
2. **Standalone Breathe tile** — ✅ done.
3. **Home Screen widget + Action-button shortcut.** A "Loomi, I'm stressed" widget
   that deep-links straight into the relief flow. Needs a *Widget Extension* target
   + an `App Intent` and a URL scheme (`loomi://relief`). Biggest perceived-value win.
4. **Distribution experiment.** Pre-launch with zero users, this is the actual
   bottleneck — not more content. Pick one cheap, fast test: a short demo clip
   for social, an ASO-optimized App Store listing leaning on the stress-first +
   privacy angle, or seeding in one niche community (e.g. nursing/shift-work
   forums). Run it before sinking more time into content depth.
5. **Stats from the journal.** You already capture mood + timestamp. Add a simple
   "this week" view (mood distribution, entries count, a gentle streak). No new data
   collection — pure local aggregation.
6. **Emergency contact.** Let the user pick a contact; one tap dials `tel:`. ~half a day.
7. **Apple Health (HealthKit).** Log a "mindful minute" when a breathing session
   completes. Adds legitimacy + a reason to open daily. Needs HealthKit entitlement.
8. **Visualizations / sleep audio.** Content-heavy; do after the structural wins.
9. **Localization.** English-first; revisit once retention is proven.

## Implementation notes for the next ones

- **Widget + shortcut:** add a Widget Extension target; share state via an App Group;
  register URL scheme `loomi`; handle `onOpenURL` in `LoomiApp` to set the screen to
  `.relief`. Add an `AppIntent` ("Open Loomi relief") so it shows in the Action button
  and Shortcuts.
- **Stats:** read `JournalStore.entries`, group by day/mood; render with the same
  card style. Swift Charts (iOS 16+) makes the mood chart trivial.
- **HealthKit:** request `.mindfulSession` write permission; on breathing completion,
  save an `HKCategorySample` for the session duration.

## ASO / store-listing quick wins

- Title/subtitle target "stress relief" + "calm" + "anxiety" keywords.
- First two screenshots: Loomi + the big button, then the breathing orb.
- Mention "private — your notes never leave your phone."
- A short preview video of a breathing session converts well in this category.
