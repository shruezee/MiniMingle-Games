//
//  PlayTimeManager.swift
//  MiniMingle Games
//
//  A daily play-time limit that only grown-ups can change (Settings is behind
//  the parental gate). Time is counted while the app is on screen and resets
//  every day. Everything stays on the device.
//

import SwiftUI

@MainActor
@Observable
final class PlayTimeManager {
    /// Limits a parent can pick, in minutes. 0 means "no limit".
    static let limitChoices = [0, 10, 15, 20, 30, 45, 60]

    private(set) var limitMinutes: Int
    private(set) var usedSeconds: Int
    /// Extra seconds a parent granted today on top of the limit.
    private(set) var extraSeconds: Int

    /// True while a grown-up is in Settings, so their time is not counted.
    var isPaused = false

    private var day: Int
    private let defaults = UserDefaults.standard

    init() {
        let stored = UserDefaults.standard
        limitMinutes = stored.integer(forKey: "playLimitMinutes")
        usedSeconds = stored.integer(forKey: "playUsedSeconds")
        extraSeconds = stored.integer(forKey: "playExtraSeconds")
        day = stored.integer(forKey: "playDay")
        rolloverIfNeeded()
    }

    // MARK: Read

    var isLimitOn: Bool { limitMinutes > 0 }

    var allowedSeconds: Int { limitMinutes * 60 + extraSeconds }

    var remainingSeconds: Int { max(0, allowedSeconds - usedSeconds) }

    var isTimeUp: Bool { isLimitOn && remainingSeconds == 0 }

    var usedMinutes: Int { usedSeconds / 60 }

    /// Minutes left, rounded up so "0 min left" only shows when time is really up.
    var remainingMinutes: Int { (remainingSeconds + 59) / 60 }

    // MARK: Change (called from grown-up screens only)

    func setLimit(_ minutes: Int) {
        limitMinutes = minutes
        save()
    }

    func addMinutes(_ minutes: Int) {
        extraSeconds += minutes * 60
        save()
    }

    func resetToday() {
        usedSeconds = 0
        extraSeconds = 0
        save()
    }

    // MARK: Counting

    /// Called once a second while the app is active.
    func tick() {
        rolloverIfNeeded()
        guard isLimitOn, !isPaused, !isTimeUp else { return }
        usedSeconds += 1
        if usedSeconds % 5 == 0 || isTimeUp { save() }
    }

    func save() {
        defaults.set(limitMinutes, forKey: "playLimitMinutes")
        defaults.set(usedSeconds, forKey: "playUsedSeconds")
        defaults.set(extraSeconds, forKey: "playExtraSeconds")
        defaults.set(day, forKey: "playDay")
    }

    /// A new calendar day starts with a fresh allowance.
    private func rolloverIfNeeded() {
        let today = Int(Calendar.current.startOfDay(for: .now).timeIntervalSince1970)
        if day != today {
            day = today
            usedSeconds = 0
            extraSeconds = 0
            save()
        }
    }
}
