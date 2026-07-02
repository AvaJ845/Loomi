//
//  ReliefView.swift
//  The "I'm feeling stressed" flow: intro → breathing → grounding → reframe → done.
//

import SwiftUI

struct ReliefView: View {
    var goHome: () -> Void
    @EnvironmentObject private var journal: JournalStore
    enum Step { case intro, breathe, ground, reframe, done }
    @State private var step: Step = .intro

    var body: some View {
        VStack(spacing: 8) {
            switch step {
            case .intro:   intro
            case .breathe: BreathingView(onDone: { step = .ground }, onBack: { step = .intro })
            case .ground:  GroundingView(onDone: { step = .reframe }, onBack: { step = .breathe })
            case .reframe: ReframeView(onDone: { step = .done })
            case .done:    done
            }
        }
        .padding(.top, 8)
    }

    private var intro: some View {
        VStack(spacing: 10) {
            PuppyView(size: 170).floating()
            Text("Hey, I'm right here.").font(.baloo(20)).multilineTextAlignment(.center)
            Text("You're safe. Whatever's stressing you, we don't have to fix it all at once. Let's just steady your body first.")
                .font(.text(14.5)).foregroundColor(.muted)
                .multilineTextAlignment(.center).frame(maxWidth: 320)
            ChoiceButton("Walk me through it") { step = .breathe }
            ChoiceButton("I just need to breathe", kind: .alt) { step = .breathe }
            Button("Not now") { goHome() }
                .font(.baloo(14)).foregroundColor(.muted).padding(.top, 4)
                .buttonStyle(.plain)
        }
    }

    private var done: some View {
        VStack(spacing: 10) {
            PuppyView(size: 170, happy: true).bouncing()
            Text("You did that. I'm proud of you.").font(.baloo(20)).multilineTextAlignment(.center)
            Text("You showed up for yourself in a hard moment — that's the whole skill. How are you feeling?")
                .font(.text(14.5)).foregroundColor(.muted)
                .multilineTextAlignment(.center).frame(maxWidth: 320)
            ChoiceButton("Calmer — thanks, Loomi") { journal.logReliefOutcome(.calmer); goHome() }
            ChoiceButton("A bit better") { journal.logReliefOutcome(.better); goHome() }
            ChoiceButton("Still rough — let's breathe again", kind: .alt) { journal.logReliefOutcome(.stillRough); step = .breathe }
        }
    }
}

// MARK: - Breathing

private struct BreathPhase { let label: String; let secs: Int; let scale: CGFloat }

private let breathPhases = [
    BreathPhase(label: "Breathe in",  secs: 4, scale: 1.0),
    BreathPhase(label: "Hold",        secs: 4, scale: 1.0),
    BreathPhase(label: "Breathe out", secs: 6, scale: 0.5),
    BreathPhase(label: "Rest",        secs: 2, scale: 0.5),
]

struct BreathingView: View {
    var onDone: () -> Void
    var onBack: () -> Void

    @State private var pi = 0
    @State private var secs = breathPhases[0].secs
    @State private var cycles = 0
    @State private var scale: CGFloat = 0.5
    @State private var started = false
    @State private var sessionStart = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().stroke(Color.brandRed.opacity(0.55), lineWidth: 4)
                    .frame(width: 170, height: 170).scaleEffect(scale)
                Circle()
                    .fill(RadialGradient(colors: [.roseSoft, .roseDeep],
                                         center: UnitPoint(x: 0.38, y: 0.32),
                                         startRadius: 5, endRadius: 120))
                    .frame(width: 170, height: 170).scaleEffect(scale)
                VStack(spacing: 2) {
                    Text(breathPhases[pi].label).font(.baloo(19))
                    Text("\(secs)").font(.baloo(30, .heavy))
                }
                .foregroundColor(.navyDeep)
            }
            .frame(width: 240, height: 240)

            Text("\(cycles) \(cycles == 1 ? "breath" : "breaths") together · Loomi's breathing with you")
                .font(.text(14)).foregroundColor(.muted)
                .multilineTextAlignment(.center)

            PuppyView(size: 120).padding(.top, 8)

            ChoiceButton("I'm feeling steadier →", kind: .alt) {
                HealthKitManager.shared.logMindfulSession(start: sessionStart, end: Date())
                onDone()
            }.padding(.top, 8)
            Button("← Back") { onBack() }
                .font(.baloo(14)).foregroundColor(.muted).buttonStyle(.plain)
        }
        .onAppear {
            guard !started else { return }
            started = true
            sessionStart = Date()
            withAnimation(.easeInOut(duration: Double(breathPhases[0].secs))) { scale = breathPhases[0].scale }
        }
        .onReceive(timer) { _ in tick() }
    }

    private func tick() {
        if secs > 1 { secs -= 1; return }
        let next = (pi + 1) % breathPhases.count
        if next == 0 { cycles += 1 }
        pi = next
        secs = breathPhases[next].secs
        let phase = breathPhases[next]
        if phase.label == "Breathe in" || phase.label == "Breathe out" {
            withAnimation(.easeInOut(duration: Double(phase.secs))) { scale = phase.scale }
        }
    }
}

// MARK: - Grounding (5-4-3-2-1)

private struct Sense { let n: Int; let sense: String; let tip: String }

private let senses = [
    Sense(n: 5, sense: "things you can see",   tip: "Look around and name them — a mug, the light, your hands."),
    Sense(n: 4, sense: "things you can feel",  tip: "The floor under you, your shirt, the air, something nearby to touch."),
    Sense(n: 3, sense: "things you can hear",  tip: "Traffic, a fan, your own breath. Let the sounds in."),
    Sense(n: 2, sense: "things you can smell", tip: "Coffee, soap, fresh air — or just notice the absence."),
    Sense(n: 1, sense: "thing you can taste",  tip: "A sip of water, gum, or the taste already in your mouth."),
]

struct GroundingView: View {
    var onDone: () -> Void
    var onBack: () -> Void
    @State private var i = 0

    var body: some View {
        let s = senses[i]
        let last = i == senses.count - 1
        return VStack(spacing: 8) {
            Text("GROUNDING · 5-4-3-2-1")
                .font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark).padding(.top, 6)
            Text("\(s.n)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundColor(.brandRed)
            Text(s.sense).font(.baloo(20)).multilineTextAlignment(.center)
            Text(s.tip).font(.text(14.5)).foregroundColor(.muted)
                .multilineTextAlignment(.center).frame(maxWidth: 320)
            HStack(spacing: 7) {
                ForEach(0..<senses.count, id: \.self) { k in
                    Circle().fill(k <= i ? Color.brandRed : Color.roseDeep).frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 6)
            ChoiceButton(last ? "Done — that's grounding" : "Next", kind: .alt) {
                if last { onDone() } else { i += 1 }
            }
            Button("← Back") { onBack() }
                .font(.baloo(14)).foregroundColor(.muted).buttonStyle(.plain)
        }
    }
}

// MARK: - Reframe

struct ReframeView: View {
    var onDone: () -> Void
    @State private var step = 0
    @State private var what = ""
    @State private var control: String? = nil
    @State private var third = ""

    var body: some View {
        VStack(spacing: 10) {
            if step == 0 {
                Text("What's weighing on you right now?").font(.baloo(20)).multilineTextAlignment(.center)
                Text("Just naming it takes some of its power away. No one else sees this.")
                    .font(.text(14.5)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 320)
                field($what, "Type whatever's on your mind…")
                ChoiceButton("Next →", kind: .alt) { step = 1 }
            } else if step == 1 {
                Text("Is this something you can act on right now?").font(.baloo(20)).multilineTextAlignment(.center)
                Text("Stress eases when we sort what's ours to carry from what isn't — yet.")
                    .font(.text(14.5)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 320)
                HStack(spacing: 10) {
                    ChoiceButton("Yes, partly") { control = "yes"; step = 2 }
                    ChoiceButton("Not right now") { control = "no"; step = 2 }
                }
            } else {
                Text(control == "yes" ? "What's the smallest next step?" : "What could you set down for now?")
                    .font(.baloo(20)).multilineTextAlignment(.center)
                Text(control == "yes"
                     ? "Not the whole thing — just the very next move. Small counts."
                     : "If you can't act yet, you're allowed to put it down until you can. That's not giving up.")
                    .font(.text(14.5)).foregroundColor(.muted).multilineTextAlignment(.center).frame(maxWidth: 320)
                field($third, "One small thing…")
                ChoiceButton("I'm ready →", kind: .alt) { onDone() }
            }
        }
    }

    private func field(_ text: Binding<String>, _ placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.roseDeep, lineWidth: 2)
                .background(Color.cream.clipShape(RoundedRectangle(cornerRadius: 16)))
            if text.wrappedValue.isEmpty {
                Text(placeholder).font(.text(15)).foregroundColor(.muted)
                    .padding(.horizontal, 16).padding(.vertical, 18)
            }
            TextEditor(text: text)
                .font(.text(15)).foregroundColor(.ink)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .frame(minHeight: 96)
    }
}
