import SwiftUI
import AVFoundation

// MARK: - ESTADO DO JOGO

@MainActor
class EstadoDoJogo: ObservableObject {
    @Published var telaAtual: TelaJogo = .inicio
    @Published var materiais: [MaterialDescoberto] = []
    @Published var combinacoes: [CombinacaoCraft] = []
    @Published var rodadaCraftAtual: Int = 1
    
    // Controle da Explicação 1
    @Published var textoExplicacaoIndex: Int = 0
    let textosExplicacao = [
        "Did you know everything around you was created by someone?",
        "Before existing, every object started as a PROTOTYPE...",
        "A first version made to test ideas!",
        "Today you're going to learn how to create your own prototypes.",
        "Let’s start by finding the materials we need!"
    ]
    
    var todosMateriaisDescobertos: Bool {
        return !materiais.contains { $0.descoberto == false }
    }
    
    init() {
        reiniciarDados()
    }
    
    func reiniciarDados() {
        // Certifique-se que estes nomes batem com seus Assets
        materiais = [
            MaterialDescoberto(nome: "Rolo de Papelão", assetImagem: "PapelaoUnico", descricao: "A estrutura base do nosso projeto.", descoberto: false, offsetX: -400, offsetY: 190),
            MaterialDescoberto(nome: "Cola", assetImagem: "Cola", descricao: "Essencial para unir peças permanentemente.", descoberto: false, offsetX: 150, offsetY: -40),
            MaterialDescoberto(nome: "Tesoura", assetImagem: "Tesoura", descricao: "Use com cuidado para cortar e moldar.", descoberto: false, offsetX: -140, offsetY: 10),
            MaterialDescoberto(nome: "Fita Adesiva", assetImagem: "Fita", descricao: "Ótima para fixações rápidas.", descoberto: false, offsetX: 380, offsetY: 200),
            MaterialDescoberto(nome: "Papel Colorido", assetImagem: "Papel", descricao: "Dá cor e vida ao protótipo.", descoberto: false, offsetX: 70, offsetY: 180),
            MaterialDescoberto(nome: "Botões", assetImagem: "Botao", descricao: "Perfeitos para detalhes e decoração.", descoberto: false, offsetX: -380, offsetY: -90),
            MaterialDescoberto(nome: "Clips", assetImagem: "Clips", descricao: "Servem de arame ou suporte.", descoberto: false, offsetX: 450, offsetY: -50)
        ]
        
        combinacoes = [
            CombinacaoCraft(nome: "Cortar Base", material1Nome: "Rolo de Papelão", material2Nome: "Tesoura", assetResultado: "papelaoCortado", rodada: 1),
            CombinacaoCraft(nome: "Criar Apoio", material1Nome: "Rolo de Papelão", material2Nome: "Fita Adesiva", assetResultado: "papelaoVirado", rodada: 2),
            CombinacaoCraft(nome: "Acabamento", material1Nome: "Rolo de Papelão", material2Nome: "Botões", assetResultado: "Telainicial", rodada: 3)
        ]
        
        rodadaCraftAtual = 1
        textoExplicacaoIndex = 0
    }
    
    func avancarParaCraft() {
        rodadaCraftAtual = 1
        telaAtual = .craft
    }
    
    func resetarJogo() {
        reiniciarDados()
        telaAtual = .inicio
    }
}

// MARK: - VIEW PRINCIPAL

struct ContentView: View {
    // CORREÇÃO: StateObject garante que o objeto não morra quando a View recarrega
    @StateObject private var estado = EstadoDoJogo()
    
    var body: some View {
        ZStack {
            switch estado.telaAtual {
            case .inicio:
                TelaInicio(estado: estado)
                    .transition(.opacity)
            case .explicacao:
                TelaExplicacao(estado: estado)
                    .transition(.opacity)
            case .descoberta:
                TelaDescoberta(estado: estado)
                    .transition(.opacity)
            case .explicacao2:
                TelaExplicacao2(estado: estado)
                    .transition(.opacity)
            case .craft:
                TelaCraft(estado: estado)
                    .transition(.opacity)
            case .parabenizacao:
                TelaParabenizacao(estado: estado)
                    .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: estado.telaAtual)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
