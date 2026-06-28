//
//  Theme.swift
//  Colors, fonts, background, and shared view helpers.
//  Palette is pulled straight from the uploaded Doberman artwork:
//  navy body, caramel tan points, dusty rose, red collar, gold tag.
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

    static let navy     = Color(hex: 0x2E3D49)
    static let navyDeep = Color(hex: 0x243039)
    static let tan      = Color(hex: 0xC2854A)
    static let tanLight = Color(hex: 0xD7A267)
    static let tanDark  = Color(hex: 0xA56E3A)
    static let roseBg   = Color(hex: 0xF0D7D2)
    static let roseSoft = Color(hex: 0xF7E7E3)
    static let roseDeep = Color(hex: 0xD8ADA6)
    static let brandRed = Color(hex: 0xCC392D)
    static let redDeep  = Color(hex: 0xB02E23)
    static let gold     = Color(hex: 0xE2AC39)
    static let goldDeep = Color(hex: 0xC9912A)
    static let cream    = Color(hex: 0xFBF4EF)
    static let ink      = Color(hex: 0x2E3D49)
    static let muted    = Color(hex: 0x6E6258)
}

// MARK: - Fonts
// System "rounded" stands in for Baloo 2 (display) and system default for body.
// Swap these for bundled fonts if you want an exact match to the web version.

extension Font {
    static func baloo(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
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
