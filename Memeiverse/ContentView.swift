import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var director: GameDirector
    @State private var selectedMeme: Meme?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.25),
                        Color.purple.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

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
            Text("Tap a legend to unfold its story.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(director.curated) { meme in
                        Button {
                            selectedMeme = meme
                        } label: {
                            MemeLoreBadge(meme: meme)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .frame(height: 190)
                .overlay {
                    if let assetName = meme.assetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        AsyncImage(url: meme.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .tint(.white)
                            case .failure:
                                Image(systemName: "xmark.octagon")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.7))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            @unknown default:
                                Color.black.opacity(0.4)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .topLeading) {
                    if meme.isTrending {
                        Text("🔥 trending")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.55))
                            .clipShape(Capsule())
                            .padding(12)
                    }
                }

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
                    Label(meme.source.displayName, systemImage: "link")
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
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(width: 300)
    }
}

private struct MemeTile: View {
    let meme: Meme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .aspectRatio(4.0 / 5.0, contentMode: .fit)
                .overlay {
                    if let assetName = meme.assetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        AsyncImage(url: meme.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().tint(.white)
                            case .failure:
                                Image(systemName: "icloud.slash")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.6))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            @unknown default:
                                Color.white.opacity(0.08)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

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
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct MemeLoreBadge: View {
    let meme: Meme

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.purple.opacity(0.6),
                                Color.cyan.opacity(0.6),
                                Color.pink.opacity(0.6)
                            ],
                            center: .center
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                    }

                if let assetName = meme.assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(6)
                } else {
                    AsyncImage(url: meme.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.white)
                        case .failure:
                            Image(systemName: "sparkles")
                                .foregroundStyle(.white.opacity(0.8))
                                .font(.system(size: 28))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        @unknown default:
                            Color.black.opacity(0.4)
                        }
                    }
                    .clipShape(Circle())
                    .padding(6)
                }
            }
            .frame(width: 96, height: 96)

            Text(meme.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            if let caption = meme.caption {
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(14)
        .frame(width: 140)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    ContentView()
        .environmentObject(
            GameDirector(
                feedService: MemeFeedService(),
                repository: MemeRepository()
            )
        )
}
