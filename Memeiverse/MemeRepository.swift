import Foundation
import SwiftUI

struct MemeRepository {
    func loadMemes(shuffled: Bool) -> [Meme] {
        var items: [Meme] = [
            Meme(key: "STONKS", title: "STONKS", emoji: "📈", tagline: "Numbers go up.", era: "2019", color: .cyan, virality: 72, stonks: 95, chaos: 38, lore: "The classic finance meme embodying irrational optimism. The line only goes up... until it doesn't."),
            Meme(key: "DOGE", title: "DOGE", emoji: "🐶", tagline: "Such coin. Much wow.", era: "2013", color: .orange, virality: 88, stonks: 65, chaos: 42, lore: "Shiba-powered internet culture that accidentally became a currency."),
            Meme(key: "PEPE", title: "PEPE", emoji: "🐸", tagline: "Feels good man.", era: "2005", color: .green, virality: 79, stonks: 58, chaos: 66, lore: "An enduring frog with many moods; cultural impact varies by context."),
            Meme(key: "NYAN", title: "NYAN CAT", emoji: "🐱", tagline: "To the stars with rainbow trails.", era: "2011", color: .pink, virality: 83, stonks: 40, chaos: 55, lore: "A pastry cat soaring through space, powered by chiptunes."),
            Meme(key: "RICK", title: "RICKROLL", emoji: "🎵", tagline: "Never gonna give you up.", era: "2007", color: .purple, virality: 91, stonks: 20, chaos: 35, lore: "A bait-and-switch legend that still catches the unwary."),
        ]
        if shuffled { items.shuffle() }
        return items
    }
}
