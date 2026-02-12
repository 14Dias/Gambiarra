import AVFoundation
import SwiftUI

struct TelaCraft: View {
    @ObservedObject var estado: EstadoDoJogo
    
    @State private var slot1: MaterialDescoberto?
    @State private var slot2: MaterialDescoberto?
    
    @State private var mensagemFeedback: String = "Arrasta 2 materiais para combinar!"
    @State private var feedbackCor: Color = .white
    @State private var mostrarSucesso: Bool = false
    @State private var assetResultadoAtual: String = "Interrogacao"
    
    var receitaAtual: CombinacaoCraft? {
        estado.combinacoes.first(where: { $0.rodada == estado.rodadaCraftAtual })
    }
    
    var body: some View {
        ZStack {
            Image("TelaFundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)
            
            GeometryReader { geo in
                VStack {
                    HStack {
                        Text("Protótipo \(estado.rodadaCraftAtual) de 3")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: geo.size.width * 0.9, height: 300)
                        
                        if mostrarSucesso {
                            VStack {
                                Image(assetResultadoAtual)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .transition(.scale)
                                
                                Text("Sucesso!")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.green)
                                
                                Button("Próximo") {
                                    avancarRodada()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            HStack(spacing: 50) {
                                SlotView(material: slot1, placeholder: "1")
                                    .onTapGesture { slot1 = nil }
                                
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                
                                SlotView(material: slot2, placeholder: "2")
                                    .onTapGesture { slot2 = nil }
                            }
                        }
                    }
                    
                    Text(mensagemFeedback)
                        .font(.headline)
                        .foregroundColor(feedbackCor)
                        .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Mochila de Materiais")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(estado.materiais) { material in
                                    Image(material.assetImagem)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                        .padding(5)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            adicionarMaterial(material)
                                        }
                                }
                            }
                            .padding()
                        }
                        .background(Color.black.opacity(0.2))
                    }
                }
            }
        }
        // CORREÇÃO: Sintaxe nova do onChange para iOS 17+
        .onChange(of: slot1) { _ in verificarCombinacao() }
        .onChange(of: slot2) { _ in verificarCombinacao() }
    }
    
    func adicionarMaterial(_ mat: MaterialDescoberto) {
        guard !mostrarSucesso else { return }
        
        withAnimation {
            if slot1 == nil {
                slot1 = mat
            } else if slot2 == nil {
                slot2 = mat
            }
        }
    }
    
    func verificarCombinacao() {
        guard let m1 = slot1, let m2 = slot2, let receita = receitaAtual else {
            mensagemFeedback = "Escolhe dois materiais..."
            feedbackCor = .white
            return
        }
        
        let nomesSelecionados = [m1.nome, m2.nome]
        let ingredientesCertos = [receita.material1Nome, receita.material2Nome]
        
        let acertou = nomesSelecionados.allSatisfy(ingredientesCertos.contains) && nomesSelecionados.count == ingredientesCertos.count && m1.nome != m2.nome
        
        if acertou {
            feedbackCor = .green
            mensagemFeedback = "A CRIAR..."
            
            withAnimation(.easeInOut(duration: 0.5)) {
                assetResultadoAtual = receita.assetResultado
                mostrarSucesso = true
                slot1 = nil
                slot2 = nil
            }
        } else {
            feedbackCor = .red
            mensagemFeedback = "Essa combinação não funciona. Tenta outra!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    slot1 = nil
                    slot2 = nil
                    feedbackCor = .white
                    mensagemFeedback = "Tenta de novo!"
                }
            }
        }
    }
    
    func avancarRodada() {
        if estado.rodadaCraftAtual < 3 {
            withAnimation {
                estado.rodadaCraftAtual += 1
                mostrarSucesso = false
                mensagemFeedback = "Vamos para o próximo protótipo!"
            }
        } else {
            withAnimation {
                estado.telaAtual = .parabenizacao
            }
        }
    }
}
#Preview(traits: .landscapeLeft) {
    // Cria um estado de jogo de exemplo para o Preview
    let exemplo = EstadoDoJogo()
    return TelaCraft(estado: exemplo)
}
