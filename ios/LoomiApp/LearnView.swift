//
//  LearnView.swift
//  Learning content (Understand / In-the-moment / Build resilience) and the Support screen.
//

import SwiftUI

struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

let understandItems: [Lesson] = [
    Lesson(title: "Stress is an alarm, not a flaw",
           body: "It's your body's built-in protection system. A threat (real or imagined) triggers adrenaline and cortisol to prep you to act. It's ancient, automatic, and not a sign anything's wrong with you."),
    Lesson(title: "Acute vs. chronic",
           body: "Short bursts of stress can sharpen focus and even help you perform. The problem is when the alarm never switches off — that constant 'on' is what wears the body and mind down."),
    Lesson(title: "Where you feel it",
           body: "Tight chest, shallow breath, clenched jaw, racing thoughts, a knotted stomach, a short fuse. These are physical, not 'just in your head' — which is why physical tools work."),
    Lesson(title: "What sets it off",
           body: "Uncertainty, feeling overloaded, having too little control, and never getting recovery time. Naming your trigger is the first step to loosening its grip."),
]

let techniqueItems: [Lesson] = [
    Lesson(title: "Breathe out longer",
           body: "A slow exhale (longer than the inhale) tells your nervous system the danger has passed. Try Loomi's button — in for 4, out for 6."),
    Lesson(title: "Ground with 5-4-3-2-1",
           body: "Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste. It pulls a spinning mind back to right now."),
    Lesson(title: "Cool down, literally",
           body: "Cold water on your face or wrists triggers a reflex that slows your heart rate. A surprisingly fast reset."),
    Lesson(title: "Move it out",
           body: "Stress is adrenaline with nowhere to go. A brisk walk, shaking out your hands, or stretching burns it off."),
    Lesson(title: "Drop your shoulders",
           body: "Do a quick body scan — unclench your jaw, lower your shoulders, soften your hands. We hold stress as tension we don't notice."),
    Lesson(title: "Brain-dump the list",
           body: "Get every looming task out of your head and onto paper. You can't hold it all at once, and you were never meant to."),
]

let resilienceItems: [Lesson] = [
    Lesson(title: "Protect your sleep",
           body: "Sleep is the foundation everything else sits on. Even one bad night raises baseline stress; a steady schedule lowers it."),
    Lesson(title: "Move most days",
           body: "Regular movement is one of the most reliable stress reducers there is — it doesn't have to be intense to count."),
    Lesson(title: "Watch caffeine & alcohol",
           body: "Both can amplify anxiety and wreck sleep. You don't have to quit — just notice how they land for you."),
    Lesson(title: "Stay connected",
           body: "Talking to someone you trust genuinely lowers stress hormones. Isolation makes everything feel heavier than it is."),
    Lesson(title: "Practice the small no",
           body: "Overload often comes from over-committing. Boundaries aren't selfish — they're how you stay able to show up at all."),
    Lesson(title: "Build in recovery",
           body: "Tiny breaks through the day beat one big collapse later. Step outside, breathe, look away from the screen."),
    Lesson(title: "Be kind to yourself",
           body: "Talk to yourself like you'd talk to a friend having a hard day. Self-criticism is just more stress on the pile."),
    Lesson(title: "Get backup if it's constant",
           body: "If stress is steady and affecting your life, a doctor or therapist can help. CBT is especially well-proven for this — see Support."),
]

// MARK: - Lessons list

struct LessonsView: View {
    let title: String
    let eyebrow: String
    let items: [Lesson]
    var goHome: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text(title).font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .padding(.vertical, 4)

            Text(eyebrow.uppercased())
                .font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)

            ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(String(format: "%02d", idx + 1)).font(.baloo(17, .bold)).foregroundColor(.brandRed)
                        Text(item.title).font(.baloo(17, .bold)).foregroundColor(.ink)
                    }
                    Text(item.body).font(.text(14.5)).foregroundColor(.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
            }

            PuppyView(size: 110).frame(maxWidth: .infinity).padding(.top, 4)
        }
    }
}

// MARK: - Support

struct SupportView: View {
    var goHome: () -> Void
    @AppStorage("loomi.ec.name")  private var ecName = ""
    @AppStorage("loomi.ec.phone") private var ecPhone = ""
    @State private var editingContact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                BackButton(action: goHome)
                Text("Support").font(.baloo(24, .heavy)).foregroundColor(.ink)
            }
            .padding(.vertical, 4)

            Text("Loomi is a self-help companion for everyday stress — not a doctor or therapist, and not a substitute for professional care. If stress is steady, heavy, or getting in the way of your life, please reach out to a real person who can help.")
                .font(.text(14)).foregroundColor(.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .card()

            emergencyContact

            Text("IF YOU NEED SOMEONE NOW (US)")
                .font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)

            resCard("988 Suicide & Crisis Lifeline",
                    "Free, 24/7, for any kind of emotional crisis or distress. Call or text 988.",
                    url: "tel:988")
            resCard("Crisis Text Line",
                    "Text HOME to 741741 to message a trained counselor, any time.",
                    url: "sms:741741")
            resCard("In immediate danger",
                    "If you or someone else is at risk right now, call your local emergency number (911 in the US).",
                    url: nil)
            resCard("Talk to a professional",
                    "A doctor or therapist can help you build a longer-term plan. CBT is especially effective for stress and anxiety.",
                    url: nil)

            Text("Outside the US? Search \"crisis line\" plus your country — most regions have a free helpline.")
                .font(.text(12.5)).foregroundColor(.muted)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 4)

            PuppyView(size: 110).frame(maxWidth: .infinity).padding(.top, 8)
        }
    }

    @ViewBuilder private var emergencyContact: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR PERSON").font(.text(11, .bold)).tracking(2.5).foregroundColor(.tanDark)
            if !ecName.isEmpty && !ecPhone.isEmpty && !editingContact {
                HStack(spacing: 12) {
                    ZStack { Circle().fill(Color.brandRed.opacity(0.15)).frame(width: 46, height: 46)
                             Image(systemName: "phone.fill").foregroundColor(.redDeep) }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(ecName).font(.baloo(16, .bold)).foregroundColor(.ink)
                        Text("Tap to call when you need a friendly voice").font(.text(12.5)).foregroundColor(.muted)
                    }
                    Spacer()
                    Button { editingContact = true } label: {
                        Image(systemName: "pencil").foregroundColor(.muted)
                    }.buttonStyle(.plain)
                }
                if let u = telURL(ecPhone) {
                    Link(destination: u) {
                        Text("Call \(ecName)").font(.baloo(17, .bold)).foregroundColor(.cream)
                            .frame(maxWidth: .infinity).padding(14)
                            .background(Color.brandRed)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            } else {
                Text("Save someone you trust for one-tap calling in a hard moment. Stays on this phone.")
                    .font(.text(13.5)).foregroundColor(.muted).fixedSize(horizontal: false, vertical: true)
                ecField($ecName, "Name (e.g. Mom)")
                ecField($ecPhone, "Phone number", keyboard: .phonePad)
                Button {
                    editingContact = false
                } label: {
                    Text("Save").font(.baloo(16, .bold)).foregroundColor(.cream)
                        .frame(maxWidth: .infinity).padding(12)
                        .background((ecName.isEmpty || ecPhone.isEmpty) ? Color.roseDeep : Color.navy)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(ecName.isEmpty || ecPhone.isEmpty)
            }
        }
        .card()
    }

    private func telURL(_ phone: String) -> URL? {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        return URL(string: "tel:\(digits)")
    }

    private func ecField(_ text: Binding<String>, _ placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .font(.text(15)).foregroundColor(.ink)
            .keyboardType(keyboard)
            .padding(12)
            .background(Color.roseSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func resCard(_ title: String, _ desc: String, url: String?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.baloo(15.5, .bold)).foregroundColor(.ink)
            Text(desc).font(.text(13.5)).foregroundColor(.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let url, let u = URL(string: url) {
                Link("Open", destination: u)
                    .font(.baloo(13, .bold)).foregroundColor(.redDeep).padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .navy.opacity(0.18), radius: 10, x: 0, y: 5)
    }
}
