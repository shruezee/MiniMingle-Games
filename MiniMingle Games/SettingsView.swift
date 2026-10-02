//
//  SettingsView.swift
//  MiniMingle Games
//
//  Grown-ups area. It is only reachable through the parental gate.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var app
    @Environment(PlayTimeManager.self) private var playTime
    @Environment(\.dismiss) private var dismiss

    @AppStorage(Feedback.soundKey) private var soundOn = true
    @AppStorage(Feedback.hapticsKey) private var hapticsOn = true
    @State private var confirmClear = false
    @State private var showBreakPreview = false

    var body: some View {
        ZStack {
            CartoonBackground()

            // Scrolls so nothing is cut off in landscape or at large text sizes.
            ScrollView {
                VStack(spacing: 18) {
                    Text("Settings")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.pink)
                        .padding(.top, 24)

                    VStack(spacing: 0) {
                        Toggle("🔊  Sound effects", isOn: $soundOn)
                            .padding(16)
                        Divider().padding(.horizontal)
                        Toggle("📳  Vibration", isOn: $hapticsOn)
                            .padding(16)
                    }
                    .font(Theme.font(.headline))
                    .foregroundStyle(Theme.ink)
                    .tint(Theme.mintDark)
                    .cartoonCard()

                    timerCard

                    Button("Clear leaderboard") { confirmClear = true }
                        .buttonStyle(CartoonButtonStyle(fill: .white, edge: Theme.lavenderEdge, foreground: Theme.pinkDark))
                        .disabled(app.scores.isEmpty)
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
        .confirmationDialog("Clear all saved scores?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Clear scores", role: .destructive) { app.clearScores() }
        }
        .fullScreenCover(isPresented: $showBreakPreview) {
            TimeUpView(isPreview: true, onClose: { showBreakPreview = false })
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: Daily play timer

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⏱ Daily play timer")
                .font(Theme.font(.headline))
                .foregroundStyle(Theme.ink)

            Text("Choose how long your child can play each day. When time runs out, a break screen appears until a grown-up adds more.")
                .font(Theme.font(.footnote, weight: .medium))
                .foregroundStyle(Theme.inkSoft)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
                ForEach(PlayTimeManager.limitChoices, id: \.self) { minutes in
                    let selected = minutes == playTime.limitMinutes
                    Button {
                        playTime.setLimit(minutes)
                    } label: {
                        Text(minutes == 0 ? "Off" : "\(minutes) min")
                            .font(Theme.font(.subheadline))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(CartoonTileStyle(
                        fill: selected ? Theme.mint : .white,
                        edge: selected ? Theme.mintDark : Theme.lavenderEdge
                    ))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }

            Text(summary)
                .font(Theme.font(.subheadline, weight: .medium))
                .foregroundStyle(Theme.ink)

            HStack(spacing: 10) {
                Button("Preview break screen") { showBreakPreview = true }
                    .buttonStyle(CartoonButtonStyle(fill: Theme.lavender, edge: Theme.lavenderDark, foreground: Theme.ink))
                Button("Reset today") { playTime.resetToday() }
                    .buttonStyle(CartoonButtonStyle(fill: .white, edge: Theme.lavenderEdge, foreground: Theme.ink))
                    .disabled(!playTime.isLimitOn)
            }
            .font(Theme.font(.subheadline))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cartoonCard()
    }

    private var summary: String {
        guard playTime.isLimitOn else {
            return "No limit set. Your child can play as long as they like."
        }
        return "Played today: \(playTime.usedMinutes) min. Left: \(playTime.remainingMinutes) min."
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .environment(PlayTimeManager())
}
