# Loomi

A stress-relief app (**Loomi**) with a native iOS build, a web prototype, and
product roadmap documentation. This repo contains the calm companion app and
supporting materials.

```
BrunoProject/
├── ios/                     ← the real iOS app (SwiftUI, iOS 16+)
│   ├── LoomiApp/            ← app target sources
│   │   └── *.swift
│   ├── LoomiWidget/         ← Home/Lock-Screen widget (separate target)
│   │   └── *.swift
│   └── README.md            ← Xcode setup (targets, capabilities, deep links)
├── web/
│   └── Loomi.jsx            ← the original React prototype of Loomi
└── docs/
    └── Loomi-Roadmap.md     ← positioning, feature-gap vs Rootd, what's next
```

## The pieces

**`ios/` — Loomi (the product).** A SwiftUI app: a one-tap stress-relief flow
(breathe → ground → reframe), standalone Breathe, an on-device Journal with a
weekly Stats view, learning sections, Support with an emergency contact, a Home
Screen widget + Action-button shortcut (`loomi://relief`), and Apple Health
mindful minutes. No game is bundled in the app — it's a focused calm-tools
product. Mascot and breathing orb are original art. Start in `ios/README.md`.

**`web/` — Loomi (prototype).** The earlier React/web version. Good for quick
demos in a browser; the iOS app is the canonical product.

## Quick start

- **Run the app:** open Xcode, make a new SwiftUI App + a Widget Extension, drop
  in the files from `ios/`, then follow `ios/README.md` for the setup steps
  (URL scheme, widget target, HealthKit capability — App Intents need nothing).
- **Web prototype:** drop `web/Loomi.jsx` into any React sandbox.

## Notes

- Loomi is a **self-help companion, not medical care**; the Support screen carries
  real crisis resources. Journal/Stats/contact stay **on-device** (no tracking) —
  a deliberate privacy stance, see `docs/Loomi-Roadmap.md`.
