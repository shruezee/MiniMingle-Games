//
//  ContentView.swift
//  MiniMingle Games
//
//  Created by shruthi palchandar on 30/9/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(PlayTimeManager.self) private var playTime
    @Environment(\.scenePhase) private var scenePhase

    @State private var showSplash = true

    /// Play time only counts while the app is on screen and past the splash.
    private var isCounting: Bool {
        scenePhase == .active && !showSplash
    }

    var body: some View {
        ZStack {
            HomeView()

            // Covers everything (games and menus) once today's time is used up.
            if playTime.isTimeUp && !showSplash {
                TimeUpView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: playTime.isTimeUp)
        .task(id: isCounting) {
            guard isCounting else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                playTime.tick()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { playTime.save() }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(PlayTimeManager())
}
