//
//  PuppyView.swift
//  Loomi the Doberman puppy — brand-sheet fidelity: outlined cartoon style,
//  gradient shading, pink inner ears, tan points, expressive eyes.
//  Drawn with SwiftUI Canvas in a 480x520 design space and scaled to fit.
//  Blinks on a timer-free schedule via TimelineView. `happy` = waving pose.
//

import SwiftUI

struct PuppyView: View {
    var size: CGFloat = 190
    var happy: Bool = false

    // outline ink + illustration palette
    private static let outline   = Color(hex: 0x16222D)
    private static let navyHi    = Color(hex: 0x2A4257)
    private static let navyLo    = Color(hex: 0x1B2B39)
    private static let tanHi     = Color(hex: 0xF5A257)
    private static let tanLo     = Color(hex: 0xDD7E2F)
    private static let earPink   = Color(hex: 0xF2A9B4)
    private static let irisHi    = Color(hex: 0x8A5526)
    private static let irisLo    = Color(hex: 0x3C2716)
    private static let sheen     = Color(hex: 0x33495D)

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, canvasSize in
                let s = min(canvasSize.width / 480, canvasSize.height / 520)
                ctx.scaleBy(x: s, y: s)
                draw(&ctx, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
        .frame(width: size, height: size * 520 / 480)
        .accessibilityLabel("Loomi, a friendly Doberman puppy")
    }

    // MARK: - shading helpers

    private func navyFill(for path: Path) -> GraphicsContext.Shading {
        vGrad(path, Self.navyHi, Self.navyLo)
    }
    private func tanFill(for path: Path) -> GraphicsContext.Shading {
        vGrad(path, Self.tanHi, Self.tanLo)
    }
    private func vGrad(_ path: Path, _ top: Color, _ bottom: Color) -> GraphicsContext.Shading {
        let r = path.boundingRect
        return .linearGradient(Gradient(colors: [top, bottom]),
                               startPoint: CGPoint(x: r.midX, y: r.minY),
                               endPoint:   CGPoint(x: r.midX, y: r.maxY))
    }
    private func outlined(_ ctx: inout GraphicsContext, _ path: Path,
                          fill: GraphicsContext.Shading, lineWidth: CGFloat = 7) {
        ctx.fill(path, with: fill)
        ctx.stroke(path, with: .color(Self.outline),
                   style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
    private func ell(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
    }

    private func blinkAmount(_ t: TimeInterval) -> CGFloat {
        let cyc = t.truncatingRemainder(dividingBy: 4.5)   // blink ~every 4.5s
        guard cyc > 4.30 else { return 0 }
        let p = (cyc - 4.30) / 0.20                         // 0...1 across blink window
        return CGFloat(p < 0.5 ? p * 2 : (1 - p) * 2)       // close then open
    }

    // MARK: - drawing

    private func draw(_ ctx: inout GraphicsContext, time: TimeInterval) {
        // ground shadow
        ctx.fill(ell(240, 492, 150, 22), with: .color(.roseDeep.opacity(0.55)))

        // tail
        var tail = Path()
        tail.move(to: .init(x: 356, y: 420))
        tail.addQuadCurve(to: .init(x: 404, y: 372), control: .init(x: 400, y: 410))
        tail.addQuadCurve(to: .init(x: 388, y: 342), control: .init(x: 407, y: 348))
        tail.addQuadCurve(to: .init(x: 372, y: 384), control: .init(x: 394, y: 366))
        tail.addQuadCurve(to: .init(x: 344, y: 400), control: .init(x: 356, y: 396))
        tail.closeSubpath()
        outlined(&ctx, tail, fill: navyFill(for: tail))

        // haunches
        var lH = Path()
        lH.move(to: .init(x: 158, y: 340))
        lH.addQuadCurve(to: .init(x: 116, y: 424), control: .init(x: 118, y: 368))
        lH.addQuadCurve(to: .init(x: 162, y: 480), control: .init(x: 116, y: 470))
        lH.addLine(to: .init(x: 196, y: 484))
        lH.addQuadCurve(to: .init(x: 168, y: 364), control: .init(x: 160, y: 428))
        lH.closeSubpath()
        outlined(&ctx, lH, fill: navyFill(for: lH))

        var rH = Path()
        rH.move(to: .init(x: 322, y: 340))
        rH.addQuadCurve(to: .init(x: 364, y: 424), control: .init(x: 362, y: 368))
        rH.addQuadCurve(to: .init(x: 318, y: 480), control: .init(x: 364, y: 470))
        rH.addLine(to: .init(x: 284, y: 484))
        rH.addQuadCurve(to: .init(x: 312, y: 364), control: .init(x: 320, y: 428))
        rH.closeSubpath()
        outlined(&ctx, rH, fill: navyFill(for: rH))

        // back paws
        var lBP = Path()
        lBP.move(to: .init(x: 128, y: 458))
        lBP.addQuadCurve(to: .init(x: 150, y: 488), control: .init(x: 118, y: 486))
        lBP.addQuadCurve(to: .init(x: 180, y: 470), control: .init(x: 176, y: 489))
        lBP.addQuadCurve(to: .init(x: 166, y: 452), control: .init(x: 182, y: 456))
        lBP.addQuadCurve(to: .init(x: 128, y: 458), control: .init(x: 142, y: 448))
        lBP.closeSubpath()
        outlined(&ctx, lBP, fill: tanFill(for: lBP), lineWidth: 6)

        var rBP = Path()
        rBP.move(to: .init(x: 352, y: 458))
        rBP.addQuadCurve(to: .init(x: 330, y: 488), control: .init(x: 362, y: 486))
        rBP.addQuadCurve(to: .init(x: 300, y: 470), control: .init(x: 304, y: 489))
        rBP.addQuadCurve(to: .init(x: 314, y: 452), control: .init(x: 298, y: 456))
        rBP.addQuadCurve(to: .init(x: 352, y: 458), control: .init(x: 338, y: 448))
        rBP.closeSubpath()
        outlined(&ctx, rBP, fill: tanFill(for: rBP), lineWidth: 6)

        // body
        var torso = Path()
        torso.move(to: .init(x: 240, y: 268))
        torso.addCurve(to: .init(x: 138, y: 380), control1: .init(x: 176, y: 268), control2: .init(x: 142, y: 316))
        torso.addCurve(to: .init(x: 240, y: 486), control1: .init(x: 134, y: 446), control2: .init(x: 178, y: 486))
        torso.addCurve(to: .init(x: 342, y: 380), control1: .init(x: 302, y: 486), control2: .init(x: 346, y: 446))
        torso.addCurve(to: .init(x: 240, y: 268), control1: .init(x: 338, y: 316), control2: .init(x: 304, y: 268))
        torso.closeSubpath()
        outlined(&ctx, torso, fill: navyFill(for: torso))

        // chest bib
        var bib = Path()
        bib.move(to: .init(x: 240, y: 292))
        bib.addCurve(to: .init(x: 190, y: 372), control1: .init(x: 208, y: 292), control2: .init(x: 190, y: 326))
        bib.addCurve(to: .init(x: 240, y: 452), control1: .init(x: 190, y: 424), control2: .init(x: 212, y: 452))
        bib.addCurve(to: .init(x: 290, y: 372), control1: .init(x: 268, y: 452), control2: .init(x: 290, y: 424))
        bib.addCurve(to: .init(x: 240, y: 292), control1: .init(x: 290, y: 326), control2: .init(x: 272, y: 292))
        bib.closeSubpath()
        outlined(&ctx, bib, fill: tanFill(for: bib), lineWidth: 6)

        // left front leg + paw (always down)
        var lLeg = Path()
        lLeg.move(to: .init(x: 196, y: 368))
        lLeg.addLine(to: .init(x: 196, y: 452))
        lLeg.addQuadCurve(to: .init(x: 214, y: 470), control: .init(x: 196, y: 470))
        lLeg.addLine(to: .init(x: 222, y: 470))
        lLeg.addQuadCurve(to: .init(x: 238, y: 452), control: .init(x: 238, y: 470))
        lLeg.addLine(to: .init(x: 238, y: 368))
        lLeg.closeSubpath()
        outlined(&ctx, lLeg, fill: navyFill(for: lLeg), lineWidth: 6)

        var lPaw = Path()
        lPaw.move(to: .init(x: 182, y: 452))
        lPaw.addQuadCurve(to: .init(x: 214, y: 486), control: .init(x: 178, y: 484))
        lPaw.addQuadCurve(to: .init(x: 244, y: 464), control: .init(x: 244, y: 487))
        lPaw.addQuadCurve(to: .init(x: 224, y: 446), control: .init(x: 244, y: 448))
        lPaw.addQuadCurve(to: .init(x: 182, y: 452), control: .init(x: 196, y: 444))
        lPaw.closeSubpath()
        outlined(&ctx, lPaw, fill: tanFill(for: lPaw), lineWidth: 6)
        var lToes = Path()
        lToes.move(to: .init(x: 206, y: 466)); lToes.addLine(to: .init(x: 206, y: 484))
        lToes.move(to: .init(x: 222, y: 468)); lToes.addLine(to: .init(x: 222, y: 486))
        ctx.stroke(lToes, with: .color(Self.outline.opacity(0.8)),
                   style: StrokeStyle(lineWidth: 4, lineCap: .round))

        if happy {
            // right front leg raised, waving
            var arm = Path()
            arm.move(to: .init(x: 282, y: 380))
            arm.addQuadCurve(to: .init(x: 336, y: 316), control: .init(x: 318, y: 356))
            arm.addLine(to: .init(x: 352, y: 330))
            arm.addQuadCurve(to: .init(x: 300, y: 402), control: .init(x: 336, y: 376))
            arm.addQuadCurve(to: .init(x: 276, y: 398), control: .init(x: 284, y: 412))
            arm.addQuadCurve(to: .init(x: 282, y: 380), control: .init(x: 272, y: 388))
            arm.closeSubpath()
            outlined(&ctx, arm, fill: navyFill(for: arm), lineWidth: 6)

            // raised paw pad + toe beans
            let pad = ell(352, 306, 30, 27)
            outlined(&ctx, pad, fill: tanFill(for: pad), lineWidth: 6)
            ctx.fill(ell(352, 313, 12, 9),  with: .color(.tanDark))
            ctx.fill(ell(338, 296, 5.5, 5.5), with: .color(.tanDark))
            ctx.fill(ell(352, 292, 5.5, 5.5), with: .color(.tanDark))
            ctx.fill(ell(366, 296, 5.5, 5.5), with: .color(.tanDark))

            // motion ticks
            var ticks = Path()
            ticks.move(to: .init(x: 392, y: 258)); ticks.addLine(to: .init(x: 404, y: 240))
            ticks.move(to: .init(x: 406, y: 282)); ticks.addLine(to: .init(x: 424, y: 272))
            ticks.move(to: .init(x: 370, y: 244)); ticks.addLine(to: .init(x: 376, y: 224))
            ctx.stroke(ticks, with: .color(.teal),
                       style: StrokeStyle(lineWidth: 8, lineCap: .round))
        } else {
            // right front leg + paw down
            var rLeg = Path()
            rLeg.move(to: .init(x: 284, y: 368))
            rLeg.addLine(to: .init(x: 284, y: 452))
            rLeg.addQuadCurve(to: .init(x: 266, y: 470), control: .init(x: 284, y: 470))
            rLeg.addLine(to: .init(x: 258, y: 470))
            rLeg.addQuadCurve(to: .init(x: 242, y: 452), control: .init(x: 242, y: 470))
            rLeg.addLine(to: .init(x: 242, y: 368))
            rLeg.closeSubpath()
            outlined(&ctx, rLeg, fill: navyFill(for: rLeg), lineWidth: 6)

            var rPaw = Path()
            rPaw.move(to: .init(x: 298, y: 452))
            rPaw.addQuadCurve(to: .init(x: 266, y: 486), control: .init(x: 302, y: 484))
            rPaw.addQuadCurve(to: .init(x: 236, y: 464), control: .init(x: 236, y: 487))
            rPaw.addQuadCurve(to: .init(x: 256, y: 446), control: .init(x: 236, y: 448))
            rPaw.addQuadCurve(to: .init(x: 298, y: 452), control: .init(x: 284, y: 444))
            rPaw.closeSubpath()
            outlined(&ctx, rPaw, fill: tanFill(for: rPaw), lineWidth: 6)
            var rToes = Path()
            rToes.move(to: .init(x: 274, y: 466)); rToes.addLine(to: .init(x: 274, y: 484))
            rToes.move(to: .init(x: 258, y: 468)); rToes.addLine(to: .init(x: 258, y: 486))
            ctx.stroke(rToes, with: .color(Self.outline.opacity(0.8)),
                       style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }

        // ears with pink interiors
        var lEar = Path()
        lEar.move(to: .init(x: 158, y: 132))
        lEar.addLine(to: .init(x: 108, y: 22))
        lEar.addQuadCurve(to: .init(x: 118, y: 14), control: .init(x: 102, y: 8))
        lEar.addLine(to: .init(x: 216, y: 96)); lEar.closeSubpath()
        outlined(&ctx, lEar, fill: navyFill(for: lEar))

        var lEarIn = Path()
        lEarIn.move(to: .init(x: 162, y: 116))
        lEarIn.addLine(to: .init(x: 126, y: 40))
        lEarIn.addQuadCurve(to: .init(x: 133, y: 36), control: .init(x: 122, y: 30))
        lEarIn.addLine(to: .init(x: 198, y: 96)); lEarIn.closeSubpath()
        outlined(&ctx, lEarIn, fill: .color(Self.earPink), lineWidth: 5)

        var rEar = Path()
        rEar.move(to: .init(x: 322, y: 132))
        rEar.addLine(to: .init(x: 372, y: 22))
        rEar.addQuadCurve(to: .init(x: 362, y: 14), control: .init(x: 378, y: 8))
        rEar.addLine(to: .init(x: 264, y: 96)); rEar.closeSubpath()
        outlined(&ctx, rEar, fill: navyFill(for: rEar))

        var rEarIn = Path()
        rEarIn.move(to: .init(x: 318, y: 116))
        rEarIn.addLine(to: .init(x: 354, y: 40))
        rEarIn.addQuadCurve(to: .init(x: 347, y: 36), control: .init(x: 358, y: 30))
        rEarIn.addLine(to: .init(x: 282, y: 96)); rEarIn.closeSubpath()
        outlined(&ctx, rEarIn, fill: .color(Self.earPink), lineWidth: 5)

        // head
        let head = ell(240, 190, 112, 100)
        outlined(&ctx, head, fill: navyFill(for: head))

        // head sheen
        var sheenP = Path()
        sheenP.move(to: .init(x: 164, y: 130))
        sheenP.addQuadCurve(to: .init(x: 244, y: 98),  control: .init(x: 198, y: 100))
        sheenP.addQuadCurve(to: .init(x: 190, y: 150), control: .init(x: 206, y: 116))
        sheenP.addQuadCurve(to: .init(x: 164, y: 130), control: .init(x: 176, y: 138))
        sheenP.closeSubpath()
        ctx.fill(sheenP, with: .color(Self.sheen.opacity(0.55)))

        // tan brows
        let lBrow = ell(196, 149, 19, 12)
        outlined(&ctx, lBrow, fill: tanFill(for: lBrow), lineWidth: 5)
        let rBrow = ell(284, 149, 19, 12)
        outlined(&ctx, rBrow, fill: tanFill(for: rBrow), lineWidth: 5)

        // muzzle
        var muzzle = Path()
        muzzle.move(to: .init(x: 240, y: 168))
        muzzle.addCurve(to: .init(x: 172, y: 226), control1: .init(x: 196, y: 168), control2: .init(x: 172, y: 194))
        muzzle.addCurve(to: .init(x: 240, y: 278), control1: .init(x: 172, y: 258), control2: .init(x: 200, y: 278))
        muzzle.addCurve(to: .init(x: 308, y: 226), control1: .init(x: 280, y: 278), control2: .init(x: 308, y: 258))
        muzzle.addCurve(to: .init(x: 240, y: 168), control1: .init(x: 308, y: 194), control2: .init(x: 284, y: 168))
        muzzle.closeSubpath()
        outlined(&ctx, muzzle, fill: tanFill(for: muzzle), lineWidth: 6)

        // eyes
        let lWhite = ell(198, 185, 25, 29)
        let rWhite = ell(282, 185, 25, 29)
        outlined(&ctx, lWhite, fill: .color(Color(hex: 0xFFF9F2)), lineWidth: 5)
        outlined(&ctx, rWhite, fill: .color(Color(hex: 0xFFF9F2)), lineWidth: 5)

        func iris(_ cx: CGFloat, _ cy: CGFloat) {
            ctx.fill(ell(cx, cy, 17, 17), with: .radialGradient(
                Gradient(colors: [Self.irisHi, Self.irisLo]),
                center: CGPoint(x: cx - 4, y: cy - 6), startRadius: 0, endRadius: 20))
            ctx.fill(ell(cx, cy + 2, 8, 8), with: .color(Color(hex: 0x1A0F07)))
            ctx.fill(ell(cx - 6, cy - 8, 6, 6), with: .color(.white))
            ctx.fill(ell(cx + 6, cy + 8, 2.8, 2.8), with: .color(.white.opacity(0.8)))
        }
        iris(202, 189)
        iris(278, 189)

        // eyelids (blink) — calm pose only
        if !happy {
            let lid = blinkAmount(time)
            if lid > 0.001 {
                let h = 30 * lid
                outlined(&ctx, ell(198, 185, 26, h), fill: navyFill(for: lWhite), lineWidth: 5)
                outlined(&ctx, ell(282, 185, 26, h), fill: navyFill(for: rWhite), lineWidth: 5)
            }
        }

        // nose
        var nose = Path()
        nose.move(to: .init(x: 240, y: 205))
        nose.addQuadCurve(to: .init(x: 262, y: 221), control: .init(x: 262, y: 205))
        nose.addQuadCurve(to: .init(x: 240, y: 237), control: .init(x: 262, y: 237))
        nose.addQuadCurve(to: .init(x: 218, y: 221), control: .init(x: 218, y: 237))
        nose.addQuadCurve(to: .init(x: 240, y: 205), control: .init(x: 218, y: 205))
        nose.closeSubpath()
        outlined(&ctx, nose, fill: .color(Self.outline), lineWidth: 5)
        ctx.fill(ell(232, 215, 6, 4), with: .color(Color(hex: 0x5C6B77).opacity(0.8)))

        // mouth
        if happy {
            var open = Path()
            open.move(to: .init(x: 204, y: 240))
            open.addQuadCurve(to: .init(x: 276, y: 240), control: .init(x: 240, y: 282))
            open.addQuadCurve(to: .init(x: 240, y: 268), control: .init(x: 262, y: 268))
            open.addQuadCurve(to: .init(x: 204, y: 240), control: .init(x: 218, y: 268))
            open.closeSubpath()
            outlined(&ctx, open, fill: .color(Color(hex: 0x7A2020)), lineWidth: 6)

            var tongue = Path()
            tongue.move(to: .init(x: 226, y: 254))
            tongue.addQuadCurve(to: .init(x: 254, y: 254), control: .init(x: 240, y: 250))
            tongue.addQuadCurve(to: .init(x: 240, y: 276), control: .init(x: 254, y: 274))
            tongue.addQuadCurve(to: .init(x: 226, y: 254), control: .init(x: 226, y: 274))
            tongue.closeSubpath()
            outlined(&ctx, tongue, fill: .color(Color(hex: 0xF27D8A)), lineWidth: 5)
        } else {
            var mouth = Path()
            mouth.move(to: .init(x: 240, y: 239))
            mouth.addQuadCurve(to: .init(x: 222, y: 257), control: .init(x: 240, y: 253))
            mouth.move(to: .init(x: 240, y: 239))
            mouth.addQuadCurve(to: .init(x: 258, y: 257), control: .init(x: 240, y: 253))
            ctx.stroke(mouth, with: .color(Self.outline),
                       style: StrokeStyle(lineWidth: 6, lineCap: .round))
        }

        // collar + tag
        var collar = Path()
        collar.move(to: .init(x: 168, y: 296))
        collar.addQuadCurve(to: .init(x: 312, y: 296), control: .init(x: 240, y: 336))
        collar.addLine(to: .init(x: 312, y: 322))
        collar.addQuadCurve(to: .init(x: 168, y: 322), control: .init(x: 240, y: 362))
        collar.closeSubpath()
        outlined(&ctx, collar, fill: .color(.brandRed), lineWidth: 6)

        var link = Path()
        link.move(to: .init(x: 240, y: 338)); link.addLine(to: .init(x: 240, y: 352))
        ctx.stroke(link, with: .color(Color(hex: 0xB98F1E)), style: StrokeStyle(lineWidth: 6))
        let tag = ell(240, 368, 19, 19)
        outlined(&ctx, tag, fill: .color(.gold), lineWidth: 6)
        ctx.fill(ell(240, 368, 6.5, 6.5), with: .color(.goldDeep))
    }
}

#Preview {
    HStack { PuppyView(size: 160); PuppyView(size: 160, happy: true) }
        .padding()
        .background(LoomiBackground())
}
