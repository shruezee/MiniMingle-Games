//
//  HomeView.swift
//  MiniMingle Games
//
//  Follows the cartoon-kids reference: 1. choose a game, 2. choose a hero,
//  3. choose who plays, then the big pink "Let's Play!" button.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var app
    @Environment(PlayTimeManager.self) private var playTime
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var path: [GameKind] = []
    @State private var selectedGame: GameKind = .connectFour
    @State private var showParentalGate = false
    @State private var passedParentalGate = false
    @State private var showSettings = false
    @State private var showLeaderboard = false
    @State private var appeared = false

    private let title = "MiniMingle Games"

    // Layout adapts to iPad (regular x regular) and to landscape phones (compact height).
    private var compactHeight: Bool { verticalSizeClass == .compact }
    private var isPad: Bool { horizontalSizeClass == .regular && verticalSizeClass == .regular }
    private var scale: CGFloat { isPad ? 1.3 : 1 }
    private var contentWidth: CGFloat { isPad || compactHeight ? 760 : 600 }
    private var heroColumns: Int { compactHeight || horizontalSizeClass == .regular ? 6 : 3 }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                CartoonBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        header
                        if playTime.isLimitOn { timeLeftPill }
                        gameSection
                        heroSection
                        modeSection
                        // Landscape phones are short, so the button scrolls with the page
                        // instead of covering the tiles.
                        if compactHeight { playButton }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, isPad ? 24 : 8)
                    .padding(.bottom, 16)
                    .frame(maxWidth: contentWidth)
                    .frame(maxWidth: .infinity)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .safeAreaInset(edge: .bottom) {
                if !compactHeight { playButton }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: GameKind.self) { kind in
                GameContainerView(kind: kind, session: app.session)
            }
        }
        // Settings sit behind a parental gate. Settings opens only after the gate has closed.
        .sheet(isPresented: $showParentalGate, onDismiss: {
            if passedParentalGate {
                passedParentalGate = false
                showSettings = true
            }
        }) {
            ParentalGateView(onPass: { passedParentalGate = true })
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLeaderboard) { LeaderboardView() }
        // Time spent in the grown-ups area does not count against the daily timer.
        .onChange(of: showParentalGate || showSettings) { _, grownUpsArea in
            playTime.isPaused = grownUpsArea
        }
        // When time runs out, close any child-facing sheet so the break screen shows.
        .onChange(of: playTime.isTimeUp) { _, timeIsUp in
            if timeIsUp { showLeaderboard = false }
        }
        .onAppear { appeared = true }
    }

    // MARK: Header

    /// Shows how much of today's play time is left (only when a parent set a limit).
    private var timeLeftPill: some View {
        Text("⏱ \(playTime.remainingMinutes) min left today")
            .font(Theme.font(.subheadline))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(.white).shadow(color: Theme.lavenderEdge, radius: 0, x: 0, y: 4))
            .accessibilityLabel("\(playTime.remainingMinutes) minutes of play time left today")
    }

    private var header: some View {
        ZStack {
            titleLayer(Theme.pinkGlow, offset: 5)
            titleLayer(.white, offset: 3)
            titleLayer(Theme.pink, offset: 0)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(title)
                .padding(.horizontal, 0)

            HStack {
                roundButton(systemImage: "trophy.fill", label: "Leaderboard", fill: Theme.yellow) {
                    showLeaderboard = true
                }
                Spacer()
                roundButton(systemImage: "gearshape.fill", label: "Settings (grown-ups)", fill: .white) {
                    showParentalGate = true
                }
            }
        }
        .padding(.top, 4)
    }

    /// One layer of the title. Three stacked layers give the flat cartoon shadow.
    private func titleLayer(_ color: Color, offset: CGFloat) -> some View {
        Text(title)
            .font(Theme.font(.largeTitle))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 52)
            .offset(y: offset)
            .accessibilityHidden(offset != 0)
    }

    private func roundButton(systemImage: String, label: String, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Theme.ink)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(RoundIconStyle(fill: fill))
        .accessibilityLabel(label)
    }

    // MARK: 1. Games

    private var gameSection: some View {
        section("1. Choose a game") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104 * scale), spacing: 8)], spacing: 8) {
                ForEach(Array(GameKind.allCases.enumerated()), id: \.element) { index, kind in
                    let selected = kind == selectedGame
                    Button {
                        selectedGame = kind
                    } label: {
                        VStack(spacing: 4) {
                            Text(kind.emoji)
                                .font(.system(size: 34 * scale))
                            Text(kind.title)
                                .font(Theme.font(.footnote, weight: .medium))
                                .foregroundStyle(Theme.ink)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 88 * scale)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(CartoonTileStyle(
                        fill: selected ? Theme.yellow : .white,
                        edge: selected ? Theme.yellowDark : Theme.lavenderEdge,
                        selected: selected
                    ))
                    .accessibilityLabel(kind.title)
                    .accessibilityHint(kind.blurb)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                    // Tiles bounce in one after another.
                    .scaleEffect(appeared ? 1 : 0.5)
                    .opacity(appeared ? 1 : 0)
                    .animation(Theme.bounce.delay(Double(index) * 0.06), value: appeared)
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: 2. Heroes

    private var heroSection: some View {
        section("2. Choose your hero") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: heroColumns), spacing: 8) {
                ForEach(Hero.roster) { hero in
                    let selected = hero == app.hero
                    Button {
                        app.choose(hero)
                    } label: {
                        VStack(spacing: 2) {
                            HeroBadge(hero: hero)
                                .frame(width: 48 * scale, height: 48 * scale)
                            Text(hero.name)
                                .font(Theme.font(.caption2, weight: .medium))
                                .foregroundStyle(Theme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(CartoonTileStyle(
                        fill: selected ? Theme.softPink : .white,
                        edge: selected ? Theme.pinkEdge : Theme.lavenderEdge
                    ))
                    .accessibilityLabel(hero.name)
                    .accessibilityHint(hero.power)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: 3. Mode

    private var modeSection: some View {
        section("3. Who plays?") {
            HStack(spacing: 10) {
                ForEach(PlayMode.allCases) { mode in
                    let selected = mode == app.mode
                    Button(mode.title) {
                        app.choose(mode)
                    }
                    .buttonStyle(ModePillStyle(selected: selected))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: Play

    private var playButton: some View {
        Button {
            path.append(selectedGame)
        } label: {
            Text("Let's Play! ⭐")
                .font(Theme.font(.title))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(CartoonButtonStyle())
        .frame(maxWidth: 520)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: Helpers

    private func section<Content: View>(_ heading: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading)
                .font(Theme.font(.headline))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
}

/// Small round icon button for the header (42-44pt white circle).
private struct RoundIconStyle: ButtonStyle {
    let fill: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(fill)
                    .shadow(color: Theme.lavenderEdge, radius: 0, y: configuration.isPressed ? 1 : 4)
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(Theme.bounce, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Feedback.tap() }
            }
    }
}

/// Half-width pill for the Computer / Friend choice.
private struct ModePillStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.font(.headline))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Capsule()
                    .fill(selected ? Theme.mint : .white)
                    .shadow(
                        color: selected ? Theme.mintDark : Theme.lavenderEdge,
                        radius: 0,
                        y: configuration.isPressed ? 1 : 4
                    )
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(Theme.bounce, value: configuration.isPressed)
            .animation(Theme.bounce, value: selected)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Feedback.tap() }
            }
    }
}

#Preview {
    HomeView()
        .environment(AppState())
        .environment(PlayTimeManager())
}
