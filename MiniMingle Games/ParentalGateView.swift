//
//  ParentalGateView.swift
//  MiniMingle Games
//
//  A "grown-ups only" check shown before Settings (and before any external
//  link or purchase, if the app ever adds one). It asks the player to read
//  three numbers written as words and type them as digits, which young
//  children usually cannot do yet.
//

import SwiftUI

struct ParentalGateView: View {
    /// Called once the correct digits were typed.
    let onPass: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var digits = ParentalGateView.makeChallenge()
    @State private var entry = ""
    @State private var triedWrong = false

    private static let words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    private static func makeChallenge() -> [Int] {
        Array((0...9).shuffled().prefix(3))
    }

    private var prompt: String {
        digits.map { Self.words[$0] }.joined(separator: "  ·  ")
    }

    private var answer: String {
        digits.map(String.init).joined()
    }

    var body: some View {
        ZStack {
            CartoonBackground()

            ScrollView {
                VStack(spacing: 16) {
                    Text("🔒 Grown-ups only")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.pink)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)

                    Text("Type these numbers as digits to continue:")
                        .font(Theme.font(.headline, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.center)

                    Text(prompt)
                        .font(Theme.font(.title2))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .cartoonCard()

                    entryBoxes

                    Text(triedWrong ? "Not quite. Here is a new one." : " ")
                        .font(Theme.font(.subheadline, weight: .medium))
                        .foregroundStyle(Theme.pinkDark)

                    keypad
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Cancel") { dismiss() }
                .buttonStyle(CartoonButtonStyle(fill: .white, edge: Theme.lavenderEdge, foreground: Theme.ink))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .presentationDetents([.large])
    }

    // MARK: Pieces

    private var entryBoxes: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                let character = index < entry.count ? String(Array(entry)[index]) : ""
                Text(character)
                    .font(Theme.font(.largeTitle))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 64, height: 72)
                    .cartoonCard(
                        fill: index == entry.count ? Theme.softPink : .white,
                        edge: index == entry.count ? Theme.pinkEdge : Theme.lavenderEdge
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Typed \(entry.count) of 3 digits")
    }

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(1...9, id: \.self) { number in
                key(String(number)) { type(String(number)) }
            }
            Color.clear.frame(height: 1)
            key("0") { type("0") }
            key("⌫", label: "Delete") {
                if !entry.isEmpty { _ = entry.removeLast() }
            }
        }
        .padding(.top, 4)
    }

    private func key(_ title: String, label: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(Theme.font(.title))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 60)
        }
        .buttonStyle(CartoonTileStyle())
        .accessibilityLabel(label ?? title)
    }

    // MARK: Logic

    private func type(_ digit: String) {
        guard entry.count < 3 else { return }
        entry += digit
        guard entry.count == 3 else { return }

        if entry == answer {
            onPass()
            dismiss()
        } else {
            // Wrong answer: clear it and ask for a different set of numbers.
            Feedback.error()
            entry = ""
            digits = Self.makeChallenge()
            triedWrong = true
        }
    }
}

#Preview {
    ParentalGateView(onPass: {})
}
