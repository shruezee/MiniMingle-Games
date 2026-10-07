//
//  SplashView.swift
//  MiniMingle Games
//
//  The animated splash that matches the app icon. Everything is sized from the
//  screen's own width and height, so it fits every iPhone and iPad, in
//  portrait and landscape.
//

import SwiftUI

struct SplashView: View {
    /// Called when the splash has finished and the app should show Home.
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    private let title = "MiniMingle Games"

    var body: some View {
        ZStack {
            artwork
            // Same footer as the launch screen, kept above the bottom safe area.
            VStack {
                Spacer()
                Text("© 2026 Shruezee Studio. All rights reserved.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }

    private var artwork: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let side = min(w, h)

            // The artwork is laid out in "units" where the face is 620 wide
            // (the same proportions as the app icon). It is about 934 units
            // wide and 865 units tall, so pick the unit that fits both ways.
            let titleHeight = side * 0.16
            let unit = min(w * 0.9 / 934, (h - titleHeight - side * 0.12) / 865)
            let cx = w / 2
            let cy = (h - titleHeight) / 2 - 27.5 * unit

            ZStack {
                LinearGradient(colors: [Theme.blue, Theme.lavender], startPoint: .top, endPoint: .bottom)

                // Corner pieces, in the same places as on the icon.
                flatDisc(fill: Theme.lavenderDark, edge: Theme.ink.opacity(0.35), size: 190 * unit, unit: unit)
                    .piece(shown: shown, delay: 0.25, x: cx - 342 * unit, y: cy - 310 * unit)

                RoundedRectangle(cornerRadius: 40 * unit, style: .continuous)
                    .fill(Theme.mint)
                    .frame(width: 170 * unit, height: 170 * unit)
                    .shadow(color: Theme.mintDark, radius: 0, x: 0, y: 12 * unit)
                    .rotationEffect(.degrees(12))
                    .piece(shown: shown, delay: 0.35, x: cx + 348 * unit, y: cy - 325 * unit)

                ZStack {
                    Circle().fill(Theme.pinkDark).offset(y: 16 * unit)
                    Circle().fill(Theme.pink)
                    Circle()
                        .fill(.white.opacity(0.55))
                        .frame(width: 64 * unit, height: 64 * unit)
                        .offset(x: -54 * unit, y: -56 * unit)
                }
                .frame(width: 250 * unit, height: 250 * unit)
                .piece(shown: shown, delay: 0.45, x: cx - 322 * unit, y: cy + 335 * unit)

                ZStack {
                    Circle().fill(Theme.blueDark).offset(y: 16 * unit)
                    HeroBadge(hero: Hero.roster[2])
                }
                .frame(width: 250 * unit, height: 250 * unit)
                .piece(shown: shown, delay: 0.55, x: cx + 322 * unit, y: cy + 335 * unit)

                // The smiling character, bouncing in first.
                MascotFace(diameter: 620 * unit)
                    .scaleEffect(shown || reduceMotion ? 1 : 0.2)
                    .opacity(shown || reduceMotion ? 1 : 0)
                    .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.5), value: shown)
                    .position(x: cx, y: cy)

                // Title with the same flat pink shadow as the Home screen.
                let titleY = (cy + 460 * unit + h) / 2
                ZStack {
                    titleLayer(Theme.pinkGlow, side: side, offset: 5)
                    titleLayer(.white, side: side, offset: 3)
                    titleLayer(Theme.pink, side: side, offset: 0)
                }
                .opacity(shown || reduceMotion ? 1 : 0)
                .offset(y: shown || reduceMotion ? 0 : 24)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.6), value: shown)
                .position(x: cx, y: titleY)
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .onAppear { shown = true }
        .task {
            try? await Task.sleep(for: .seconds(reduceMotion ? 0.8 : 2.2))
            onFinish()
        }
    }

    private func titleLayer(_ color: Color, side: CGFloat, offset: CGFloat) -> some View {
        Text(title)
            .font(.system(size: side * 0.085, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .offset(y: offset * side / 400)
    }

    private func flatDisc(fill: Color, edge: Color, size: CGFloat, unit: CGFloat) -> some View {
        ZStack {
            Circle().fill(edge).offset(y: 12 * unit)
            Circle().fill(fill)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Piece pop-in

private extension View {
    /// Places a piece and pops it in with a small bounce.
    func piece(shown: Bool, delay: Double, x: CGFloat, y: CGFloat) -> some View {
        scaleEffect(shown ? 1 : 0.1)
            .opacity(shown ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(delay), value: shown)
            .position(x: x, y: y)
    }
}

// MARK: - Mascot

/// The smiling yellow face from the app icon, drawn at any size.
struct MascotFace: View {
    let diameter: CGFloat

    var body: some View {
        let d = diameter
        ZStack {
            Circle()
                .fill(Theme.yellow)
                .frame(width: d, height: d)
                .shadow(color: Theme.yellowDark, radius: 0, x: 0, y: d * 0.042)

            EmblemShape(emblem: .bolt)
                .fill(Theme.pink)
                .frame(width: d * 0.242, height: d * 0.242)
                .shadow(color: Theme.pinkDark, radius: 0, x: 0, y: d * 0.013)
                .offset(y: -d * 0.306)

            ForEach([-1.0, 1.0], id: \.self) { side in
                Capsule()
                    .fill(Theme.ink)
                    .frame(width: d * 0.119, height: d * 0.203)
                    .overlay(alignment: .topLeading) {
                        Circle()
                            .fill(.white)
                            .frame(width: d * 0.048, height: d * 0.048)
                            .offset(x: d * 0.023, y: d * 0.032)
                    }
                    .offset(x: side * d * 0.206, y: -d * 0.048)
            }

            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle()
                    .fill(Theme.pink.opacity(0.75))
                    .frame(width: d * 0.161, height: d * 0.161)
                    .offset(x: side * d * 0.361, y: d * 0.145)
            }

            MascotSmile()
                .stroke(Theme.ink, style: StrokeStyle(lineWidth: d * 0.071, lineCap: .round))
                .frame(width: d * 0.403, height: d * 0.177)
                .offset(y: d * 0.242)
        }
        .frame(width: d, height: d)
    }
}

private struct MascotSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.6)
        )
        return path
    }
}

#Preview("Splash") {
    SplashView(onFinish: {})
}
