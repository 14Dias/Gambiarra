import SpriteKit

class DestructibleBaseNode: SKSpriteNode {
    
    init(type: BaseType) {
        let texture = SKTexture(imageNamed: type.assetName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.name = "baseNode"
        self.isUserInteractionEnabled = false // Deixa a Scene gerenciar
        
        // Física estática para interações
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.zPosition = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyCut(pathPoints: [CGPoint]) {
        guard let scene = self.scene, let currentTexture = self.texture else { return }
        
        // 1. Converte pontos da Scene (Global) para o Node (Local)
        let localPoints = pathPoints.map { self.convert($0, from: scene) }
        
        // 2. Ajuste para coordenadas de textura (CoreGraphics usa Bottom-Left 0,0, SpriteKit Node usa Center 0,0)
        let texturePoints = localPoints.map { point -> CGPoint in
            return CGPoint(
                x: point.x + (self.size.width / 2),
                y: point.y + (self.size.height / 2)
            )
        }
        
        // 3. Gera nova textura cortada
        if let newTexture = TextureCutter.cutTexture(sourceTexture: currentTexture, points: texturePoints) {
            self.texture = newTexture
            
        }
    }
}
