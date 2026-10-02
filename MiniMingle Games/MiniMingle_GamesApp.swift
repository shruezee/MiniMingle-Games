//
//  MiniMingle_GamesApp.swift
//  MiniMingle Games
//
//  Created by shruthi palchandar on 30/9/2026.
//

import SwiftUI

@main
struct MiniMingle_GamesApp: App {
    @State private var appState = AppState()
    @State private var playTime = PlayTimeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(playTime)
        }
    }
}
