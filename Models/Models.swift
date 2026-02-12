import SwiftUI
import AVFoundation

// MARK: - MODELOS DE DADOS

enum TelaJogo {
    case inicio
    case explicacao
    case descoberta
    case craft
    case parabenizacao
}

struct MaterialDescoberto: Identifiable, Equatable {
    let id = UUID()
    let nome: String
    let assetImagem: String
    let descricao: String
    var descoberto: Bool = false
    var offsetX: CGFloat
    var offsetY: CGFloat
}

struct CombinacaoCraft: Identifiable {
    let id = UUID()
    let nome: String
    let material1Nome: String
    let material2Nome: String
    let assetResultado: String
    let rodada: Int
    var concluida: Bool = false
}
