//
//  TimeUpView.swift
//  MiniMingle Games
//
//  Full-screen "time for a break" screen shown when the daily play limit that
//  a parent set has run out. Only a grown-up (through the parental gate) can
//  add more time. The same screen can be previewed from Settings.
//

import SwiftUI

struct TimeUpView: View {
    /// True when a parent is previewing the screen from Settings.
    var isPreview = false
    var onClose: () -> Void = {}

    @Environment(PlayTimeManager.self) private var playTime
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showGate = false
    @State private var passedGate = false
    @State private var showOptions = false
    @State private var bob = false

    var body: some View {
        ZStack {
            CartoonBackground()

            VStack(spacing: 20) {
                if isPreview {
                    Text("PREVIEW")
                        .font(Theme.font(.caption))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Theme.yellow))
                }

                Spacer(minLength: 0)

                Text("😴")
                    .font(.system(size: 110))
                    .offset(y: bob ? -10 : 10)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.3).repeatForever(autoreverses: true),
                        value: bob
                    )
                    .accessibilityHidden(true)

                Text("Time for a break!")
                    .font(Theme.largeTitle)
                    .foregroundStyle(Theme.pink)
                    .multilineTextAlignment(.center)

                Text("You have played all of today's time.\nSee you tomorrow! 👋")
                    .font(Theme.font(.title3, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)

                Button(isPreview ? "Close preview" : "Grown-up: add time") {
                    if isPreview { onClose() } else { showGate = true }
                }
                .buttonStyle(CartoonButtonStyle(
                    fill: isPreview ? Theme.pink : .white,
                    edge: isPreview ? Theme.pinkDark : Theme.lavenderEdge,
                    foreground: isPreview ? .white : Theme.ink
                ))
                .padding(.bottom, 12)
            }
            .padding(24)
            .frame(maxWidth: 560)
        }
        .onAppear { bob = true }
        // The gate must close before the choices appear.
        .sheet(isPresented: $showGate, onDismiss: {
            if passedGate {
                passedGate = false
                showOptions = true
            }
        }) {
            ParentalGateView(onPass: { passedGate = true })
        }
        .confirmationDialog("Give more play time?", isPresented: $showOptions, titleVisibility: .visible) {
            Button("Add 10 minutes") { playTime.addMinutes(10) }
            Button("Add 30 minutes") { playTime.addMinutes(30) }
            Button("Turn the timer off") { playTime.setLimit(0) }
            Button("Not now", role: .cancel) {}
        }
    }
}

#Preview("Time's up") {
    TimeUpView(isPreview: true)
        .environment(PlayTimeManager())
}
