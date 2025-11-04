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
                timestamp: Date(timeIntervalSince1970: 1561939200),
                lore: "A boilerplate stock trader turned surreal hero, STONKS embodies internet-era financial optimism. The meme fueled countless jokes about game-stopping trades, stimulus checks, and meme-stock frenzies."
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
                timestamp: Date(timeIntervalSince1970: 1388534400),
                lore: "From a Shiba Inu side-eye photo to the face of meme coins, Doge taught the web how wholesome chaos can move markets. Its Comic Sans barks inspired a decade of 'much wow' remixes and cryptocurrency parodies."
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
                timestamp: Date(timeIntervalSince1970: 1303862400),
                lore: "Pixel pastry cat streaking through space became an anthem for early viral loops. Nyan Cat’s chiptune soundtrack and endless rainbow trail helped define the looping GIF era."
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
                timestamp: Date(timeIntervalSince1970: 1174080000),
                lore: "Every suspicious link could be a Rickroll. The internet’s longest-running bait-and-switch keeps Rick Astley’s 1987 bop in perpetual rotation and remains the go-to prank in meme culture."
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
                timestamp: Date(timeIntervalSince1970: 1502755200),
                lore: "This stock photo became a universal template for temptation and shifting loyalties. Brands, politics, and fandoms all used the wandering boyfriend to dramatize every flavor of betrayal."
            )
        ]
        if shuffled {
            items.shuffle()
        }
        return items
    }
}
