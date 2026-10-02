//
//  Hero.swift
//  MiniMingle Games
//
//  Six original heroes. Each one has a color pair and an emblem
//  that is used as the game piece.
//

import SwiftUI

enum Emblem {
    case bolt, flame, drop, leaf, eye, wing
}

struct Hero: Identifiable, Hashable {
    let id: String
    let name: String
    let power: String
    let light: Color
    let dark: Color
    let emblem: Emblem

    static let roster: [Hero] = [
        Hero(id: "volt", name: "Volt Vanguard", power: "Lightning speed",
             light: Color(hex: 0xFFE066), dark: Color(hex: 0x5B7CFF), emblem: .bolt),
        Hero(id: "aurora", name: "Aurora Blaze", power: "Fire and light",
             light: Color(hex: 0xFFB37A), dark: Color(hex: 0xFF5FA2), emblem: .flame),
        Hero(id: "tide", name: "Tidecaller", power: "Water waves",
             light: Color(hex: 0x8FF0E6), dark: Color(hex: 0x3A9BDC), emblem: .drop),
        Hero(id: "oak", name: "Iron Oak", power: "Earth strength",
             light: Color(hex: 0xA8E6A1), dark: Color(hex: 0x8A5A2B), emblem: .leaf),
        Hero(id: "lynx", name: "Shadow Lynx", power: "Sneaky stealth",
             light: Color(hex: 0xD1B3FF), dark: Color(hex: 0x5B3FA0), emblem: .eye),
        Hero(id: "sky", name: "Skybolt", power: "Flight and wind",
             light: Color(hex: 0xBFE6FF), dark: Color(hex: 0x4AA8FF), emblem: .wing)
    ]
}

// MARK: - Emblem drawing

/// Draws an emblem inside a 24 x 24 design grid scaled to the given rect.
struct EmblemShape: Shape {
    let emblem: Emblem

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        let ox = rect.midX - 12 * s
        let oy = rect.midY - 12 * s
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: ox + x * s, y: oy + y * s)
        }

        var p = Path()
        switch emblem {
        case .bolt:
            p.move(to: pt(13, 2))
            p.addLine(to: pt(4, 14))
            p.addLine(to: pt(11, 14))
            p.addLine(to: pt(9, 22))
            p.addLine(to: pt(20, 9))
            p.addLine(to: pt(13, 9))
            p.closeSubpath()
        case .flame:
            p.move(to: pt(12, 2))
            p.addCurve(to: pt(18, 14), control1: pt(13, 7), control2: pt(18, 9))
            p.addCurve(to: pt(6, 14), control1: pt(18, 21), control2: pt(6, 21))
            p.addCurve(to: pt(9, 8), control1: pt(6, 11), control2: pt(8, 10))
            p.addLine(to: pt(10.5, 10))
            p.closeSubpath()
        case .drop:
            p.move(to: pt(12, 2))
            p.addCurve(to: pt(5, 15), control1: pt(10, 6), control2: pt(5, 10))
            p.addCurve(to: pt(19, 15), control1: pt(5, 21), control2: pt(19, 21))
            p.addCurve(to: pt(12, 2), control1: pt(19, 10), control2: pt(14, 6))
            p.closeSubpath()
        case .leaf:
            p.move(to: pt(4, 20))
            p.addCurve(to: pt(20, 4), control1: pt(4, 9), control2: pt(12, 4))
            p.addCurve(to: pt(4, 20), control1: pt(20, 12), control2: pt(15, 20))
            p.closeSubpath()
        case .eye:
            p.move(to: pt(2, 12))
            p.addQuadCurve(to: pt(22, 12), control: pt(12, 3))
            p.addQuadCurve(to: pt(2, 12), control: pt(12, 21))
            p.closeSubpath()
            // Pupil (cut out with the even-odd fill rule).
            p.addEllipse(in: CGRect(x: ox + 10 * s, y: oy + 8.5 * s, width: 4 * s, height: 7 * s))
        case .wing:
            p.move(to: pt(3, 15))
            p.addQuadCurve(to: pt(21, 8), control: pt(9, 3))
            p.addQuadCurve(to: pt(10, 14), control: pt(12, 9))
            p.addQuadCurve(to: pt(3, 15), control: pt(8, 12))
            p.closeSubpath()
        }
        return p
    }
}

/// Round hero badge. It fills the space it is given, so set a frame on it.
struct HeroBadge: View {
    let hero: Hero

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().fill(hero.light)
                Circle()
                    .fill(.white.opacity(0.65))
                    .frame(width: s * 0.2, height: s * 0.2)
                    .offset(x: -s * 0.2, y: -s * 0.22)
                EmblemShape(emblem: hero.emblem)
                    .fill(hero.dark, style: FillStyle(eoFill: true))
                    .padding(s * 0.2)
            }
            .frame(width: s, height: s)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(hero.name)
    }
}
