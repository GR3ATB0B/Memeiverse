import Foundation

struct Meme: Identifiable, Equatable {
    enum Source: String, Codable {
        case reddit = "meme-api.com"
        case curated = "curated"
    }

    let id: String
    let title: String
    let caption: String?
    let imageURL: URL?
    let postURL: URL?
    let author: String?
    let tags: [String]
    let upvotes: Int?
    let source: Source
    let isTrending: Bool
    let timestamp: Date?
    let lore: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        caption: String? = nil,
        imageURL: URL?,
        postURL: URL? = nil,
        author: String? = nil,
        tags: [String] = [],
        upvotes: Int? = nil,
        source: Source,
        isTrending: Bool = false,
        timestamp: Date? = nil,
        lore: String? = nil
    ) {
        self.id = id
        self.title = title
        self.caption = caption
        self.imageURL = imageURL
        self.postURL = postURL
        self.author = author
        self.tags = tags
        self.upvotes = upvotes
        self.source = source
        self.isTrending = isTrending
        self.timestamp = timestamp
        self.lore = lore
    }
}

extension Meme {
    func withTrending(_ trending: Bool) -> Meme {
        Meme(
            id: id,
            title: title,
            caption: caption,
            imageURL: imageURL,
            postURL: postURL,
            author: author,
            tags: tags,
            upvotes: upvotes,
            source: source,
            isTrending: trending,
            timestamp: timestamp,
            lore: lore
        )
    }
}

extension Meme.Source {
    var displayName: String {
        switch self {
        case .reddit:
            return "Reddit"
        case .curated:
            return "Curated Vault"
        }
    }
}
