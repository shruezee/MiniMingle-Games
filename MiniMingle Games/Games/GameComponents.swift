//
//  GameComponents.swift
//  MiniMingle Games
//
//  Types and small views shared by all five games.
//

import SwiftUI

/// Who is playing. Player 0 is the human, player 1 is the computer or a friend.
struct GameSession {
    let players: [Hero]
    let vsAI: Bool

    func label(_ index: Int) -> String {
        vsAI ? (index == 0 ? "You" : "Computer") : "Player \(index + 1)"
    }

    func turnText(_ turn: Int) -> String {
        if vsAI {
            return turn == 0 ? "Your turn, \(players[0].name)!" : "\(players[1].name) is thinking…"
        }
        return "\(players[turn].name)'s turn!"
    }

    /// True while the computer is choosing, so taps should be ignored.
    func isComputerTurn(_ turn: Int) -> Bool {
        vsAI && turn == 1
    }
}

/// Reported by a game when it ends. A nil winner means a draw.
struct GameResult: Equatable {
    let winner: Int?
    let points: Int
}

/// Rounded white label used for turn and status messages.
struct StatusPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.font(.headline))
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.white)
                    .shadow(color: Theme.lavenderEdge, radius: 0, x: 0, y: 4)
            )
            .animation(.easeInOut(duration: 0.2), value: text)
    }
}

/// Wins for both players across rounds.
struct ScoreHeader: View {
    let session: GameSession
    let wins: [Int]
    /// Stack the two players top to bottom (used beside the board in landscape).
    var vertical = false

    var body: some View {
        Group {
            if vertical {
                VStack(spacing: 12) { cards }
            } else {
                HStack(spacing: 12) { cards }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var cards: some View {
        ForEach(0..<2, id: \.self) { index in
            HStack(spacing: 10) {
                HeroBadge(hero: session.players[index])
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 0) {
                    Text(session.label(index))
                        .font(Theme.font(.caption, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                    Text(session.players[index].name)
                        .font(Theme.font(.footnote))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
                Text("\(wins[index])")
                    .font(Theme.font(.title))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
            }
            .padding(10)
            .cartoonCard(fill: .white, edge: session.players[index].light)
            .accessibilityElement(children: .combine)
        }
    }
}

extension View {
    /// Blue toy-board frame used behind game grids.
    func boardCard(fill: Color = Theme.blue, edge: Color = Theme.blueDark) -> some View {
        padding(12)
            .cartoonCard(fill: fill, edge: edge, radius: 28)
    }

    /// Scales a board to the biggest size that fits the space left on screen,
    /// keeping its width-to-height ratio. Keeps boards on-screen in landscape
    /// and stops them growing huge on iPad.
    func fittedBoard(ratio: CGFloat, maxWidth: CGFloat = 640) -> some View {
        aspectRatio(ratio, contentMode: .fit)
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
