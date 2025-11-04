import Foundation

struct Meme: Identifiable, Equatable {
    enum Source: String, Codable {
        case superMeme = "supermeme.ai"
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
        timestamp: Date? = nil
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
    }
}
