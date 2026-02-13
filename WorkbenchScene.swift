import SpriteKit
import SwiftUI

class WorkbenchScene: SKScene {
    
    // MARK: - Estado Externo
    var selectedTool: ToolType = .hand
    var baseType: BaseType = .papel
    
    // MARK: - Nodes
    private var baseNode: DestructibleBaseNode?
    private var cameraNode: SKCameraNode!
    
    // MARK: - Variáveis de Interação
    private var activeNode: SKNode? // Nó sendo arrastado
    private var dragOffset: CGPoint = .zero // Distância entre o toque e o centro do objeto
    
    private var cutPathPoints: [CGPoint] = []
    private var visualCutLine: SKShapeNode?
    private var guideNode: SKShapeNode? // Referência para a guia
    
    // MARK: - Ciclo de Vida
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "TelaFundo") ?? .gray
        physicsWorld.gravity = .zero // Visão Top-Down
        
        setupCamera()
        spawnBase(type: baseType)
        // setupGuides() é chamado dentro do spawnBase agora para garantir ordem
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    private func spawnBase(type: BaseType) {
        baseNode?.removeFromParent()
        let newBase = DestructibleBaseNode(type: type)
        newBase.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Escala inicial
        if newBase.size.width > frame.width * 0.8 {
            newBase.setScale(0.7)
        }
        
        addChild(newBase)
        baseNode = newBase
        
        // Adiciona a guia DIRETAMENTE ao objeto base
        addGuideToBase(newBase)
    }
    
    private func addGuideToBase(_ base: SKNode) {
        // Remove guia anterior se existir
        guideNode?.removeFromParent()
        
        // Cria o caminho RELATIVO ao centro do objeto (0,0)
        let path = CGMutablePath()
        
        // Exemplo: Uma linha tracejada horizontal levemente curvada
        // Como é relativo ao pai, (0,0) é o centro do papel
        path.move(to: CGPoint(x: -150, y: 0))
        path.addQuadCurve(to: CGPoint(x: 150, y: 0), control: CGPoint(x: 0, y: 50))
        
        // Cria um caminho tracejado usando Core Graphics
        let dashedPath = path.copy(dashingWithPhase: 0, lengths: [15, 10], transform: .identity)
        let shape = SKShapeNode(path: dashedPath)
        shape.strokeColor = .white.withAlphaComponent(0.8)
        shape.lineWidth = 4
        shape.name = "guide"
        shape.zPosition = 10 // Garante que fique acima da textura do papel
        
        // Efeito de "Pulsar" para chamar atenção
        shape.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.3, duration: 1.0),
            .fadeAlpha(to: 0.9, duration: 1.0)
        ])))
        
        base.addChild(shape)
        guideNode = shape
    }
    
    // MARK: - Manipulação de Toque (Touch Handling)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Filtra nós relevantes (Base ou Itens) ignorando guias ou efeitos
        let touchedNodes = nodes(at: location).filter { $0.name == "craftItem" || $0.name == "baseNode" }
        // Pega o nó com maior zPosition (o que está "em cima")
        let topNode = touchedNodes.max(by: { $0.zPosition < $1.zPosition })
        
        switch selectedTool {
        case .hand:
            if let node = topNode {
                activeNode = node
                // Calcula o offset para o movimento ser suave (não pular para o centro do dedo)
                dragOffset = CGPoint(x: node.position.x - location.x, y: node.position.y - location.y)
                
                node.removeAllActions()
                node.run(.scale(to: node.xScale * 1.05, duration: 0.1)) // Feedback visual
            }
            
        case .scissors:
            cutPathPoints = [location]
            createVisualCutTrail()
            
        case .glue, .tape:
            attemptToStick(at: location, tool: selectedTool)
            
        case .clip, .button:
            spawnItem(at: location, type: selectedTool)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        switch selectedTool {
        case .hand:
            if let node = activeNode {
                // Aplica a posição somando o offset original
                node.position = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
            }
            
        case .scissors:
            cutPathPoints.append(location)
            updateVisualCutTrail()
            
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch selectedTool {
        case .hand:
            if let node = activeNode {
                node.run(.scale(to: node.xScale / 1.05, duration: 0.1))
                activeNode = nil
            }
            
        case .scissors:
            finishCut()
            
        default:
            break
        }
    }
    
    // MARK: - Lógicas Específicas
    
    private func createVisualCutTrail() {
        visualCutLine = SKShapeNode()
        visualCutLine?.strokeColor = .red
        visualCutLine?.lineWidth = 5
        visualCutLine?.lineCap = .round
        visualCutLine?.zPosition = 100 // Sempre no topo
        if let line = visualCutLine { addChild(line) }
    }
    
    private func updateVisualCutTrail() {
        let path = CGMutablePath()
        guard !cutPathPoints.isEmpty else { return }
        path.move(to: cutPathPoints[0])
        for point in cutPathPoints.dropFirst() {
            path.addLine(to: point)
        }
        visualCutLine?.path = path
    }
    
    private func finishCut() {
        visualCutLine?.removeFromParent()
        visualCutLine = nil
        
        // Verifica bounding box
        guard let base = baseNode, base.frame.intersects(calcBoundingBox(of: cutPathPoints)) else {
            cutPathPoints.removeAll()
            return
        }
        
        // Executa corte
        base.applyCut(pathPoints: cutPathPoints)
        
        // Opcional: Remover a guia se o usuário cortar perto dela
        // Para simplificar, removemos a guia no primeiro corte bem sucedido
        if let guide = guideNode {
            guide.run(.sequence([
                .fadeOut(withDuration: 0.5),
                .removeFromParent()
            ]))
            guideNode = nil
        }
        
        cutPathPoints.removeAll()
    }
    
    private func spawnItem(at position: CGPoint, type: ToolType) {
        let imageName = (type == .button) ? "Botao" : "Clips"
        let item = SKSpriteNode(imageNamed: imageName)
        item.position = position
        item.name = "craftItem"
        item.zPosition = 10
        item.setScale(0.5)
        
        // Física
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.width/2)
        item.physicsBody?.isDynamic = true
        item.physicsBody?.categoryBitMask = 2
        
        addChild(item)
        
        // Animação Pop
        item.setScale(0.1)
        item.run(.sequence([
            .scale(to: 0.6, duration: 0.15),
            .scale(to: 0.5, duration: 0.1)
        ]))
    }
    
    private func attemptToStick(at location: CGPoint, tool: ToolType) {
        // Pega todos os nós no ponto
        let nodesAtPoint = nodes(at: location)
        
        // Busca Item e Base
        guard let item = nodesAtPoint.first(where: { $0.name == "craftItem" }),
              let base = nodesAtPoint.first(where: { $0.name == "baseNode" }) else {
            return
        }
        
        // Se o item já é filho da base, não precisa colar de novo
        if item.parent == base { return }
        
        // Converter posição Global -> Local da Base
        let localPos = base.convert(item.position, from: self)
        
        // Trocar de PAI
        item.removeFromParent()
        base.addChild(item)
        item.position = localPos
        
        // Feedback Visual (Adesivo)
        let sticker = SKSpriteNode(imageNamed: (tool == .glue) ? "Cola" : "Fita")
        sticker.setScale(0.3)
        sticker.position = localPos
        sticker.zPosition = item.zPosition + 1
        sticker.zRotation = CGFloat.random(in: -0.5...0.5)
        base.addChild(sticker)
        
        // Feedback de Ação
        let scaleUp = SKAction.scale(to: item.xScale * 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: item.xScale, duration: 0.1)
        item.run(.sequence([scaleUp, scaleDown]))
    }
    
    private func calcBoundingBox(of points: [CGPoint]) -> CGRect {
        guard !points.isEmpty else { return .zero }
        var minX = points[0].x, maxX = points[0].x
        var minY = points[0].y, maxY = points[0].y
        
        for p in points {
            minX = min(minX, p.x); maxX = max(maxX, p.x)
            minY = min(minY, p.y); maxY = max(maxY, p.y)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
