import SwiftUI
import AVFoundation

struct TelaExplicacao: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var textoExibido: String = ""
    @State private var textoCompleto: Bool = false
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

                        Spacer().frame(width: 232)
                    }

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
        
        let textoAlvo = textoAtual
        
        digitacaoTask = Task {
            for char in textoAlvo {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
                
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
            digitacaoTask?.cancel()
            textoExibido = textoAtual
            textoCompleto = true
        } else {
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
    let exemplo = EstadoDoJogo()
    return TelaExplicacao(estado: exemplo)
}
