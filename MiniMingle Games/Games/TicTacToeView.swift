//
//  TicTacToeView.swift
//  MiniMingle Games
//

import SwiftUI

struct TicTacToeView: View {
    let session: GameSession
    let onFinish: (GameResult) -> Void

    @State private var board: [Int?] = Array(repeating: nil, count: 9)
    @State private var turn = 0
    @State private var finished = false
    @State private var winLine: [Int] = []

    private static let lines = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]

    var body: some View {
        VStack(spacing: 20) {
            StatusPill(text: finished ? "Game over!" : session.turnText(turn))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    cell(index)
                }
            }
            .boardCard(fill: Theme.softPink, edge: Theme.pinkEdge)
            .fittedBoard(ratio: 1)
        }
        .padding(.vertical, 8)
        // The computer moves whenever the turn passes to it.
        .task(id: turn) {
            guard session.isComputerTurn(turn), !finished else { return }
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled, let move = aiMove() else { return }
            place(move)
        }
    }

    private func cell(_ index: Int) -> some View {
        Button {
            humanTap(index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(winLine.contains(index) ? Theme.yellow : .white)
                if let player = board[index] {
                    HeroBadge(hero: session.players[player])
                        .padding(10)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(board[index].map { session.players[$0].name } ?? "Empty square")
    }

    // MARK: Moves

    private func humanTap(_ index: Int) {
        guard !finished, board[index] == nil, !session.isComputerTurn(turn) else { return }
        place(index)
    }

    private func place(_ index: Int) {
        withAnimation(Theme.bounce) { board[index] = turn }
        Feedback.place()

        if let line = Self.winningLine(board) {
            winLine = line
            finish(winner: turn)
        } else if board.allSatisfy({ $0 != nil }) {
            finish(winner: nil)
        } else {
            turn = 1 - turn
        }
    }

    private func finish(winner: Int?) {
        finished = true
        let empties = board.filter { $0 == nil }.count
        onFinish(GameResult(winner: winner, points: winner == nil ? 0 : 100 + empties * 10))
    }

    // MARK: Computer player (wins if it can, usually blocks, otherwise center or random)

    private func aiMove() -> Int? {
        let empty = board.indices.filter { board[$0] == nil }
        if let win = empty.first(where: { wouldWin($0, player: 1) }) { return win }
        if Int.random(in: 0..<4) != 0, let block = empty.first(where: { wouldWin($0, player: 0) }) { return block }
        if board[4] == nil { return 4 }
        return empty.randomElement()
    }

    private func wouldWin(_ index: Int, player: Int) -> Bool {
        var test = board
        test[index] = player
        return Self.winningLine(test) != nil
    }

    private static func winningLine(_ board: [Int?]) -> [Int]? {
        lines.first { line in
            board[line[0]] != nil && board[line[0]] == board[line[1]] && board[line[1]] == board[line[2]]
        }
    }
}

#Preview("Tic-Tac-Toe") {
    let session = GameSession(players: Array(Hero.roster.prefix(2)), vsAI: true)
    TicTacToeView(session: session, onFinish: { _ in })
        .padding(.horizontal)
        .safeAreaInset(edge: .top) { ScoreHeader(session: session, wins: [1, 0]).padding(.horizontal) }
        .background(CartoonBackground())
}
