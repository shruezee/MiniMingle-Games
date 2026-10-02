//
//  DotsAndBoxesView.swift
//  MiniMingle Games
//
//  Take turns drawing lines between dots. Close a box to claim it
//  and play again. The player with the most boxes wins.
//

import SwiftUI

struct DotsAndBoxesView: View {
    let session: GameSession
    let onFinish: (GameResult) -> Void

    /// Boxes along each side of the board.
    private static let size = 4

    private struct Line: Hashable {
        let horizontal: Bool
        let row: Int
        let col: Int
    }

    private static let allLines: [Line] = {
        var lines: [Line] = []
        for row in 0...DotsAndBoxesView.size {
            for col in 0..<DotsAndBoxesView.size {
                lines.append(Line(horizontal: true, row: row, col: col))
            }
        }
        for row in 0..<DotsAndBoxesView.size {
            for col in 0...DotsAndBoxesView.size {
                lines.append(Line(horizontal: false, row: row, col: col))
            }
        }
        return lines
    }()

    @State private var lineOwners: [Line: Int] = [:]
    @State private var boxOwners: [Int: Int] = [:]
    @State private var turn = 0
    @State private var finished = false

    var body: some View {
        VStack(spacing: 20) {
            StatusPill(text: statusText)

            board
                .padding(8)
                .cartoonCard(fill: Theme.cream, edge: Theme.mintDark, radius: 28)
                .fittedBoard(ratio: 1)
        }
        .padding(.vertical, 8)
        // The computer keeps drawing while it is its turn (including bonus turns).
        .task(id: lineOwners.count) {
            guard session.isComputerTurn(turn), !finished else { return }
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled, let line = aiLine() else { return }
            draw(line)
        }
    }

    private var statusText: String {
        let mine = boxOwners.values.filter { $0 == 0 }.count
        let theirs = boxOwners.values.filter { $0 == 1 }.count
        let score = "\(mine) – \(theirs)"
        return finished ? "Boxes \(score)" : "\(session.turnText(turn))  ·  \(score)"
    }

    // MARK: Board drawing

    private var board: some View {
        GeometryReader { geo in
            let side = geo.size.width
            let pad: CGFloat = 24
            let step = (side - pad * 2) / CGFloat(Self.size)
            let dots = Self.size + 1

            ZStack {
                ForEach(0..<(Self.size * Self.size), id: \.self) { box in
                    if let owner = boxOwners[box] {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(session.players[owner].light)
                            .frame(width: step - 14, height: step - 14)
                            .overlay {
                                HeroBadge(hero: session.players[owner]).padding(8)
                            }
                            .position(
                                x: pad + (CGFloat(box % Self.size) + 0.5) * step,
                                y: pad + (CGFloat(box / Self.size) + 0.5) * step
                            )
                            .transition(.scale)
                            .allowsHitTesting(false)
                    }
                }

                ForEach(Self.allLines, id: \.self) { line in
                    lineButton(line, step: step, pad: pad)
                }

                ForEach(0..<(dots * dots), id: \.self) { dot in
                    Circle()
                        .fill(Theme.ink)
                        .frame(width: 14, height: 14)
                        .position(
                            x: pad + CGFloat(dot % dots) * step,
                            y: pad + CGFloat(dot / dots) * step
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func lineButton(_ line: Line, step: CGFloat, pad: CGFloat) -> some View {
        let x = pad + CGFloat(line.col) * step + (line.horizontal ? step / 2 : 0)
        let y = pad + CGFloat(line.row) * step + (line.horizontal ? 0 : step / 2)
        let owner = lineOwners[line]
        let color = owner.map { session.players[$0].dark } ?? Theme.lavenderEdge

        return Button {
            humanTap(line)
        } label: {
            ZStack {
                Color.clear
                Capsule()
                    .fill(color)
                    .frame(
                        width: line.horizontal ? step - 18 : (owner == nil ? 8 : 10),
                        height: line.horizontal ? (owner == nil ? 8 : 10) : step - 18
                    )
            }
            .frame(width: line.horizontal ? step : 44, height: line.horizontal ? 44 : step)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
        .accessibilityLabel(owner == nil ? "Empty line" : "Drawn line")
    }

    // MARK: Game logic

    private func humanTap(_ line: Line) {
        guard !finished, !session.isComputerTurn(turn) else { return }
        draw(line)
    }

    private func draw(_ line: Line) {
        guard !finished, lineOwners[line] == nil else { return }

        var gained = 0
        withAnimation(Theme.bounce) {
            lineOwners[line] = turn
            for box in Self.boxes(touching: line) where boxOwners[box] == nil && Self.sides(of: box, in: lineOwners) == 4 {
                boxOwners[box] = turn
                gained += 1
            }
        }

        if gained > 0 { Feedback.match() } else { Feedback.place() }

        if boxOwners.count == Self.size * Self.size {
            finish()
        } else if gained == 0 {
            turn = 1 - turn
        }
    }

    private func finish() {
        finished = true
        let mine = boxOwners.values.filter { $0 == 0 }.count
        let theirs = boxOwners.values.filter { $0 == 1 }.count
        if mine == theirs {
            onFinish(GameResult(winner: nil, points: 0))
        } else {
            let winner = mine > theirs ? 0 : 1
            onFinish(GameResult(winner: winner, points: 50 + max(mine, theirs) * 10))
        }
    }

    /// Box indices (row * size + col) that a line borders.
    private static func boxes(touching line: Line) -> [Int] {
        var result: [Int] = []
        if line.horizontal {
            if line.row > 0 { result.append((line.row - 1) * size + line.col) }
            if line.row < size { result.append(line.row * size + line.col) }
        } else {
            if line.col > 0 { result.append(line.row * size + line.col - 1) }
            if line.col < size { result.append(line.row * size + line.col) }
        }
        return result
    }

    private static func sides(of box: Int, in owners: [Line: Int]) -> Int {
        let row = box / size
        let col = box % size
        let edges = [
            Line(horizontal: true, row: row, col: col),
            Line(horizontal: true, row: row + 1, col: col),
            Line(horizontal: false, row: row, col: col),
            Line(horizontal: false, row: row, col: col + 1)
        ]
        return edges.filter { owners[$0] != nil }.count
    }

    // MARK: Computer player (closes boxes, avoids giving away a third side)

    private func aiLine() -> Line? {
        let open = Self.allLines.filter { lineOwners[$0] == nil }
        if let capture = open.first(where: { line in
            Self.boxes(touching: line).contains { Self.sides(of: $0, in: lineOwners) == 3 }
        }) {
            return capture
        }
        let safe = open.filter { line in
            Self.boxes(touching: line).allSatisfy { Self.sides(of: $0, in: lineOwners) < 2 }
        }
        return safe.randomElement() ?? open.randomElement()
    }
}

#Preview("Dots & Boxes") {
    let session = GameSession(players: Array(Hero.roster.prefix(2)), vsAI: true)
    DotsAndBoxesView(session: session, onFinish: { _ in })
        .padding(.horizontal)
        .safeAreaInset(edge: .top) { ScoreHeader(session: session, wins: [1, 0]).padding(.horizontal) }
        .background(CartoonBackground())
}
