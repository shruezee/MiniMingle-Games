//
//  AppState.swift
//  MiniMingle Games
//
//  Game list, chosen hero and mode, and the saved leaderboard.
//

import SwiftUI

enum GameKind: String, CaseIterable, Identifiable, Hashable {
    case ticTacToe, bingo, connectFour, dotsAndBoxes, memoryMatch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ticTacToe: "Tic-Tac-Toe"
        case .bingo: "Bingo"
        case .connectFour: "Connect 4"
        case .dotsAndBoxes: "Dots & Boxes"
        case .memoryMatch: "Memory Match"
        }
    }

    var blurb: String {
        switch self {
        case .ticTacToe: "Three in a row wins!"
        case .bingo: "Call numbers, fill a line!"
        case .connectFour: "Drop discs, connect four!"
        case .dotsAndBoxes: "Close the most boxes!"
        case .memoryMatch: "Find the matching heroes!"
        }
    }

    var emoji: String {
        switch self {
        case .ticTacToe: "❌"
        case .bingo: "🎯"
        case .connectFour: "🔴"
        case .dotsAndBoxes: "🟦"
        case .memoryMatch: "🧩"
        }
    }

    var tint: Color {
        switch self {
        case .ticTacToe: Theme.pinkEdge
        case .bingo: Theme.yellow
        case .connectFour: Theme.blue
        case .dotsAndBoxes: Theme.mint
        case .memoryMatch: Theme.lavender
        }
    }

    var tintDark: Color {
        switch self {
        case .ticTacToe: Theme.pink
        case .bingo: Theme.yellowDark
        case .connectFour: Theme.blueDark
        case .dotsAndBoxes: Theme.mintDark
        case .memoryMatch: Theme.lavenderDark
        }
    }
}

enum PlayMode: String, CaseIterable, Identifiable {
    case ai, friend

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ai: "🤖 Computer"
        case .friend: "👫 Friend"
        }
    }
}

struct ScoreEntry: Codable, Identifiable {
    var id = UUID()
    let heroName: String
    let game: String
    let points: Int
    let date: Date
}

@MainActor
@Observable
final class AppState {
    private(set) var hero: Hero
    private(set) var mode: PlayMode
    private(set) var scores: [ScoreEntry]

    private let defaults = UserDefaults.standard

    init() {
        let heroID = UserDefaults.standard.string(forKey: "heroID")
        hero = Hero.roster.first { $0.id == heroID } ?? Hero.roster[1]
        mode = PlayMode(rawValue: UserDefaults.standard.string(forKey: "mode") ?? "") ?? .ai
        if let data = UserDefaults.standard.data(forKey: "scores"),
           let saved = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            scores = saved
        } else {
            scores = []
        }
    }

    /// The second player is the next hero in the roster.
    var opponent: Hero {
        let index = Hero.roster.firstIndex(of: hero) ?? 0
        return Hero.roster[(index + 1) % Hero.roster.count]
    }

    var session: GameSession {
        GameSession(players: [hero, opponent], vsAI: mode == .ai)
    }

    func choose(_ hero: Hero) {
        self.hero = hero
        defaults.set(hero.id, forKey: "heroID")
    }

    func choose(_ mode: PlayMode) {
        self.mode = mode
        defaults.set(mode.rawValue, forKey: "mode")
    }

    func record(heroName: String, game: GameKind, points: Int) {
        guard points > 0 else { return }
        scores.append(ScoreEntry(heroName: heroName, game: game.title, points: points, date: .now))
        scores.sort { $0.points > $1.points }
        scores = Array(scores.prefix(50))
        save()
    }

    func clearScores() {
        scores = []
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(scores) {
            defaults.set(data, forKey: "scores")
        }
    }
}
