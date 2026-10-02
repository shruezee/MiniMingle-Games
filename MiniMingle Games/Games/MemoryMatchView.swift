//
//  MemoryMatchView.swift
//  MiniMingle Games
//
//  Flip two cards to find matching heroes. A match earns a point and
//  another turn. The player with the most pairs wins.
//

import SwiftUI

struct MemoryMatchView: View {
    let session: GameSession
    let onFinish: (GameResult) -> Void

    private struct Card: Identifiable {
        let id: Int
        let hero: Hero
        var faceUp = false
        var matched = false
    }

    @State private var cards: [Card] = MemoryMatchView.makeDeck()
    @State private var flipped: [Int] = []
    @State private var seen: Set<Int> = []
    @State private var pairs = [0, 0]
    @State private var turn = 0
    @State private var locked = false
    @State private var finished = false

    private var aiKey: Int {
        turn * 10 + flipped.count + (locked ? 5 : 0)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StatusPill(text: statusText)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(cards.indices, id: \.self) { index in
                        cardView(index)
                    }
                }
                .boardCard(fill: Theme.lavender, edge: Theme.lavenderDark)
                .frame(maxWidth: 460)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        // After two cards are up, wait a moment, then score or flip back.
        .task(id: locked) {
            guard locked else { return }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            resolve()
        }
        // The computer flips its two cards one at a time.
        .task(id: aiKey) {
            guard session.isComputerTurn(turn), !finished, !locked else { return }
            try? await Task.sleep(for: .milliseconds(750))
            guard !Task.isCancelled else { return }
            if flipped.isEmpty {
                if let first = aiFirstPick() { flip(first) }
            } else if flipped.count == 1, let second = aiSecondPick() {
                flip(second)
            }
        }
    }

    private var statusText: String {
        if finished { return "Pairs \(pairs[0]) – \(pairs[1])" }
        return "\(session.turnText(turn))  ·  \(pairs[0]) – \(pairs[1])"
    }

    private func cardView(_ index: Int) -> some View {
        let card = cards[index]
        let showFront = card.faceUp || card.matched

        return Button {
            guard !session.isComputerTurn(turn) else { return }
            flip(index)
        } label: {
            ZStack {
                // Back of the card.
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.pink)
                    .overlay {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .opacity(showFront ? 0 : 1)

                // Front of the card.
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(card.matched ? Theme.mint : .white)
                    .overlay {
                        HeroBadge(hero: card.hero).padding(8)
                    }
                    .opacity(showFront ? 1 : 0)
            }
            .aspectRatio(0.8, contentMode: .fit)
            .rotation3DEffect(.degrees(showFront ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showFront ? card.hero.name : "Face-down card")
    }

    // MARK: Game logic

    private func flip(_ index: Int) {
        guard !locked, !finished, cards.indices.contains(index),
              !cards[index].faceUp, !cards[index].matched else { return }

        withAnimation(.easeInOut(duration: 0.3)) { cards[index].faceUp = true }
        Feedback.place()
        seen.insert(index)
        flipped.append(index)

        if flipped.count == 2 { locked = true }
    }

    private func resolve() {
        guard flipped.count == 2 else {
            locked = false
            return
        }
        let first = flipped[0]
        let second = flipped[1]

        if cards[first].hero == cards[second].hero {
            withAnimation(Theme.bounce) {
                cards[first].matched = true
                cards[second].matched = true
            }
            pairs[turn] += 1
            Feedback.match()
            flipped = []
            locked = false
            if cards.allSatisfy({ $0.matched }) { finish() }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                cards[first].faceUp = false
                cards[second].faceUp = false
            }
            flipped = []
            locked = false
            turn = 1 - turn
        }
    }

    private func finish() {
        finished = true
        if pairs[0] == pairs[1] {
            onFinish(GameResult(winner: nil, points: 0))
        } else {
            let winner = pairs[0] > pairs[1] ? 0 : 1
            onFinish(GameResult(winner: winner, points: 50 + pairs[winner] * 30))
        }
    }

    private static func makeDeck() -> [Card] {
        let faces = (Hero.roster + Hero.roster).shuffled()
        return faces.enumerated().map { Card(id: $0.offset, hero: $0.element) }
    }

    // MARK: Computer player (remembers most cards it has seen)

    private func knownPair() -> (Int, Int)? {
        let known = seen.filter { !cards[$0].matched }.sorted()
        for a in known {
            for b in known where b > a && cards[a].hero == cards[b].hero {
                return (a, b)
            }
        }
        return nil
    }

    private func aiFirstPick() -> Int? {
        if Int.random(in: 0..<10) < 7, let pair = knownPair() { return pair.0 }
        return cards.indices.filter { !cards[$0].faceUp && !cards[$0].matched }.randomElement()
    }

    private func aiSecondPick() -> Int? {
        guard let first = flipped.first else { return nil }
        if Int.random(in: 0..<10) < 7,
           let match = seen.first(where: { $0 != first && !cards[$0].matched && cards[$0].hero == cards[first].hero }) {
            return match
        }
        return cards.indices.filter { $0 != first && !cards[$0].faceUp && !cards[$0].matched }.randomElement()
    }
}
