//
//  AppIconView.swift
//  MiniMingle Games
//
//  The app icon, drawn with shapes only (no image files).
//  It is a full 1024 x 1024 square with no transparency and no rounded
//  corners, because iOS rounds the corners itself.
//

import SwiftUI

struct AppIconView: View {
    /// Size of the artwork in points. The App Store icon is 1024 x 1024.
    static let side: CGFloat = 1024

    var body: some View {
        ZStack {
            // Edge-to-edge background: blue sky fading into soft lavender.
            LinearGradient(
                colors: [Theme.blue, Theme.lavender],
                startPoint: .top,
                endPoint: .bottom
            )

            // Game pieces in the corners (all kept away from the face).
            Circle()
                .fill(Theme.lavenderDark)
                .frame(width: 190, height: 190)
                .shadow(color: Theme.ink.opacity(0.35), radius: 0, x: 0, y: 12)
                .position(x: 170, y: 190)

            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Theme.mint)
                .frame(width: 170, height: 170)
                .shadow(color: Theme.mintDark, radius: 0, x: 0, y: 12)
                .rotationEffect(.degrees(12))
                .position(x: 860, y: 175)

            // Pink disc. The flat shadow is its own disc so it only sits underneath.
            ZStack {
                Circle().fill(Theme.pinkDark).offset(y: 16)
                Circle().fill(Theme.pink)
                Circle()
                    .fill(.white.opacity(0.55))
                    .frame(width: 64, height: 64)
                    .offset(x: -54, y: -56)
            }
            .frame(width: 250, height: 250)
            .position(x: 190, y: 835)

            // Hero piece (Tidecaller's water drop), with the same kind of shadow.
            ZStack {
                Circle().fill(Theme.blueDark).offset(y: 16)
                HeroBadge(hero: Hero.roster[2])
            }
            .frame(width: 250, height: 250)
            .position(x: 834, y: 835)

            // The big smiling character.
            face
        }
        .frame(width: Self.side, height: Self.side)
        .clipped()
    }

    // MARK: Face

    private var face: some View {
        ZStack {
            Circle()
                .fill(Theme.yellow)
                .frame(width: 620, height: 620)
                .shadow(color: Theme.yellowDark, radius: 0, x: 0, y: 26)

            // Lightning bolt on the forehead: the "hero" touch.
            EmblemShape(emblem: .bolt)
                .fill(Theme.pink)
                .frame(width: 150, height: 150)
                .shadow(color: Theme.pinkDark, radius: 0, x: 0, y: 8)
                .offset(y: -190)

            // Eyes with a white sparkle each.
            ForEach([-1.0, 1.0], id: \.self) { side in
                Capsule()
                    .fill(Theme.ink)
                    .frame(width: 74, height: 126)
                    .overlay(alignment: .topLeading) {
                        Circle()
                            .fill(.white)
                            .frame(width: 30, height: 30)
                            .offset(x: 14, y: 20)
                    }
                    .offset(x: side * 128, y: -30)
            }

            // Rosy cheeks.
            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle()
                    .fill(Theme.pink.opacity(0.75))
                    .frame(width: 100, height: 100)
                    .offset(x: side * 224, y: 90)
            }

            // Big happy smile.
            SmileShape()
                .stroke(Theme.ink, style: StrokeStyle(lineWidth: 44, lineCap: .round))
                .frame(width: 250, height: 110)
                .offset(y: 150)
        }
        .position(x: Self.side / 2, y: 500)
    }
}

/// A simple curved smile that fills the rect it is drawn in.
private struct SmileShape: Shape {
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

#Preview("Icon 1024") {
    // The real artwork is 1024 pt wide, so shrink it to fit the canvas.
    AppIconView()
        .scaleEffect(0.36)
        .frame(width: 370, height: 370)
}

#Preview("How it looks on the Home Screen") {
    // Same artwork shrunk to real icon sizes, with iOS-style rounded corners.
    HStack(spacing: 24) {
        ForEach([180.0, 120.0, 60.0], id: \.self) { size in
            AppIconView()
                .scaleEffect(size / AppIconView.side)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous))
        }
    }
    .padding(30)
    .background(Color.gray.opacity(0.3))
}
