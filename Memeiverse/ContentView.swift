import SwiftUI
import SpriteKit
struct ContentView: View {
    @EnvironmentObject private var director: GameDirector

    private var scene: SKScene {
        director.scene
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.4),
                    Color.purple.opacity(0.6),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()
                .background(Color.clear)
                .onAppear {
                    director.boot()
                }

            VStack {
                MemeHUD(selected: $director.selectedMeme)
                    .padding()

                Spacer()

                MemeCompassView(selected: $director.selectedMeme)
                    .frame(height: 180)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameDirector(preview: true))
}
