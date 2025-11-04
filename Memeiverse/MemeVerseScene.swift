import SpriteKit
import SwiftUI

final class MemeVerseScene: SKScene {
    // Layers
    private let gridLayer = SKNode()
    private let particleLayer = SKNode()
    private let memeLayer = SKNode()

    // Selection callback
    var onSelect: ((Meme) -> Void)?

    private var memeNodes: [MemeNode] = []

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .clear
        addChild(gridLayer)
        addChild(particleLayer)
        addChild(memeLayer)

        buildGrid()
        startParticles()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        gridLayer.removeAllChildren()
        buildGrid()
        layoutMemes()
    }

    func present(memes: [Meme]) {
        memeLayer.removeAllChildren()
        memeNodes = memes.map { MemeNode(meme: $0) }
        for node in memeNodes { memeLayer.addChild(node) }
        layoutMemes()
    }

    private func layoutMemes() {
        guard !memeNodes.isEmpty else { return }
        let radius = min(size.width, size.height) * 0.35
        let center = CGPoint(x: size.width/2, y: size.height/2)
        for (index, node) in memeNodes.enumerated() {
            let angle = CGFloat(index) / CGFloat(memeNodes.count) * .pi * 2
            let pos = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            node.position = pos
            node.zPosition = 10
            node.removeAllActions()
            node.run(SKAction.rotate(byAngle: 0.2, duration: 6).repeatForever())
        }
    }

    private func buildGrid() {
        let path = CGMutablePath()
        let step: CGFloat = 40
        let w = size.width
        let h = size.height
        // Vertical lines
        stride(from: 0 as CGFloat, through: w, by: step).forEach { x in
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: h))
        }
        // Horizontal lines
        stride(from: 0 as CGFloat, through: h, by: step).forEach { y in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: w, y: y))
        }
        let grid = SKShapeNode(path: path)
        grid.strokeColor = SKColor(cgColor: UIColor.systemTeal.withAlphaComponent(0.15).cgColor)
        grid.lineWidth = 1
        grid.zPosition = 0
        gridLayer.addChild(grid)
    }

    private func startParticles() {
        let spawn = SKAction.run { [weak self] in
            guard let self else { return }
            let dot = SKShapeNode(circleOfRadius: 1.5)
            dot.fillColor = .white.withAlphaComponent(0.6)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: CGFloat.random(in: 0...self.size.height))
            dot.zPosition = 5
            let drift = CGVector(dx: CGFloat.random(in: -10...10), dy: CGFloat.random(in: 20...60))
            let move = SKAction.move(by: drift, duration: TimeInterval.random(in: 2.0...4.0))
            let fade = SKAction.fadeOut(withDuration: 2.0)
            dot.run(.sequence([.group([move, fade]), .removeFromParent()]))
            self.particleLayer.addChild(dot)
        }
        let wait = SKAction.wait(forDuration: 0.12)
        run(.repeatForever(.sequence([spawn, wait])))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let nodes = nodes(at: point).compactMap { $0 as? MemeNode }
        guard let node = nodes.first else { return }
        let pulse = SKAction.sequence([
            .scale(to: 1.15, duration: 0.12),
            .scale(to: 1.0, duration: 0.18)
        ])
        node.run(pulse)
        onSelect?(node.meme)
    }
}
