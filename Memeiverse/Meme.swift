import Foundation
import SwiftUI

struct Meme: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let title: String
    let emoji: String
    let tagline: String
    let era: String
    let color: Color
    let virality: Int   // 0-100
    let stonks: Int    // 0-100
    let chaos: Int     // 0-100
    let lore: String
    
    init(key: String, title: String, emoji: String, tagline: String, era: String, color: Color, virality: Int, stonks: Int, chaos: Int, lore: String) {
        self.key = key
        self.title = title
        self.emoji = emoji
        self.tagline = tagline
        self.era = era
        self.color = color
        self.virality = Meme.normalizeStat(virality)
        self.stonks = Meme.normalizeStat(stonks)
        self.chaos = Meme.normalizeStat(chaos)
        self.lore = lore
    }

    private static func normalizeStat(_ raw: Int) -> Int {
        return min(max(raw, 0), 100)
    }
}
