import SwiftUI
import AVFoundation

struct TelaExplicacao: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var textoExibido: String = ""
    @State private var textoCompleto: Bool = false
    @State private var fase = 0
    
    // CORREÇÃO: Usamos Task em vez de Timer para segurança de concorrência
    @State private var digitacaoTask: Task<Void, Never>?
    
    var textoAtual: String {
        if estado.textoExplicacaoIndex < estado.textosExplicacao.count {
            return estado.textosExplicacao[estado.textoExplicacaoIndex]
        }
        return ""
    }
    
    var body: some View {
        ZStack {
            Image("TelaFundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)
            
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.orange.opacity(0.9))
                        .shadow(radius: 10)
                        .frame(height: 250)
                        .padding(70)
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 200) {
                            Text(textoExibido)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 120)
                                .id("textoTyper")

                            HStack {
                                Spacer()
                                if textoCompleto {
                                    Text("Toque para continuar >>")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .offset(y: -120)
                        }

                        // Reserva de espaço à direita para o gato (200 de largura + 32 de margem)
                        Spacer().frame(width: 232)
                    }

                    // GatoB ancorado à direita por cima da caixa de texto
                    HStack {
                        Spacer()
                        Image("GatoB")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .padding(.trailing, 70)
                            .offset(y: -150)
                    }
                }
            }
        }
        .onAppear {
            comecarDigitacao()
        }
        // Cancelar tarefa ao sair da tela para evitar vazamento
        .onDisappear {
            digitacaoTask?.cancel()
        }
        .onTapGesture {
            tratarClique()
        }
    }
    
    func comecarDigitacao() {
        textoExibido = ""
        textoCompleto = false
        digitacaoTask?.cancel()
        
        let textoAlvo = textoAtual // Captura string para uso seguro na Task
        
        digitacaoTask = Task {
            for char in textoAlvo {
                // Verificação de cancelamento
                if Task.isCancelled { return }
                
                // Pausa não bloqueante (substitui o Timer)
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 segundos
                
                // Atualização segura na Main Thread (Views são @MainActor por padrão)
                if !Task.isCancelled {
                    textoExibido.append(char)
                }
            }
            if !Task.isCancelled {
                textoCompleto = true
            }
        }
    }
    
    func tratarClique() {
        if !textoCompleto {
            // Completar texto instantaneamente
            digitacaoTask?.cancel()
            textoExibido = textoAtual
            textoCompleto = true
        } else {
            // Avançar
            if estado.textoExplicacaoIndex < estado.textosExplicacao.count - 1 {
                estado.textoExplicacaoIndex += 1
                comecarDigitacao()
            } else {
                withAnimation {
                    estado.telaAtual = .descoberta
                }
            }
        }
    }
}
#Preview(traits: .landscapeLeft) {
    // Cria um estado de jogo de exemplo para o Preview
    let exemplo = EstadoDoJogo()
    return TelaExplicacao(estado: exemplo)
}
