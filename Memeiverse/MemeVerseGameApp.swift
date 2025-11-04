import SwiftUI

@main
struct MemeVerseGameApp: App {
    @StateObject private var director = GameDirector()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(director)
        }
    }
}
