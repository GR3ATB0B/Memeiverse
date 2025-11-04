import Foundation
import SpriteKit

final class GameDirector: ObservableObject {
    @Published var selectedMeme: Meme? = nil
    let scene: MemeVerseScene
    private let repository = MemeRepository()
    private let isPreview: Bool

    init(preview: Bool = false) {
        self.isPreview = preview
        self.scene = MemeVerseScene(size: CGSize(width: 400, height: 800))
        self.scene.scaleMode = .resizeFill
        self.scene.backgroundColor = .clear
        self.scene.onSelect = { [weak self] meme in
            self?.selectedMeme = meme
        }
    }

    func boot() {
        let memes = repository.loadMemes(shuffled: !isPreview)
        scene.present(memes: memes)
        if selectedMeme == nil {
            selectedMeme = memes.first
        }
    }
}
