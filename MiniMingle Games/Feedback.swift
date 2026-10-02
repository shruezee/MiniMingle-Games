//
//  Feedback.swift
//  MiniMingle Games
//
//  Simple sound and haptic feedback. Both can be switched off in Settings.
//

import AudioToolbox
import UIKit

@MainActor
enum Feedback {
    static let soundKey = "soundOn"
    static let hapticsKey = "hapticsOn"

    private enum Sound: UInt32 {
        case tap = 1104
        case place = 1105
        case match = 1057
        case win = 1025
        case lose = 1053
        case error = 1073
    }

    private static var soundOn: Bool {
        UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true
    }

    private static var hapticsOn: Bool {
        UserDefaults.standard.object(forKey: hapticsKey) as? Bool ?? true
    }

    private static func play(_ sound: Sound) {
        guard soundOn else { return }
        AudioServicesPlaySystemSound(SystemSoundID(sound.rawValue))
    }

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsOn else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    /// Any button press.
    static func tap() {
        play(.tap)
        impact(.light)
    }

    /// A piece or line was placed on the board.
    static func place() {
        play(.place)
        impact(.medium)
    }

    /// A pair or a box was completed.
    static func match() {
        play(.match)
        notify(.success)
    }

    static func win() {
        play(.win)
        notify(.success)
    }

    static func lose() {
        play(.lose)
        notify(.warning)
    }

    /// An invalid move.
    static func error() {
        play(.error)
        notify(.error)
    }
}
