//
//  Theme.swift
//  MiniMingle Games
//
//  Cartoon Kids look: pastel palette, rounded fonts, chunky buttons.
//  Every screen takes its colors and fonts from here.
//

import SwiftUI

extension Color {
    /// Creates a color from a 0xRRGGBB value.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    // MARK: Colors
    static let ink = Color(hex: 0x4A3B6B)
    static let inkSoft = Color(hex: 0x8D7BB0)

    static let pink = Color(hex: 0xFF7EB6)
    static let pinkDark = Color(hex: 0xD94F8D)
    static let softPink = Color(hex: 0xFFE0EF)
    static let pinkEdge = Color(hex: 0xFFA8CF)
    static let pinkGlow = Color(hex: 0xFFC2DC)

    static let yellow = Color(hex: 0xFFD86B)
    static let yellowDark = Color(hex: 0xE6B530)

    static let mint = Color(hex: 0x9BE8B5)
    static let mintDark = Color(hex: 0x62C98A)

    static let blue = Color(hex: 0x7FB8FF)
    static let blueDark = Color(hex: 0x559DE8)

    static let lavender = Color(hex: 0xD1B3FF)
    static let lavenderDark = Color(hex: 0xA57FE0)
    static let lavenderEdge = Color(hex: 0xDCD0F0)

    static let skyTop = Color(hex: 0xCFEEFF)
    static let cream = Color(hex: 0xFFF3D9)
    static let grass = Color(hex: 0xD6F5D6)
    static let cell = Color(hex: 0xEAF4FF)

    // MARK: Fonts (rounded, scale with Dynamic Type)
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .heavy)

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    // MARK: Animation
    static let bounce = Animation.spring(response: 0.35, dampingFraction: 0.55)
}

// MARK: - Background

/// Sky gradient with two drifting clouds.
struct CartoonBackground: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            // Sky to cream at 70% to grass, like the reference page.
            LinearGradient(
                stops: [
                    .init(color: Theme.skyTop, location: 0),
                    .init(color: Theme.cream, location: 0.7),
                    .init(color: Theme.grass, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            GeometryReader { geo in
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: 90, height: 30)
                    .position(x: 25, y: 55)
                    .offset(x: drift ? 14 : -14)
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: 70, height: 24)
                    .position(x: geo.size.width - 25, y: 128)
                    .offset(x: drift ? -12 : 12)
            }
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: drift)
        }
        .ignoresSafeArea()
        .onAppear { drift = true }
        .accessibilityHidden(true)
    }
}

// MARK: - Card look

extension View {
    /// White (or tinted) rounded card with a flat "toy" shadow underneath.
    func cartoonCard(fill: Color = .white, edge: Color = Theme.lavenderEdge, radius: CGFloat = 22) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(fill)
                .shadow(color: edge, radius: 0, x: 0, y: 4)
        )
    }
}

// MARK: - Button styles

/// Chunky pill button that sinks when pressed and gives sound + haptic feedback.
struct CartoonButtonStyle: ButtonStyle {
    var fill: Color = Theme.pink
    var edge: Color = Theme.pinkDark
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.font(.title3))
            .foregroundStyle(foreground)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(minHeight: 56)
            .background(
                Capsule()
                    .fill(fill)
                    .shadow(color: edge, radius: 0, x: 0, y: configuration.isPressed ? 1 : 6)
            )
            .offset(y: configuration.isPressed ? 5 : 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Theme.bounce, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Feedback.tap() }
            }
    }
}

/// Rounded tile button for game and hero choices on the Home screen.
/// A selected tile lifts up and grows a little, as in the reference page.
struct CartoonTileStyle: ButtonStyle {
    var fill: Color = .white
    var edge: Color = Theme.lavenderEdge
    var selected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(fill)
                    .shadow(color: edge, radius: 0, x: 0, y: configuration.isPressed ? 1 : 4)
            )
            .offset(y: configuration.isPressed ? 3 : (selected ? -2 : 0))
            .scaleEffect(configuration.isPressed ? 0.96 : (selected ? 1.04 : 1))
            .animation(Theme.bounce, value: selected)
            .animation(Theme.bounce, value: configuration.isPressed)
            .animation(Theme.bounce, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Feedback.tap() }
            }
    }
}
