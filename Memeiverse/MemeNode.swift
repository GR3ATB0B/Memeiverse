import SpriteKit
import SwiftUI

final class MemeNode: SKNode {
    let meme: Meme

    init(meme: Meme) {
        self.meme = meme
        super.init()
        build()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        let glow = SKShapeNode(circleOfRadius: 52)
        glow.fillColor = UIColor(meme.color).withAlphaComponent(0.25)
        glow.strokeColor = .clear
        glow.zPosition = 0
        glow.setScale(1.0)
        addChild(glow)

        let badge = SKShapeNode(circleOfRadius: 36)
        badge.fillColor = UIColor(meme.color).withAlphaComponent(0.9)
        badge.strokeColor = .white.withAlphaComponent(0.2)
        badge.lineWidth = 2
        badge.zPosition = 1
        addChild(badge)

        let emojiLabel = SKLabelNode(text: meme.emoji)
        emojiLabel.fontSize = 28
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.horizontalAlignmentMode = .center
        emojiLabel.zPosition = 2
        addChild(emojiLabel)

        let title = SKLabelNode(text: meme.title.uppercased())
        title.fontName = "Menlo-Bold"
        title.fontSize = 10
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: -54)
        title.zPosition = 3
        addChild(title)

        let tagline = SKLabelNode(text: meme.tagline)
        tagline.fontName = "Menlo"
        tagline.fontSize = 8
        tagline.fontColor = .white.withAlphaComponent(0.8)
        tagline.position = CGPoint(x: 0, y: -68)
        tagline.zPosition = 3
        addChild(tagline)

        let slowRotate = SKAction.rotate(byAngle: 0.1, duration: 8)
        run(.repeatForever(slowRotate))
    }
}
