//
//  CraftScene.swift
//  PlaygroundTemplate
//
//  Created by Luca Dias on 12/02/26.
//


import SpriteKit
import SwiftUI

class CraftScene: SKScene {
    // Comunicação com SwiftUI
    var ferramentaSelecionada: ToolType = .hand
    
    // Rastreamento de gestos
    private var nodeSendoArrastado: SKNode?
    private var rastroCorte: SKShapeNode?
    private var pontosCorte: [CGPoint] = []
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = .zero // Sem gravidade (visão top-down)
        backgroundColor = UIColor(named: "TelaFundo") ?? .gray
        
        // Exemplo: Adicionar um papel base inicial
        spawnarPapelBase()
    }
    
    func spawnarPapelBase() {
        let tamanhoPapel = CGSize(width: 300, height: 400)
        let papel = SKShapeNode(rectOf: tamanhoPapel, cornerRadius: 2)
        papel.fillColor = .white
        papel.strokeColor = .lightGray
        papel.name = "cortavel"
        papel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Adiciona física para interação
        papel.physicsBody = SKPhysicsBody(rectangleOf: tamanhoPapel)
        papel.physicsBody?.isDynamic = true
        papel.physicsBody?.friction = 0.5
        papel.physicsBody?.linearDamping = 2.0 // "Arrasto" do ar para parar suavemente
        
        addChild(papel)
    }
    
    // MARK: - Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        switch ferramentaSelecionada {
        case .hand:
            // Lógica de pegar e arrastar
            if let node = touchedNodes.first(where: { $0.physicsBody != nil }) {
                nodeSendoArrastado = node
                node.physicsBody?.isDynamic = false // Desativa física temporária para arrastar
                node.run(SKAction.scale(to: 1.05, duration: 0.1)) // Feedback visual de "pegou"
            }
            
        case .scissors:
            // Inicia o rastro do corte
            pontosCorte = [location]
            criarRastroVisual()
            
        case .glue, .tape:
            // Lógica de colar (Simplificada)
            // Se tocar em um acessório que está sobre um papel, parentar ele
            tentarColar(location: location)
            
        case .clip, .button:
            // Sem ação direta nesta cena
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if ferramentaSelecionada == .hand, let node = nodeSendoArrastado {
            // Move o objeto direto (simples) ou usa força física (complexo)
            node.position = location
        } else if ferramentaSelecionada == .scissors {
            pontosCorte.append(location)
            atualizarRastroVisual()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ferramentaSelecionada == .hand, let node = nodeSendoArrastado {
            node.physicsBody?.isDynamic = true
            node.run(SKAction.scale(to: 1.0, duration: 0.1))
            nodeSendoArrastado = nil
        } else if ferramentaSelecionada == .scissors {
            processarCorte()
            rastroCorte?.removeFromParent()
            pontosCorte.removeAll()
        }
    }
    
    // MARK: - Mecânicas
    
    func tentarColar(location: CGPoint) {
        // Encontra os nós nesse ponto
        let nos = nodes(at: location).filter { $0.name != nil }
        
        // Precisa de pelo menos 2 objetos para colar
        guard nos.count >= 2 else { return }
        
        let objetoSuperior = nos[0]
        let objetoInferior = nos[1]
        
        // Verifica se já não são pai/filho
        if objetoSuperior.parent != objetoInferior {
            // Converte a posição para o sistema de coordenadas do novo pai
            let novaPosicao = objetoSuperior.scene?.convert(objetoSuperior.position, to: objetoInferior) ?? .zero
            
            objetoSuperior.removeFromParent()
            objetoInferior.addChild(objetoSuperior)
            objetoSuperior.position = novaPosicao
            
            // Feedback Visual
            let efeito = SKShapeNode(circleOfRadius: 10)
            efeito.fillColor = .yellow
            efeito.position = novaPosicao
            efeito.alpha = 0.5
            objetoInferior.addChild(efeito)
            efeito.run(.fadeOut(withDuration: 0.5))
        }
    }
    
    // MARK: - Lógica de Corte (Simplificada para Demo)
    // A implementação real de "Boolean Operations" em CGPath é complexa.
    // Aqui simulamos: se o rastro cruzar o objeto, deleta e cria dois menores.
    func processarCorte() {
        // 1. Identificar qual objeto foi cortado
        // 2. Calcular a geometria (Isso exigiria uma biblioteca de Helper geométrico no Swift)
        // Para este exemplo, vamos apenas simular um efeito:
        
        guard pontosCorte.count > 5 else { return }
        let pathDoCorte = CGMutablePath()
        pathDoCorte.addLines(between: pontosCorte)
        
        // Simulação: Se o corte cruzou um nó "cortavel", dividi-lo (Fake implementation)
        physicsWorld.enumerateBodies(alongRayStart: pontosCorte.first!, end: pontosCorte.last!) { body, point, normal, stop in
            if let node = body.node as? SKShapeNode, node.name == "cortavel" {
                // AQUI entraria a matemática complexa de dividir polígonos.
                // Sugestão de biblioteca externa: SwiftClipper ou Euclid
                print("Corte detectado em: \(node)")
                
                // Feedback visual temporário
                let spark = SKShapeNode(circleOfRadius: 5)
                spark.fillColor = .red
                spark.position = point
                self.addChild(spark)
                spark.run(.fadeOut(withDuration: 0.5))
            }
        }
    }
    
    // MARK: - Visuals
    
    func criarRastroVisual() {
        rastroCorte = SKShapeNode()
        rastroCorte?.strokeColor = .red
        rastroCorte?.lineWidth = 3
        // SpriteKit's SKShapeNode doesn't support dashed strokes; using solid line
        rastroCorte?.lineCap = .round
        if let rastro = rastroCorte { addChild(rastro) }
    }
    
    func atualizarRastroVisual() {
        let path = CGMutablePath()
        path.addLines(between: pontosCorte)
        rastroCorte?.path = path
    }
}

