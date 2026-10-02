//
//  BingoView.swift
//  MiniMingle Games
//
//  Each player has a 5x5 card. Tap "Call a number", then tap the number
//  on your card if you have it. First full row, column or diagonal wins.
//

import SwiftUI

struct BingoView: View {
    let session: GameSession
    let onFinish: (GameResult) -> Void

    @State private var cards: [[Int]] = BingoView.makeCards()
    @State private var marked: [[Bool]] = [BingoView.freshMarks(), BingoView.freshMarks()]
    @State private var pool: [Int] = Array(1...75).shuffled()
    @State private var called: [Int] = []
    @State private var viewing = 0
    @State private var finished = false
    @State private var winLine: [Int] = []

    private static let letters = Array("BINGO")

    /// Every row, column and diagonal as card indices.
    private static let lines: [[Int]] = {
        var result: [[Int]] = []
        for r in 0..<5 { result.append((0..<5).map { r * 5 + $0 }) }
        for c in 0..<5 { result.append((0..<5).map { $0 * 5 + c }) }
        result.append((0..<5).map { $0 * 6 })
        result.append((0..<5).map { ($0 + 1) * 4 })
        return result
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                StatusPill(text: statusText)
                calledBanner

                if !session.vsAI {
                    Picker("Card", selection: $viewing) {
                        Text(session.players[0].name).tag(0)
                        Text(session.players[1].name).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 460)
                }

                cardView

                Button("Call a number") { callNumber() }
                    .buttonStyle(CartoonButtonStyle(fill: Theme.yellow, edge: Theme.yellowDark, foreground: Theme.ink))
                    .disabled(finished)
                    .padding(.top, 4)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        // The computer marks the latest number a moment after it is called.
        .task(id: called.count) {
            guard session.vsAI, !finished, let number = called.last else { return }
            try? await Task.sleep(for: .milliseconds(1300))
            guard !Task.isCancelled, !finished else { return }
            if Int.random(in: 0..<10) < 8 {
                mark(player: 1, number: number)
            }
        }
    }

    private var statusText: String {
        if finished { return "BINGO!" }
        if called.isEmpty { return "Tap “Call a number” to start!" }
        return session.vsAI ? "Find it on your card!" : "Both players: tap your card!"
    }

    // MARK: Views

    private var calledBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.pink)
                    .shadow(color: Theme.pinkDark, radius: 0, y: 5)
                if let last = called.last {
                    VStack(spacing: 0) {
                        Text(String(Self.letters[(last - 1) / 15]))
                            .font(Theme.font(.caption))
                        Text("\(last)")
                            .font(Theme.font(.title, weight: .heavy))
                    }
                    .foregroundStyle(.white)
                    .id(last)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text("?").font(Theme.font(.title)).foregroundStyle(.white)
                }
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 2) {
                Text("Called so far")
                    .font(Theme.font(.caption, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                Text(called.suffix(6).reversed().map(String.init).joined(separator: "  "))
                    .font(Theme.font(.headline))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(minHeight: 22, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .cartoonCard()
        .frame(maxWidth: 460)
        .accessibilityElement(children: .combine)
    }

    private var cardView: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { column in
                    Text(String(Self.letters[column]))
                        .font(Theme.font(.title3, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                ForEach(0..<25, id: \.self) { index in
                    square(index)
                }
            }
        }
        .boardCard(fill: Theme.lavender, edge: Theme.lavenderDark)
        .frame(maxWidth: 460)
    }

    private func square(_ index: Int) -> some View {
        let number = cards[viewing][index]
        let isMarked = marked[viewing][index]
        let inWin = finished && winLine.contains(index)

        return Button {
            tapSquare(index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(inWin ? Theme.yellow : (isMarked ? Theme.mint : .white))
                if number == 0 {
                    Image(systemName: "star.fill").foregroundStyle(Theme.yellowDark)
                } else {
                    Text("\(number)")
                        .font(Theme.font(.headline))
                        .foregroundStyle(Theme.ink)
                        .minimumScaleFactor(0.6)
                }
                if isMarked && number != 0 {
                    HeroBadge(hero: session.players[viewing])
                        .padding(6)
                        .opacity(0.9)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(number == 0 ? "Free space" : "\(number)\(isMarked ? ", marked" : "")")
    }

    // MARK: Game logic

    private func callNumber() {
        guard !finished else { return }
        guard let number = pool.popLast() else {
            finish(winner: nil)
            return
        }
        withAnimation(Theme.bounce) { called.append(number) }
        Feedback.place()
    }

    private func tapSquare(_ index: Int) {
        guard !finished, cards[viewing][index] != 0, !marked[viewing][index] else { return }
        let number = cards[viewing][index]
        guard called.contains(number) else {
            Feedback.error()
            return
        }
        mark(player: viewing, number: number)
    }

    private func mark(player: Int, number: Int) {
        guard !finished, let index = cards[player].firstIndex(of: number), !marked[player][index] else { return }
        withAnimation(Theme.bounce) { marked[player][index] = true }
        Feedback.match()

        if let line = Self.lines.first(where: { $0.allSatisfy { marked[player][$0] } }) {
            winLine = line
            viewing = player
            finish(winner: player)
        }
    }

    private func finish(winner: Int?) {
        finished = true
        onFinish(GameResult(winner: winner, points: winner == nil ? 0 : 100 + (75 - called.count)))
    }

    // MARK: Card creation

    private static func makeCards() -> [[Int]] {
        [makeCard(), makeCard()]
    }

    /// Column B holds 1-15, I holds 16-30, and so on. The center is a free space (0).
    private static func makeCard() -> [Int] {
        let columns: [[Int]] = (0..<5).map { column in
            Array(Array((column * 15 + 1)...(column * 15 + 15)).shuffled().prefix(5))
        }
        var card = Array(repeating: 0, count: 25)
        for column in 0..<5 {
            for row in 0..<5 {
                card[row * 5 + column] = columns[column][row]
            }
        }
        card[12] = 0
        return card
    }

    private static func freshMarks() -> [Bool] {
        var marks = Array(repeating: false, count: 25)
        marks[12] = true
        return marks
    }
}
