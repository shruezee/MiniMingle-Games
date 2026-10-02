//
//  GameContainerView.swift
//  MiniMingle Games
//
//  Wraps one game with the score header and the "game finished" popup.
//  Records points on the leaderboard when someone wins.
//

import SwiftUI

struct GameContainerView: View {
    let kind: GameKind
    let session: GameSession

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var round = 0
    @State private var wins = [0, 0]
    @State private var pending: GameResult?
    @State private var result: GameResult?

    /// Landscape phones: scores sit beside the board so it can use the full height.
    private var sideBySide: Bool { verticalSizeClass == .compact }

    var body: some View {
        ZStack {
            CartoonBackground()

            // The scores live in a safe-area inset that moves from the top to the
            // side, so the game itself keeps its identity (and progress) on rotation.
            game
                .id(round)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .safeAreaInset(edge: .top, spacing: 0) {
                    if !sideBySide {
                        ScoreHeader(session: session, wins: wins)
                            .padding(.horizontal)
                    }
                }
                .safeAreaInset(edge: .leading, spacing: 0) {
                    if sideBySide {
                        ScoreHeader(session: session, wins: wins, vertical: true)
                            .frame(width: 240)
                            .padding(.leading)
                    }
                }

            if let result {
                ResultOverlay(
                    session: session,
                    result: result,
                    onAgain: playAgain,
                    onHome: { dismiss() }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        // Give the player a moment to see the final board before the popup.
        .task(id: pending) {
            guard let finished = pending else { return }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            complete(finished)
        }
    }

    @ViewBuilder
    private var game: some View {
        switch kind {
        case .ticTacToe: TicTacToeView(session: session, onFinish: { finish($0) })
        case .bingo: BingoView(session: session, onFinish: { finish($0) })
        case .connectFour: ConnectFourView(session: session, onFinish: { finish($0) })
        case .dotsAndBoxes: DotsAndBoxesView(session: session, onFinish: { finish($0) })
        case .memoryMatch: MemoryMatchView(session: session, onFinish: { finish($0) })
        }
    }

    private func finish(_ finished: GameResult) {
        pending = finished
    }

    private func complete(_ finished: GameResult) {
        pending = nil
        if let winner = finished.winner {
            wins[winner] += 1
            app.record(heroName: session.players[winner].name, game: kind, points: finished.points)
            if session.vsAI && winner == 1 { Feedback.lose() } else { Feedback.win() }
        } else {
            Feedback.match()
        }
        withAnimation(Theme.bounce) { result = finished }
    }

    private func playAgain() {
        withAnimation(Theme.bounce) { result = nil }
        round += 1
    }
}

private struct ResultOverlay: View {
    let session: GameSession
    let result: GameResult
    let onAgain: () -> Void
    let onHome: () -> Void

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var popped = false

    private var compact: Bool { verticalSizeClass == .compact }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 16) {
                if let winner = result.winner {
                    HeroBadge(hero: session.players[winner])
                        .frame(width: compact ? 64 : 110, height: compact ? 64 : 110)
                        .scaleEffect(popped ? 1 : 0.3)
                        .rotationEffect(.degrees(popped ? 0 : -25))
                    Text("\(session.players[winner].name) wins!")
                        .font(Theme.font(.title))
                        .foregroundStyle(Theme.pink)
                        .multilineTextAlignment(.center)
                    Text("+\(result.points) points ⭐")
                        .font(Theme.font(.title3))
                        .foregroundStyle(Theme.ink)
                } else {
                    Text("🤝")
                        .font(.system(size: 72))
                        .scaleEffect(popped ? 1 : 0.3)
                    Text("It's a draw!")
                        .font(Theme.font(.title))
                        .foregroundStyle(Theme.ink)
                }

                HStack(spacing: 12) {
                    Button("Home") { onHome() }
                        .buttonStyle(CartoonButtonStyle(fill: .white, edge: Theme.lavenderEdge, foreground: Theme.ink))
                    Button("Play Again") { onAgain() }
                        .buttonStyle(CartoonButtonStyle())
                }
            }
            .padding(compact ? 16 : 28)
            .frame(maxWidth: 360)
            .cartoonCard(radius: 32)
            .padding(compact ? 12 : 32)
        }
        .onAppear {
            withAnimation(Theme.bounce.delay(0.1)) { popped = true }
        }
    }
}

