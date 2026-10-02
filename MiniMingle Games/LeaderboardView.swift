//
//  LeaderboardView.swift
//  MiniMingle Games
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CartoonBackground()

            // The whole list scrolls, so it fits in landscape too.
            ScrollView {
                VStack(spacing: 10) {
                    Text("🏆 Leaderboard")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.pink)
                        .padding(.top, 24)
                        .padding(.bottom, 6)

                    if app.scores.isEmpty {
                        Text("Win a game to get on the board!")
                            .font(Theme.font(.title3))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                    } else {
                        ForEach(Array(app.scores.prefix(10).enumerated()), id: \.element.id) { index, entry in
                            row(rank: index, entry: entry)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Done") { dismiss() }
                .buttonStyle(CartoonButtonStyle())
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
    }

    private func row(rank: Int, entry: ScoreEntry) -> some View {
        let medals = ["🥇", "🥈", "🥉"]
        return HStack(spacing: 12) {
            Text(rank < medals.count ? medals[rank] : "\(rank + 1)")
                .font(rank < medals.count ? .title : Theme.font(.title3))
                .foregroundStyle(Theme.ink)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.heroName)
                    .font(Theme.font(.headline))
                    .foregroundStyle(Theme.ink)
                Text(entry.game)
                    .font(Theme.font(.caption, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer()
            Text("\(entry.points)")
                .font(Theme.font(.title3))
                .foregroundStyle(Theme.pinkDark)
        }
        .padding(12)
        .cartoonCard(fill: rank == 0 ? Theme.yellow.opacity(0.35) : .white)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LeaderboardView()
        .environment(AppState())
}
