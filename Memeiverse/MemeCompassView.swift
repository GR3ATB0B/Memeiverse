import SwiftUI

struct MemeCompassView: View {
    @Binding var selected: Meme?

    var body: some View {
        ZStack {
            CompassBackground()
            if let meme = selected {
                CompassIndicator(meme: meme)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct CompassBackground: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let ringWidth = size * 0.08
            ZStack {
                Circle()
                    .strokeBorder(AngularGradient(gradient: Gradient(colors: [.green, .cyan, .purple, .pink, .orange, .green]), center: .center), lineWidth: ringWidth)
                // Quadrant labels
                VStack {
                    label("Bullish", system: "chart.line.uptrend.xyaxis")
                    Spacer()
                    label("Wholesome", system: "heart")
                }
                HStack {
                    label("Viral", system: "bolt")
                    Spacer()
                    label("Chaotic", system: "tornado")
                }
            }
            .padding(ringWidth / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func label(_ text: String, system: String) -> some View {
        Label(text, systemImage: system)
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.8))
    }
}

private struct CompassIndicator: View {
    let meme: Meme
    @State private var position: CGPoint = .zero

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size * 0.38
            let target = computeVector(in: radius)
            Circle()
                .fill(meme.color)
                .frame(width: 28, height: 28)
                .overlay(Text(meme.emoji).font(.footnote))
                .position(x: size / 2 + target.x, y: size / 2 - target.y)
                .animation(.easeOut(duration: 0.35), value: target)
        }
    }

    private func computeVector(in radius: CGFloat) -> CGPoint {
        // Normalize stats from 0...100 to -1...1
        let v = (CGFloat(meme.virality) / 50 - 1) // Viral: 0->-1, 50->0, 100->1
        let s = (CGFloat(meme.stonks) / 50 - 1)   // Stonks: 0->-1, 50->0, 100->1
        let c = (CGFloat(meme.chaos) / 50 - 1)   // Chaos: 0->-1, 50->0, 100->1

        // Weighted vector:
        // X axis: viral (positive) minus chaotic weighted negative
        // Y axis: bullish/stonk positive minus wholesome negative but influenced by chaos
        let x = v - 0.6 * c
        let y = s - 0.2 * (1 - c)

        // Compute magnitude then clamp between min and max to avoid center clustering and overshoot
        let mag = max(0.2, min(1.0, sqrt(x * x + y * y)))

        // Normalize vector and scale by magnitude and radius
        let nx = x / max(0.001, mag)
        let ny = y / max(0.001, mag)

        return CGPoint(x: nx * radius * mag, y: ny * radius * mag)
    }
}

#Preview {
    MemeCompassView(selected: .constant(MemeRepository().loadMemes(shuffled: false).first))
        .frame(width: 220, height: 220)
        .padding()
        .background(LinearGradient(colors: [.black, .blue], startPoint: .top, endPoint: .bottom))
}
