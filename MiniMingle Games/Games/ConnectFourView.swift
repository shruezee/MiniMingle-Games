//
//  ConnectFourView.swift
//  MiniMingle Games
//

import SwiftUI

struct ConnectFourView: View {
    let session: GameSession
    let onFinish: (GameResult) -> Void

    private static let rows = 6
    private static let cols = 7

    @State private var board: [Int?] = Array(repeating: nil, count: 42)
    @State private var turn = 0
    @State private var finished = false
    @State private var winCells: [Int] = []

    var body: some View {
        VStack(spacing: 20) {
            StatusPill(text: finished ? "Game over!" : session.turnText(turn))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: Self.cols), spacing: 6) {
                ForEach(0..<(Self.rows * Self.cols), id: \.self) { index in
                    cell(index)
                }
            }
            .boardCard()
            .fittedBoard(ratio: 7.0 / 6.0)
        }
        .padding(.vertical, 8)
        .task(id: turn) {
            guard session.isComputerTurn(turn), !finished else { return }
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled, let column = aiColumn() else { return }
            drop(in: column)
        }
    }

    private func cell(_ index: Int) -> some View {
        let column = index % Self.cols
        return Button {
            guard !finished, !session.isComputerTurn(turn) else { return }
            drop(in: column)
        } label: {
            ZStack {
                Circle().fill(winCells.contains(index) ? Theme.yellow : Theme.cell)
                if let player = board[index] {
                    HeroBadge(hero: session.players[player])
                        .padding(2)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(board[index].map { session.players[$0].name } ?? "Empty, column \(column + 1)")
    }

    // MARK: Moves

    private static func lowestEmptyRow(in column: Int, board: [Int?]) -> Int? {
        for row in stride(from: rows - 1, through: 0, by: -1) where board[row * cols + column] == nil {
            return row
        }
        return nil
    }

    private func drop(in column: Int) {
        guard let row = Self.lowestEmptyRow(in: column, board: board) else {
            Feedback.error()
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            board[row * Self.cols + column] = turn
        }
        Feedback.place()

        if let cells = Self.winningCells(board) {
            winCells = cells
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
        onFinish(GameResult(winner: winner, points: winner == nil ? 0 : 100 + empties * 5))
    }

    /// Returns the four connected cells, if any.
    private static func winningCells(_ board: [Int?]) -> [Int]? {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        for row in 0..<rows {
            for col in 0..<cols {
                guard let player = board[row * cols + col] else { continue }
                for (dr, dc) in directions {
                    var cells = [row * cols + col]
                    for step in 1..<4 {
                        let r = row + dr * step
                        let c = col + dc * step
                        guard r >= 0, r < rows, c >= 0, c < cols, board[r * cols + c] == player else { break }
                        cells.append(r * cols + c)
                    }
                    if cells.count == 4 { return cells }
                }
            }
        }
        return nil
    }

    // MARK: Computer player (wins if it can, blocks, otherwise prefers the middle)

    private func aiColumn() -> Int? {
        let open = (0..<Self.cols).filter { Self.lowestEmptyRow(in: $0, board: board) != nil }
        if let win = open.first(where: { wouldWin(column: $0, player: 1) }) { return win }
        if let block = open.first(where: { wouldWin(column: $0, player: 0) }) { return block }
        let central = open.sorted { abs($0 - 3) < abs($1 - 3) }
        return central.prefix(3).randomElement()
    }

    private func wouldWin(column: Int, player: Int) -> Bool {
        guard let row = Self.lowestEmptyRow(in: column, board: board) else { return false }
        var test = board
        test[row * Self.cols + column] = player
        return Self.winningCells(test) != nil
    }
}

#Preview("Connect 4") {
    let session = GameSession(players: Array(Hero.roster.prefix(2)), vsAI: true)
    ConnectFourView(session: session, onFinish: { _ in })
        .padding(.horizontal)
        .safeAreaInset(edge: .top) { ScoreHeader(session: session, wins: [1, 0]).padding(.horizontal) }
        .background(CartoonBackground())
}
