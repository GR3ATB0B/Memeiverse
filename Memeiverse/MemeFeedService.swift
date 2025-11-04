import Foundation

struct MemeFeedService {
    private let communityAPI: CommunityMemeAPI

    init(session: URLSession = .shared) {
        self.communityAPI = CommunityMemeAPI(session: session)
    }

    func fetchTrendingMemes(limit: Int) async throws -> [Meme] {
        let limit = max(1, min(limit, 40))
        let memes = try await communityAPI.fetchMemes(limit: max(limit, 30))
        let ranked = memes.sorted { ($0.upvotes ?? 0) > ($1.upvotes ?? 0) }
        let deduped = deduplicate(ranked, maxItems: limit)
        return deduped.map { $0.withTrending(true) }
    }

    func fetchDiscoveryMemes(limit: Int) async throws -> [Meme] {
        let limit = max(1, min(limit, 60))
        let memes = try await communityAPI.fetchMemes(limit: max(limit, 40)).shuffled()
        return deduplicate(memes, maxItems: limit)
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
}

enum MemeFeedError: LocalizedError {
    case invalidResponse
    case decoding(Error)
    case communityFailed(String)
    case badStatusCode(Int)
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
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw MemeFeedError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                throw MemeFeedError.badStatusCode(http.statusCode)
            }
            return try MemeAPIDecoder.decode(data: data)
        } catch {
            if let error = error as? MemeFeedError {
                throw error
            } else {
                throw MemeFeedError.communityFailed(error.localizedDescription)
            }
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
                timestamp: nil,
                lore: nil
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
