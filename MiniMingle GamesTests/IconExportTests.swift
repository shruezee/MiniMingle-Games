//
//  IconExportTests.swift
//  MiniMingle GamesTests
//
//  Renders AppIconView and writes the 1024 x 1024 PNG straight into the
//  app's AppIcon.appiconset. Run it with Product > Test (Cmd+U) whenever
//  the icon artwork changes. The icon view is only used here and in its
//  own preview, never in the shipping UI.
//

import Testing
import SwiftUI
import UIKit
import ImageIO
import UniformTypeIdentifiers
@testable import MiniMingle_Games

struct IconExportTests {

    /// <project folder>/MiniMingle Games/Assets.xcassets/AppIcon.appiconset
    /// Found from this file's own path, so it works from any checkout.
    private static var appIconSetFolder: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // MiniMingle GamesTests
            .deletingLastPathComponent()   // project folder
            .appendingPathComponent("MiniMingle Games")
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
    }

    @MainActor
    @Test func exportAppIcon() throws {
        // 1. Render at exactly 1024 x 1024 pixels (scale 1).
        let renderer = ImageRenderer(content: AppIconView())
        renderer.scale = 1
        let rendered = try #require(renderer.uiImage, "ImageRenderer produced no image")

        // 2. Draw onto an opaque white RGB canvas (alpha byte skipped), so the
        //    PNG that ImageIO writes has no alpha channel at all.
        let pixels = Int(AppIconView.side)
        let rect = CGRect(x: 0, y: 0, width: pixels, height: pixels)
        let cgSource = try #require(rendered.cgImage, "Rendered image has no CGImage")
        let context = try #require(CGContext(
            data: nil,
            width: pixels,
            height: pixels,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(rect)
        context.draw(cgSource, in: rect)
        let flattened = try #require(context.makeImage())

        // 3. Write it into the asset catalog.
        let folder = Self.appIconSetFolder
        try #require(FileManager.default.fileExists(atPath: folder.path), "AppIcon.appiconset not found at \(folder.path)")
        let file = folder.appendingPathComponent("AppIcon-1024.png")
        let destination = try #require(CGImageDestinationCreateWithURL(file as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, flattened, nil)
        try #require(CGImageDestinationFinalize(destination), "Could not write the PNG")
        print("Saved app icon to: \(file.path)")

        // 4. Read the file back and check size and alpha.
        let source = try #require(CGImageSourceCreateWithURL(file as CFURL, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        #expect(image.width == 1024)
        #expect(image.height == 1024)
        let hasAlpha: Bool
        switch image.alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast: hasAlpha = false
        default: hasAlpha = true
        }
        #expect(!hasAlpha, "The App Store rejects icons with an alpha channel")
    }
}
