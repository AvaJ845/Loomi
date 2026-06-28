//
//  LoomiWidget.swift
//  A Home Screen / Lock Screen widget: one tap goes straight into Loomi's
//  stress-relief flow via the loomi://relief deep link. Self-contained — it
//  doesn't depend on the app's Theme files, so it can live in its own target.
//
//  This file belongs to a **Widget Extension** target (see README).
//

import WidgetKit
import SwiftUI

// Palette (kept local to the widget target)
private extension Color {
    static let wRose  = Color(red: 0.94, green: 0.84, blue: 0.80)
    static let wRed   = Color(red: 0.80, green: 0.22, blue: 0.18)
    static let wNavy  = Color(red: 0.18, green: 0.24, blue: 0.29)
    static let wCream = Color(red: 0.98, green: 0.96, blue: 0.94)
    static let wGold  = Color(red: 0.89, green: 0.67, blue: 0.22)
}

struct LoomiEntry: TimelineEntry { let date: Date }

struct LoomiProvider: TimelineProvider {
    func placeholder(in context: Context) -> LoomiEntry { LoomiEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (LoomiEntry) -> Void) {
        completion(LoomiEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LoomiEntry>) -> Void) {
        completion(Timeline(entries: [LoomiEntry(date: Date())], policy: .never))
    }
}

struct LoomiWidgetView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        let content = Group {
            switch family {
            case .systemMedium:
                HStack(spacing: 14) {
                    badge
                    VStack(alignment: .leading, spacing: 3) {
                        Text("I'm feeling stressed").font(.system(size: 19, weight: .heavy, design: .rounded))
                            .foregroundColor(.wCream)
                        Text("Tap — Loomi's got you").font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.wCream.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(16)
            default: // systemSmall / lock screen
                VStack(spacing: 8) {
                    badge
                    Text("I'm stressed").font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.wCream).multilineTextAlignment(.center)
                }
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "loomi://relief"))

        bg(content)
    }

    private var badge: some View {
        ZStack {
            Circle().fill(Color.wCream.opacity(0.18)).frame(width: 52, height: 52)
            Image(systemName: "pawprint.fill").font(.system(size: 24)).foregroundColor(.wCream)
        }
    }

    @ViewBuilder private func bg<V: View>(_ v: V) -> some View {
        if #available(iOS 17.0, *) {
            v.containerBackground(for: .widget) { Color.wRed }
        } else {
            v.background(Color.wRed)
        }
    }
}

struct LoomiWidget: Widget {
    let kind = "LoomiWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LoomiProvider()) { _ in
            LoomiWidgetView()
        }
        .configurationDisplayName("Loomi")
        .description("One tap to stress relief.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
