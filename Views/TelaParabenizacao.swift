import SwiftUI
import AVFoundation

struct TelaParabenizacao: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var rotacaoMedalha = 0.0
    @State private var escala = 0.0
    
    init(estado: EstadoDoJogo) {
        self._estado = ObservedObject(wrappedValue: estado)
    }
    
    var body: some View {
        ZStack {
            Image("TelaFundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)
            
            VStack(spacing: 30) {
                Text("PARABÉNS!")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 2)
                
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .scaleEffect(escala)
                    
                    Image(systemName: "medal.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(rotacaoMedalha))
                }
                
                Text("És um verdadeiro PROTOTIPADOR!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Agora sabes transformar ideias em realidade.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                
                Button("Jogar Novamente") {
                    withAnimation {
                        estado.resetarJogo()
                    }
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.orange)
                .cornerRadius(15)
                .padding(.top, 30)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                escala = 1.2
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotacaoMedalha = 360
            }
        }
    }
}
#Preview(traits: .landscapeLeft) {
    // Cria um estado de jogo de exemplo para o Preview
    let exemplo = EstadoDoJogo()
    return TelaParabenizacao(estado: exemplo)
}
