//
//  PuppyView.swift
//  Loomi the Doberman puppy, drawn with SwiftUI Canvas in a 240x260 design space
//  and scaled to fit. Blinks on a timer-free schedule via TimelineView.
//

import SwiftUI

struct PuppyView: View {
    var size: CGFloat = 190
    var happy: Bool = false

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, canvasSize in
                let s = min(canvasSize.width / 240, canvasSize.height / 260)
                ctx.scaleBy(x: s, y: s)
                draw(&ctx, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
        .frame(width: size, height: size * 260 / 240)
        .accessibilityLabel("Loomi, a friendly Doberman puppy")
    }

    // helper: an ellipse centered at (cx,cy)
    private func ell(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
    }

    private func blinkAmount(_ t: TimeInterval) -> CGFloat {
        let cyc = t.truncatingRemainder(dividingBy: 4.5)   // blink ~every 4.5s
        guard cyc > 4.30 else { return 0 }
        let p = (cyc - 4.30) / 0.20                         // 0...1 across blink window
        return CGFloat(p < 0.5 ? p * 2 : (1 - p) * 2)       // close then open
    }

    private func draw(_ ctx: inout GraphicsContext, time: TimeInterval) {
        // ground shadow
        ctx.fill(ell(120, 246, 76, 12), with: .color(.roseDeep.opacity(0.5)))

        // ears
        var lEar = Path()
        lEar.move(to: CGPoint(x: 88, y: 66))
        lEar.addLine(to: CGPoint(x: 60, y: 10))
        lEar.addQuadCurve(to: CGPoint(x: 64, y: 7), control: CGPoint(x: 57, y: 4))
        lEar.addLine(to: CGPoint(x: 110, y: 54)); lEar.closeSubpath()
        ctx.fill(lEar, with: .color(.navy))

        var lEarIn = Path()
        lEarIn.move(to: CGPoint(x: 85, y: 60))
        lEarIn.addLine(to: CGPoint(x: 68, y: 24))
        lEarIn.addQuadCurve(to: CGPoint(x: 72, y: 22), control: CGPoint(x: 66, y: 19))
        lEarIn.addLine(to: CGPoint(x: 102, y: 54)); lEarIn.closeSubpath()
        ctx.fill(lEarIn, with: .color(.tan))

        var rEar = Path()
        rEar.move(to: CGPoint(x: 152, y: 66))
        rEar.addLine(to: CGPoint(x: 180, y: 10))
        rEar.addQuadCurve(to: CGPoint(x: 176, y: 7), control: CGPoint(x: 183, y: 4))
        rEar.addLine(to: CGPoint(x: 130, y: 54)); rEar.closeSubpath()
        ctx.fill(rEar, with: .color(.navy))

        var rEarIn = Path()
        rEarIn.move(to: CGPoint(x: 155, y: 60))
        rEarIn.addLine(to: CGPoint(x: 172, y: 24))
        rEarIn.addQuadCurve(to: CGPoint(x: 168, y: 22), control: CGPoint(x: 174, y: 19))
        rEarIn.addLine(to: CGPoint(x: 138, y: 54)); rEarIn.closeSubpath()
        ctx.fill(rEarIn, with: .color(.tan))

        // body
        var body = Path()
        body.move(to: CGPoint(x: 120, y: 150))
        body.addCurve(to: CGPoint(x: 72, y: 196),  control1: CGPoint(x: 92, y: 150),  control2: CGPoint(x: 78, y: 168))
        body.addCurve(to: CGPoint(x: 120, y: 238), control1: CGPoint(x: 68, y: 222),  control2: CGPoint(x: 88, y: 238))
        body.addCurve(to: CGPoint(x: 168, y: 196), control1: CGPoint(x: 152, y: 238), control2: CGPoint(x: 172, y: 222))
        body.addCurve(to: CGPoint(x: 120, y: 150), control1: CGPoint(x: 162, y: 168), control2: CGPoint(x: 148, y: 150))
        body.closeSubpath()
        ctx.fill(body, with: .color(.navy))

        // chest bib
        var bib = Path()
        bib.move(to: CGPoint(x: 120, y: 160))
        bib.addCurve(to: CGPoint(x: 99, y: 191),  control1: CGPoint(x: 107, y: 160), control2: CGPoint(x: 99, y: 173))
        bib.addCurve(to: CGPoint(x: 120, y: 222), control1: CGPoint(x: 99, y: 210),  control2: CGPoint(x: 109, y: 222))
        bib.addCurve(to: CGPoint(x: 141, y: 191), control1: CGPoint(x: 131, y: 222), control2: CGPoint(x: 141, y: 210))
        bib.addCurve(to: CGPoint(x: 120, y: 160), control1: CGPoint(x: 141, y: 173), control2: CGPoint(x: 133, y: 160))
        bib.closeSubpath()
        ctx.fill(bib, with: .color(.tan))

        // legs + paws
        ctx.fill(Path(roundedRect: CGRect(x: 93, y: 198, width: 22, height: 42), cornerRadius: 11), with: .color(.navy))
        ctx.fill(Path(roundedRect: CGRect(x: 125, y: 198, width: 22, height: 42), cornerRadius: 11), with: .color(.navy))
        ctx.fill(Path(roundedRect: CGRect(x: 90, y: 221, width: 27, height: 20), cornerRadius: 10), with: .color(.tan))
        ctx.fill(Path(roundedRect: CGRect(x: 123, y: 221, width: 27, height: 20), cornerRadius: 10), with: .color(.tan))

        // head
        ctx.fill(ell(120, 92, 56, 50), with: .color(.navy))
        // tan eyebrow points
        ctx.fill(ell(98, 73, 9, 5.5), with: .color(.tan))
        ctx.fill(ell(142, 73, 9, 5.5), with: .color(.tan))
        // muzzle
        ctx.fill(ell(120, 112, 35, 29), with: .color(.tan))

        // eyes
        ctx.fill(ell(99, 91, 12.5, 14.5), with: .color(.cream))
        ctx.fill(ell(141, 91, 12.5, 14.5), with: .color(.cream))

        if happy {
            var l = Path(); l.move(to: CGPoint(x: 90, y: 92)); l.addQuadCurve(to: CGPoint(x: 108, y: 92), control: CGPoint(x: 99, y: 83))
            ctx.stroke(l, with: .color(.navyDeep), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            var r = Path(); r.move(to: CGPoint(x: 132, y: 92)); r.addQuadCurve(to: CGPoint(x: 150, y: 92), control: CGPoint(x: 141, y: 83))
            ctx.stroke(r, with: .color(.navyDeep), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        } else {
            ctx.fill(ell(101, 93, 8.5, 10), with: .color(Color(hex: 0x3C2716)))
            ctx.fill(ell(143, 93, 8.5, 10), with: .color(Color(hex: 0x3C2716)))
            ctx.fill(ell(98, 89, 3, 3),  with: .color(.white))
            ctx.fill(ell(140, 89, 3, 3), with: .color(.white))
            // eyelids (blink)
            let lid = blinkAmount(time)
            if lid > 0.001 {
                let h = 15 * lid
                ctx.fill(ell(99, 91, 13, h),  with: .color(.navy))
                ctx.fill(ell(141, 91, 13, h), with: .color(.navy))
            }
        }

        // nose
        ctx.fill(ell(120, 103, 11, 8.5), with: .color(.navyDeep))
        ctx.fill(ell(116, 100, 3, 2), with: .color(Color(hex: 0x7C8893).opacity(0.7)))

        // mouth
        var mouth = Path()
        mouth.move(to: CGPoint(x: 120, y: 111)); mouth.addQuadCurve(to: CGPoint(x: 110, y: 126), control: CGPoint(x: 120, y: 122))
        mouth.move(to: CGPoint(x: 120, y: 111)); mouth.addQuadCurve(to: CGPoint(x: 130, y: 126), control: CGPoint(x: 120, y: 122))
        ctx.stroke(mouth, with: .color(.navyDeep), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        // collar
        var collar = Path()
        collar.move(to: CGPoint(x: 84, y: 148))
        collar.addQuadCurve(to: CGPoint(x: 156, y: 148), control: CGPoint(x: 120, y: 168))
        collar.addLine(to: CGPoint(x: 156, y: 161))
        collar.addQuadCurve(to: CGPoint(x: 84, y: 161), control: CGPoint(x: 120, y: 181))
        collar.closeSubpath()
        ctx.fill(collar, with: .color(.brandRed))

        // tag
        var link = Path(); link.move(to: CGPoint(x: 120, y: 170)); link.addLine(to: CGPoint(x: 120, y: 178))
        ctx.stroke(link, with: .color(.goldDeep), style: StrokeStyle(lineWidth: 3))
        ctx.fill(ell(120, 186, 10, 10), with: .color(.gold))
        ctx.stroke(ell(120, 186, 10, 10), with: .color(.goldDeep), style: StrokeStyle(lineWidth: 2))
        ctx.fill(ell(120, 186, 3.5, 3.5), with: .color(.goldDeep.opacity(0.55)))
    }
}

#Preview {
    HStack { PuppyView(size: 160); PuppyView(size: 160, happy: true) }
        .padding()
        .background(LoomiBackground())
}
