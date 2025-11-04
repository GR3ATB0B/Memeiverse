import SwiftUI

struct MemeDetailView: View {
    let meme: Meme
    @Environment(\.dismiss) private var dismiss

    private var formattedDate: String? {
        guard let timestamp = meme.timestamp else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AsyncImage(url: meme.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white.opacity(0.08))
                                ProgressView().tint(.white)
                            }
                        case .failure:
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.white.opacity(0.08))
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "icloud.slash")
                                            .font(.largeTitle)
                                        Text("Could not load image.")
                                            .font(.subheadline)
                                    }
                                    .foregroundStyle(.white.opacity(0.7))
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                        @unknown default:
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.white.opacity(0.08))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(meme.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            if meme.isTrending {
                                Label("Trending", systemImage: "flame.fill")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.orange.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }

                        if let caption = meme.caption {
                            Text(caption)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                        }

                        if let formattedDate {
                            Label(formattedDate, systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        HStack(spacing: 12) {
                            Label(meme.source.rawValue, systemImage: "globe")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))

                            if let author = meme.author, !author.isEmpty {
                                Label(author, systemImage: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }

                            if let upvotes = meme.upvotes {
                                Label("\(upvotes)", systemImage: "hand.thumbsup.fill")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }

                        if !meme.tags.isEmpty {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 80), spacing: 8)],
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(meme.tags, id: \.self) { tag in
                                    Text("#\(tag.lowercased())")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(.white.opacity(0.08))
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        if let postURL = meme.postURL {
                            VStack(alignment: .leading, spacing: 8) {
                                Link(destination: postURL) {
                                    Label("Open original post", systemImage: "arrow.up.right.square")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(.white.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                if #available(iOS 16.0, macOS 13.0, *) {
                                    ShareLink(item: postURL) {
                                        Label("Share meme", systemImage: "square.and.arrow.up")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.85))
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.purple.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    MemeDetailView(
        meme: Meme(
            id: "preview",
            title: "Doge",
            caption: "Such code. Much wow.",
            imageURL: URL(string: "https://i.imgur.com/zcG8RKy.jpg"),
            postURL: URL(string: "https://knowyourmeme.com/memes/doge"),
            author: "Kabosu",
            tags: ["doge", "crypto"],
            upvotes: 999_999,
            source: .curated,
            isTrending: true,
            timestamp: Date()
        )
    )
}
