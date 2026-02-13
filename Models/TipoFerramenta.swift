import Foundation
import SwiftUI
import CoreGraphics

// MARK: - Enums e Estruturas de Dados

enum ToolType: String, CaseIterable, Identifiable {
    case hand = "hand.point.up.left.fill" // Mover e Ajustar
    case scissors = "scissors"            // Cortar
    case glue = "drop.fill"               // Colar (Fixação Leve)
    case tape = "bandage.fill"            // Fita (Fixação Forte)
    case clip = "paperclip"               // Adicionar Clips
    case button = "circle.grid.hex.fill"  // Adicionar Botões
    
    var id: String { rawValue }
}

enum BaseType: String, CaseIterable {
    case papel = "Papel"
    case rolo = "Rolo de Papelão"
    
    var assetName: String {
        switch self {
        case .papel: return "Papel" // Certifique-se que existe no Assets
        case .rolo: return "PapelaoUnico" // Certifique-se que existe no Assets
        }
    }
}
// MARK: - Serialização (Save System)

struct CGPointCodable: Codable {
    let x: CGFloat
    let y: CGFloat
    
    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

final class CraftProject: Codable {
    var baseType: String
    var items: [ItemState]
    var cutHistory: [CutPathState]
    
    init(baseType: String, items: [ItemState] = [], cutHistory: [CutPathState] = []) {
        self.baseType = baseType
        self.items = items
        self.cutHistory = cutHistory
    }
}

struct ItemState: Codable {
    let id: UUID
    var type: String
    var position: CGPointCodable
    var rotation: CGFloat
    var scale: CGFloat
    var zPosition: CGFloat
}

struct CutPathState: Codable {
    var points: [CGPointCodable]
    var width: CGFloat
}

