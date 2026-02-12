//
//  TelaExplicacao 2.swift
//  PlaygroundTemplate
//
//  Created by Luca Dias on 12/02/26.
//


import SwiftUI
import AVFoundation

let textosExplicacao2 = [
    "Did you know everything around you was created by someone?",
    "Before existing, every object started as a PROTOTYPE...",
    "A first version made to test ideas!",
    "Today you're going to learn how to create your own prototypes.",
    "Let’s start by finding the materials we need!"
]
struct TelaExplicacao2: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var textoExibido: String = ""
    @State private var textoCompleto: Bool = false
    @State private var fase = 0
    @State private var textoExplicacaoIndex2: Int = 0
    
    // CORREÇÃO: Usamos Task em vez de Timer para segurança de concorrência
    @State private var digitacaoTask: Task<Void, Never>?
    
    var textoAtual: String {
        if textoExplicacaoIndex2 < textosExplicacao2.count {
            return textosExplicacao2[textoExplicacaoIndex2]
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
            if textoExplicacaoIndex2 < textosExplicacao2.count - 1 {
               textoExplicacaoIndex2 += 1
                comecarDigitacao()
            } else {
                withAnimation {
                    estado.telaAtual = .explicacao2
                }
            }
        }
    }
}
#Preview(traits: .landscapeLeft) {
    TelaExplicacao2()
}

