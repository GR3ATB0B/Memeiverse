import SwiftUI

struct MemeHUD: View {
    @Binding var selected: Meme?
    @State private var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(now, style: .time)
                    .monospaced()
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if let meme = selected {
                    Text(meme.emoji)
                        .font(.largeTitle)
                }
            }

            if let meme = selected {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meme.title)
                        .font(.headline)
                        .foregroundStyle(meme.color)
                    Text(meme.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Text("Era: \(meme.era)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(meme.lore)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        statChip(label: "Virality", value: meme.virality, color: .pink)
                        statChip(label: "Stonks", value: meme.stonks, color: .cyan)
                        statChip(label: "Chaos", value: meme.chaos, color: .orange)
                    }
                }
            } else {
                Text("Tap a planet to inspect a meme.")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            // tick the clock
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                now = Date()
            }
        }
    }

    private func statChip(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
            ProgressView(value: Double(value), total: 100)
                .tint(color)
            Text("\(value)")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    MemeHUD(selected: .constant(MemeRepository().loadMemes(shuffled: false).first))
        .padding()
        .background(LinearGradient(colors: [.black, .purple], startPoint: .top, endPoint: .bottom))
}
