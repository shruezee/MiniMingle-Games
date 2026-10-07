# 🎮 MiniMingle Games

**Five classic games, six cartoon heroes, and loads of fun — made just for kids.**

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS-lightgrey?style=flat-square">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-SwiftUI-orange?style=flat-square">
  <img alt="Ages" src="https://img.shields.io/badge/made%20for-ages%206–8-ff5fa2?style=flat-square">
  <img alt="Privacy" src="https://img.shields.io/badge/data%20collected-none-brightgreen?style=flat-square">
</p>

<p align="center">
  🌐 <a href="https://shruezee.github.io/MiniMingle-Games/">Website</a> · 🔒 <a href="https://shruezee.github.io/MiniMingle-Games/privacy.html">Privacy policy</a> · 🧪 Status: submitted to the App Store (in review)
</p>

## What is MiniMingle Games?

MiniMingle Games is a bright, bouncy SwiftUI app that brings five favorite board and paper games to life for kids. A player picks a game, picks a cartoon hero to represent them, and picks an opponent — a friendly computer, or a friend passing the same device back and forth.

There's nothing else to it: no sign-up, no ads, no in-app purchases, no internet connection, and no data collected. Just open the app and play. Grown-ups get a daily play timer and a parental gate guarding Settings, so the app is as easy to hand to a kid as it is to play yourself.

<p align="center">
  <img src="AppStore/screenshots/iphone-6.5/01-home.png" width="260" alt="MiniMingle Games home screen: choose a game, choose your hero, choose who plays" />
</p>
<p align="center"><em>Choose a game, choose your hero, choose who plays — then tap "Let's Play!"</em></p>

## 🕹️ Five games, six heroes

Every game is played with one of six heroes — **Volt Vanguard, Aurora Blaze, Tidecaller, Iron Oak, Shadow Lynx,** and **Skybolt** — each with their own color and emblem, which becomes their game piece on the board.

<table>
<tr>
<td align="center" width="50%">
  <img src="AppStore/screenshots/iphone-6.5/02-connect4.png" width="240" alt="Connect 4 gameplay" /><br>
  <b>Connect 4</b><br>Drop discs and connect four in a row.
</td>
<td align="center" width="50%">
  <img src="AppStore/screenshots/iphone-6.5/03-memory.png" width="240" alt="Memory Match gameplay" /><br>
  <b>Memory Match</b><br>Flip cards and find the matching heroes.
</td>
</tr>
<tr>
<td align="center" width="50%">
  <img src="AppStore/screenshots/iphone-6.5/04-tictactoe.png" width="240" alt="Tic-Tac-Toe gameplay" /><br>
  <b>Tic-Tac-Toe</b><br>Get three hero pieces in a row to win.
</td>
<td align="center" width="50%">
  <img src="AppStore/screenshots/iphone-6.5/05-dots.png" width="240" alt="Dots & Boxes gameplay" /><br>
  <b>Dots & Boxes</b><br>Draw lines and close the most boxes.
</td>
</tr>
</table>

Plus **Bingo** — call numbers and fill a line first.

## 📱 Also works beautifully on iPad

<p align="center">
  <img src="AppStore/screenshots/ipad/01-home.png" width="360" alt="iPad home screen" />
  <img src="AppStore/screenshots/ipad/02-connect4.png" width="360" alt="iPad Connect 4" />
</p>

## ✨ Features

- **5 games to play** — Tic-Tac-Toe, Connect 4, Dots & Boxes, Bingo, and Memory Match
- **6 cartoon heroes** — Volt Vanguard, Aurora Blaze, Tidecaller, Iron Oak, Shadow Lynx, and Skybolt
- **Play your way** — against the computer, or pass-and-play with a friend on the same device
- **Leaderboard** — track wins across games and heroes
- **Made for families** — a daily play timer lets grown-ups set how long kids play, and a parental gate protects Settings
- **Universal** — works on iPhone and iPad, in portrait and landscape
- **Offline & private** — no internet needed, no ads, no in-app purchases, no accounts, and no data ever leaves the device

## 🛠️ Tech stack

- **SwiftUI** for the entire UI, with `async`/`await` instead of Combine
- **UserDefaults** for all local persistence (scores, settings, play timer) — nothing is sent off-device
- Targets iOS 17+, built with Xcode

### Project structure

```
MiniMingle Games/
├── Games/                  Game boards & logic (Tic-Tac-Toe, Connect 4, Dots & Boxes, Bingo, Memory Match)
├── HomeView.swift          Game, hero, and opponent picker
├── ContentView.swift       Root navigation
├── AppState.swift          Shared app state
├── PlayTimeManager.swift   Daily play timer for parents
├── ParentalGateView.swift  Parental gate for Settings
├── LeaderboardView.swift   Win tracking
├── SettingsView.swift      Sounds, vibration, play timer settings
└── SplashView.swift        Launch screen
```

## 🚀 Getting started

1. Open `MiniMingle Games.xcodeproj` in Xcode
2. Select a simulator or device
3. Build & run (⌘R)

## 🔒 Privacy

MiniMingle Games collects no data. Everything — scores, settings, and preferences — stays on the device. See the [privacy policy](https://shruezee.github.io/MiniMingle-Games/privacy.html) for details.

## 📄 License

Copyright © 2026 Shruezee Studio. All rights reserved.
