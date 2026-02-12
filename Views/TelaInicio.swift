import SwiftUI
import AVFoundation

struct TelaInicio: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var escalaBotao: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Image("Telainicial")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)
            
            VStack(spacing: -530) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 600)
                    .offset(y: -500)
                    .shadow(radius: 10)
                
                Button(action: {
                    withAnimation {
                        estado.telaAtual = .explicacao
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .font(.system(size: 46, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .frame(width: 350)
                    .background(Color.orange)
                    .cornerRadius(25)
                    .shadow(radius: 5)
                    .scaleEffect(escalaBotao)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        escalaBotao = 1.02
                    }
                }
            }
        }
    }
}
#Preview(traits: .landscapeLeft) {
    // Cria um estado de jogo de exemplo para o Preview
    let exemplo = EstadoDoJogo()
    return TelaInicio(estado: exemplo)
}
