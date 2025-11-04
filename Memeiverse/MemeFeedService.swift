import Foundation

struct MemeFeedService {
    private let superMemeAPI: SuperMemeAPI
    private let communityAPI: CommunityMemeAPI

    init(
        session: URLSession = .shared,
        superMemeConfiguration: SuperMemeAPI.Configuration = .bundleDefault()
    ) {
        self.superMemeAPI = SuperMemeAPI(session: session, configuration: superMemeConfiguration)
        self.communityAPI = CommunityMemeAPI(session: session)
    }

    func fetchTrendingMemes(limit: Int) async throws -> [Meme] {
        let limit = max(1, min(limit, 40))

        async let superMeme = catchOrEmpty { try await superMemeAPI.fetchTrending(limit: max(3, limit / 2)) }
        async let reddit = communitySafeFetch(limit: limit, markTrending: true)

        let combined = (try await superMeme) + (try await reddit)
        return deduplicate(combined, maxItems: limit)
    }

    func fetchDiscoveryMemes(limit: Int) async throws -> [Meme] {
        let limit = max(1, min(limit, 60))

        async let superMeme = catchOrEmpty { try await superMemeAPI.fetchDiscover(limit: max(3, limit / 2)) }
        async let reddit = communitySafeFetch(limit: limit, markTrending: false)

        let compiled = (try await superMeme) + (try await reddit)
        return deduplicate(compiled, maxItems: limit)
    }

    private func deduplicate(_ memes: [Meme], maxItems: Int) -> [Meme] {
        var seen = Set<String>()
        var output: [Meme] = []
        for meme in memes {
            let key = meme.postURL?.absoluteString ?? meme.imageURL?.absoluteString ?? meme.id
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            output.append(meme)
            if output.count >= maxItems { break }
        }
        return output
    }

    private func communitySafeFetch(limit: Int, markTrending: Bool) async throws -> [Meme] {
        do {
            return try await communityAPI.fetchMemes(limit: limit).map { meme in
                Meme(
                    id: meme.id,
                    title: meme.title,
                    caption: meme.caption,
                    imageURL: meme.imageURL,
                    postURL: meme.postURL,
                    author: meme.author,
                    tags: meme.tags,
                    upvotes: meme.upvotes,
                    source: meme.source,
                    isTrending: markTrending ? (meme.upvotes ?? 0) > 5000 : meme.isTrending,
                    timestamp: meme.timestamp
                )
            }
        } catch {
            throw MemeFeedError.communityFailed(error.localizedDescription)
        }
    }

    private func catchOrEmpty(_ work: @escaping () async throws -> [Meme]) async -> [Meme] {
        do {
            return try await work()
        } catch {
            return []
        }
    }
}

enum MemeFeedError: LocalizedError {
    case invalidResponse
    case decoding(Error)
    case communityFailed(String)
    case badStatusCode(Int)
    case superMemeMissingKey
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The meme service returned an unexpected response."
        case .decoding(let error):
            return "Could not decode meme data: \(error.localizedDescription)"
        case .communityFailed(let message):
            return "Community meme feed failed: \(message)"
        case .badStatusCode(let code):
            return "Service responded with status code \(code)."
        case .superMemeMissingKey:
            return "Add a Supermeme API key to Info.plist under SUPERMEME_API_KEY to enable AI trending memes."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

private struct CommunityMemeAPI {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchMemes(limit: Int) async throws -> [Meme] {
        let count = max(1, min(limit, 50))
        let url = URL(string: "https://meme-api.com/gimme/\(count)")!
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw MemeFeedError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw MemeFeedError.badStatusCode(http.statusCode)
        }
        do {
            return try MemeAPIDecoder.decode(data: data)
        } catch {
            throw MemeFeedError.decoding(error)
        }
    }
}

private enum MemeAPIDecoder {
    struct SingleResponse: Decodable {
        let postLink: String
        let subreddit: String
        let title: String
        let url: String
        let author: String
        let ups: Int
        let preview: [String]?
        let nsfw: Bool?
        let spoiler: Bool?

        func toMeme() -> Meme {
            Meme(
                id: postLink,
                title: title,
                caption: subreddit.capitalized,
                imageURL: URL(string: url),
                postURL: URL(string: postLink),
                author: author,
                tags: [subreddit],
                upvotes: ups,
                source: .reddit,
                isTrending: ups > 5000,
                timestamp: nil
            )
        }
    }

    struct CollectionResponse: Decodable {
        let count: Int?
        let memes: [SingleResponse]?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.memes) {
                count = try container.decodeIfPresent(Int.self, forKey: .count)
                memes = try container.decodeIfPresent([SingleResponse].self, forKey: .memes)
            } else {
                let single = try SingleResponse(from: decoder)
                count = 1
                memes = [single]
            }
        }

        enum CodingKeys: String, CodingKey {
            case count
            case memes
        }
    }

    static func decode(data: Data) throws -> [Meme] {
        let decoder = JSONDecoder()
        let response = try decoder.decode(CollectionResponse.self, from: data)
        return response.memes?.map { $0.toMeme() } ?? []
    }
}

private struct SuperMemeAPI {
    struct Configuration {
        let baseURL: URL
        let apiKey: String?

        static func bundleDefault() -> Configuration {
            Configuration(
                baseURL: URL(string: "https://supermeme.ai/api/v1")!,
                apiKey: Bundle.main.object(forInfoDictionaryKey: "SUPERMEME_API_KEY") as? String
            )
        }
    }

    private let session: URLSession
    private let configuration: Configuration
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, configuration: Configuration) {
        self.session = session
        self.configuration = configuration
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func fetchTrending(limit: Int) async throws -> [Meme] {
        try await fetch(endpoint: .trending, limit: limit, markTrending: true)
    }

    func fetchDiscover(limit: Int) async throws -> [Meme] {
        try await fetch(endpoint: .latest, limit: limit, markTrending: false)
    }

    private func fetch(endpoint: Endpoint, limit: Int, markTrending: Bool) async throws -> [Meme] {
        guard let apiKey = configuration.apiKey, !apiKey.isEmpty else {
            throw MemeFeedError.superMemeMissingKey
        }

        var components = URLComponents(url: configuration.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(max(1, min(limit, 40)))")
        ]

        guard let url = components.url else {
            throw MemeFeedError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw MemeFeedError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw MemeFeedError.badStatusCode(http.statusCode)
        }

        do {
            let payload = try decoder.decode(SuperMemeResponse.self, from: data)
            return payload.entries.map { $0.toMeme(markTrending: markTrending) }
        } catch {
            throw MemeFeedError.decoding(error)
        }
    }

    private enum Endpoint {
        case trending
        case latest

        var path: String {
            switch self {
            case .trending:
                return "meme/trending"
            case .latest:
                return "meme/latest"
            }
        }
    }

    private struct SuperMemeResponse: Decodable {
        let entries: [Entry]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let root = try? container.decode(Root.self) {
                entries = root.data ?? root.memes ?? []
            } else if let array = try? container.decode([Entry].self) {
                entries = array
            } else {
                entries = []
            }
        }

        struct Root: Decodable {
            let data: [Entry]?
            let memes: [Entry]?
        }

        struct Entry: Decodable {
            let id: String?
            let title: String?
            let caption: String?
            let memeText: String?
            let text: String?
            let description: String?
            let imageUrl: URL?
            let image_url: URL?
            let url: URL?
            let shareUrl: URL?
            let share_url: URL?
            let tags: [String]?
            let upvotes: Int?
            let likes: Int?
            let createdAt: Date?
            let created_at: Date?
            let author: String?

            func toMeme(markTrending: Bool) -> Meme {
                let image = imageUrl ?? image_url ?? url
                let share = shareUrl ?? share_url
                let bestCaption = caption ?? memeText ?? text ?? description
                let votes = upvotes ?? likes
                return Meme(
                    id: id ?? (share?.absoluteString ?? image?.absoluteString ?? UUID().uuidString),
                    title: title ?? (bestCaption ?? "Supermeme Drop"),
                    caption: bestCaption,
                    imageURL: image,
                    postURL: share,
                    author: author,
                    tags: tags ?? [],
                    upvotes: votes,
                    source: .superMeme,
                    isTrending: markTrending,
                    timestamp: createdAt ?? created_at
                )
            }
        }
    }
}
