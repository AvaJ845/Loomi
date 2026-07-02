//
//  Theme.swift
//  Colors, fonts, background, and shared view helpers.
//  Palette matches the Loomi brand board exactly (Blush Pink, Deep Navy,
//  Warm Tan, Bright Red, Gold, Soothing Teal, Soft Leaf Green, White).
//  Deep/Light/Dark variants are derived from those exact base hexes rather
//  than hand-picked, so the source-of-truth swatches stay in one place.
//

import SwiftUI

// MARK: - Colors

extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8)  & 0xFF) / 255.0,
                  blue:  Double(hex & 0xFF)         / 255.0,
                  opacity: 1.0)
    }

    /// Nudges brightness (HSB) up or down — used to derive Light/Deep/Dark
    /// variants from a single brand-board base color instead of hand-picking hexes.
    func adjusted(brightness delta: Double) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let newB = min(max(b + CGFloat(delta), 0), 1)
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(newB), opacity: Double(a))
    }

    // Brand-board base colors (exact hex from the board).
    static let navy      = Color(hex: 0x1D2E3D)
    static let tan        = Color(hex: 0xE5883C)
    static let brandRed   = Color(hex: 0xE12E2D)
    static let gold       = Color(hex: 0xE6C542)
    static let roseBg     = Color(hex: 0xF4C5C3)
    static let teal       = Color(hex: 0x46AFB7)
    static let leafGreen  = Color(hex: 0xA9D79F)

    // Derived variants.
    static let navyDeep  = navy.adjusted(brightness: -0.08)
    static let tanLight  = tan.adjusted(brightness: 0.12)
    static let tanDark   = tan.adjusted(brightness: -0.15)
    static let roseSoft  = roseBg.adjusted(brightness: 0.06)
    static let roseDeep  = roseBg.adjusted(brightness: -0.12)
    static let redDeep   = brandRed.adjusted(brightness: -0.12)
    static let goldDeep  = gold.adjusted(brightness: -0.13)
    static let tealDeep  = teal.adjusted(brightness: -0.12)

    // Kept as a deliberately warm off-white for card surfaces (rather than the
    // board's flat #FFFFFF) — see "Key decisions" in CLAUDE.md for the calming,
    // non-clinical framing this app aims for.
    static let cream    = Color(hex: 0xFBF4EF)
    static let ink      = navy
    static let muted    = Color(hex: 0x6E6258)
}

// MARK: - Fonts
// The board specifies Nunito Sans (headings) / Inter (body). Neither ships as
// a system font, so this uses the closest system stand-ins — system default
// (non-rounded) for both — rather than the previous Baloo-2-style rounded
// display font. For an exact match, bundle the Nunito Sans / Inter .ttf files
// and register them in Info.plist (UIAppFonts), then swap `.system` below for
// `.custom`.

extension Font {
    static func baloo(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func text(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Background

struct LoomiBackground: View {
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [.roseSoft, .roseBg, Color(hex: 0xEAC9C3)]),
                       center: UnitPoint(x: 0.5, y: -0.05),
                       startRadius: 0, endRadius: 540)
            .ignoresSafeArea()
    }
}

// MARK: - Card

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Color.cream)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.navy.opacity(0.18), radius: 14, x: 0, y: 10)
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}

// MARK: - Animation modifiers

struct FloatingModifier: ViewModifier {
    @State private var up = false
    func body(content: Content) -> some View {
        content
            .offset(y: up ? -9 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { up = true }
            }
    }
}

struct BouncingModifier: ViewModifier {
    @State private var b = false
    func body(content: Content) -> some View {
        content
            .offset(y: b ? -12 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { b = true }
            }
    }
}

extension View {
    func floating() -> some View { modifier(FloatingModifier()) }
    func bouncing() -> some View { modifier(BouncingModifier()) }
}

// MARK: - Shared buttons

struct ChoiceButton: View {
    enum Kind { case normal, alt }
    let title: String
    var kind: Kind = .normal
    let action: () -> Void

    init(_ title: String, kind: Kind = .normal, action: @escaping () -> Void) {
        self.title = title
        self.kind = kind
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.baloo(17, .bold))
                .foregroundColor(kind == .alt ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(kind == .alt ? Color.navy : Color.cream)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.navy.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

struct BackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("←")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.ink)
                .frame(width: 42, height: 42)
                .background(Color.cream)
                .clipShape(Circle())
                .shadow(color: Color.navy.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
