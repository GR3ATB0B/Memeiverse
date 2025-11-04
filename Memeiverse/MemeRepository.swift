import Foundation

struct MemeRepository {
    /// Curated classics that can populate the discovery sections when network content is unavailable.
    func loadCuratedMemes(shuffled: Bool = false) -> [Meme] {
        var items: [Meme] = [
            Meme(
                id: "STONKS",
                title: "STONKS",
                caption: "Numbers go up.",
                imageURL: URL(string: "https://i.imgflip.com/3oevdk.jpg"),
                postURL: URL(string: "https://knowyourmeme.com/memes/stonks"),
                author: "Special Meme Fresh",
                tags: ["finance", "optimism"],
                upvotes: nil,
                source: .curated,
                isTrending: false,
                timestamp: Date(timeIntervalSince1970: 1561939200)
            ),
            Meme(
                id: "DOGE",
                title: "DOGE",
                caption: "Such coin. Much wow.",
                imageURL: URL(string: "https://i.imgur.com/zcG8RKy.jpg"),
                postURL: URL(string: "https://knowyourmeme.com/memes/doge"),
                author: "Kabosu",
                tags: ["dog", "crypto"],
                upvotes: nil,
                source: .curated,
                isTrending: false,
                timestamp: Date(timeIntervalSince1970: 1388534400)
            ),
            Meme(
                id: "NYAN",
                title: "Nyan Cat",
                caption: "To the stars with rainbow trails.",
                imageURL: URL(string: "https://i.imgur.com/ik5nX0m.gif"),
                postURL: URL(string: "https://knowyourmeme.com/memes/nyan-cat"),
                author: "Chris Torres",
                tags: ["cat", "gif", "retro"],
                upvotes: nil,
                source: .curated,
                isTrending: false,
                timestamp: Date(timeIntervalSince1970: 1303862400)
            ),
            Meme(
                id: "RICKROLL",
                title: "Rickroll",
                caption: "Never gonna give you up.",
                imageURL: URL(string: "https://i.imgur.com/H1toF6C.png"),
                postURL: URL(string: "https://knowyourmeme.com/memes/rickroll"),
                author: "Rick Astley",
                tags: ["music", "bait"],
                upvotes: nil,
                source: .curated,
                isTrending: false,
                timestamp: Date(timeIntervalSince1970: 1174080000)
            ),
            Meme(
                id: "DISTRACTED",
                title: "Distracted Boyfriend",
                caption: "A tale of temptation.",
                imageURL: URL(string: "https://i.imgur.com/gCq8lr3.jpg"),
                postURL: URL(string: "https://knowyourmeme.com/memes/distracted-boyfriend"),
                author: "Antonio Guillem",
                tags: ["stock photo", "relationship"],
                upvotes: nil,
                source: .curated,
                isTrending: false,
                timestamp: Date(timeIntervalSince1970: 1502755200)
            )
        ]
        if shuffled {
            items.shuffle()
        }
        return items
    }
}
