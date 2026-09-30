//
//  Item.swift
//  MiniMingle Games
//
//  Created by shruthi palchandar on 30/9/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
