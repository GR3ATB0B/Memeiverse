import Foundation
import Combine

@MainActor
final class GameDirector: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var trending: [Meme] = []
    @Published private(set) var discoveries: [Meme] = []
    @Published private(set) var curated: [Meme] = []
    @Published private(set) var state: LoadState = .idle

    private let feedService: MemeFeedService
    private let repository: MemeRepository
    private var hasBooted = false

    init(
        feedService: MemeFeedService = MemeFeedService(),
        repository: MemeRepository = MemeRepository()
    ) {
        self.feedService = feedService
        self.repository = repository
    }

    func boot() {
        guard !hasBooted else { return }
        hasBooted = true
        Task {
            await refresh()
        }
    }

    func refresh() async {
        state = .loading
        curated = repository.loadCuratedMemes(shuffled: true)
        do {
            async let trendingTask = feedService.fetchTrendingMemes(limit: 12)
            async let discoveryTask = feedService.fetchDiscoveryMemes(limit: 24)

            trending = try await trendingTask
            discoveries = try await discoveryTask

            if trending.isEmpty && discoveries.isEmpty {
                state = .failed("No live memes returned. Showing curated classics instead.")
            } else {
                state = .loaded
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .failed(message)
        }
    }
}
