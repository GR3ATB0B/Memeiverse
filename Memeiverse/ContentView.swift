import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var director: GameDirector
    @State private var selectedMeme: Meme?

    private let gradient = LinearGradient(
        colors: [
            Color.cyan.opacity(0.35),
            Color.purple.opacity(0.55),
            Color.black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationStack {
            ZStack {
                gradient.ignoresSafeArea()
                content
            }
            .navigationTitle("Memeiverse")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await director.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            director.boot()
        }
        .sheet(item: $selectedMeme) { meme in
            MemeDetailView(meme: meme)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch director.state {
        case .idle, .loading:
            ProgressView("Scanning the meme-verse…")
                .progressViewStyle(.circular)
                .padding()
        case .failed(let message):
            ScrollView {
                VStack(spacing: 32) {
                    failureView(message: message)
                    curatedSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            .refreshable {
                await director.refresh()
            }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if !director.trending.isEmpty {
                        trendingSection
                    }
                    if !director.discoveries.isEmpty {
                        discoverySection
                    }
                    curatedSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 36)
            }
            .refreshable {
                await director.refresh()
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Trending right now", symbol: "flame.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(director.trending) { meme in
                        Button {
                            selectedMeme = meme
                        } label: {
                            MemeHeroCard(meme: meme)
                                .frame(width: 320)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var discoverySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Fresh discoveries", symbol: "sparkles")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(director.discoveries) { meme in
                    Button {
                        selectedMeme = meme
                    } label: {
                        MemeTile(meme: meme)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var curatedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Classic lore vault", symbol: "books.vertical")
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(director.curated) { meme in
                    Button {
                        selectedMeme = meme
                    } label: {
                        MemeListRow(meme: meme)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.9))
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
            Button {
                Task { await director.refresh() }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct MemeHeroCard: View {
    let meme: Meme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: meme.imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.black.opacity(0.3)
                        ProgressView()
                            .tint(.white)
                    }
                case .failure:
                    ZStack {
                        Color.black.opacity(0.4)
                        Image(systemName: "xmark.octagon")
                            .foregroundColor(.white.opacity(0.7))
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                @unknown default:
                    Color.black.opacity(0.4)
                }
            }
            .frame(height: 180)
            .clipped()
            .overlay(alignment: .topLeading) {
                if meme.isTrending {
                    Text("🔥 trending")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 6) {
                Text(meme.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                if let caption = meme.caption {
                    Text(caption)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    Label(meme.source.rawValue, systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    if let upvotes = meme.upvotes {
                        Label("\(upvotes)", systemImage: "hand.thumbsup.fill")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct MemeTile: View {
    let meme: Meme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: meme.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                        .overlay { ProgressView().tint(.white) }
                case .failure:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                        .overlay {
                            Image(systemName: "icloud.slash")
                                .foregroundStyle(.white.opacity(0.6))
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                @unknown default:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                }
            }
            .frame(height: 160)

            Text(meme.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
            if let caption = meme.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct MemeListRow: View {
    let meme: Meme

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: meme.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay { ProgressView().tint(.white) }
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.white.opacity(0.6))
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                @unknown default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                }
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(meme.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                if let caption = meme.caption {
                    Text(caption)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    if let author = meme.author {
                        Label(author, systemImage: "person")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Label(meme.source.rawValue, systemImage: "globe")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(16)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ContentView()
        .environmentObject(
            GameDirector(
                feedService: MemeFeedService(superMemeConfiguration: .init(baseURL: URL(string: "https://supermeme.ai/api/v1")!, apiKey: nil)),
                repository: MemeRepository()
            )
        )
}
