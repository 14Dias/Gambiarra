import SwiftUI
import AVFoundation

struct TelaDescoberta: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var materialFocado: MaterialDescoberto? = nil
    @State private var mostrarInfo: Bool = false
    
    var body: some View {
        ZStack {
            Image("TelaFundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)
            
            ZStack {
                ForEach(estado.materiais.indices, id: \.self) { index in
                    let material = estado.materiais[index]
                    
                    if !material.descoberto || materialFocado?.id != material.id {
                        Image(material.assetImagem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .shadow(radius: 5)
                            .offset(x: material.offsetX, y: material.offsetY)
                            .opacity(material.descoberto ? 0.6 : 1.0)
                            .saturation(material.descoberto ? 0.0 : 1.0)
                            .onTapGesture {
                                selecionarMaterial(index)
                            }
                            .zIndex(1)
                    }
                }
                
                VStack {
                    if estado.todosMateriaisDescobertos {
                        Text("Swipe to continue")
                            .font(.title.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(50)
                
                if let focado = materialFocado, mostrarInfo {
                    // Camada de visualização focada
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .zIndex(5)
                        .onTapGesture { fecharFoco() }
                    
                    VStack(spacing: 20) {
                        Image(focado.assetImagem)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .shadow(radius: 20)
                        
                        Text(focado.nome)
                            .font(.largeTitle.bold())
                            .foregroundColor(.black)
                        
                        Text(focado.descricao)
                            .font(.title3)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Entendi!") {
                            fecharFoco()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                    }
                    .padding()
                    .transition(.scale)
                    .zIndex(10)
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    guard estado.todosMateriaisDescobertos else { return }
                    if abs(value.translation.width) > 80 && abs(value.translation.height) < 60 {
                        // ALTERAÇÃO: Agora vai para a Explicação 2 em vez do Craft direto
                        withAnimation { estado.telaAtual = .explicacao2 }
                    }
                }
        )
    }
    
    func selecionarMaterial(_ index: Int) {
        guard !estado.materiais[index].descoberto else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            materialFocado = estado.materiais[index]
            mostrarInfo = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let mat = materialFocado, let idx = estado.materiais.firstIndex(where: {$0.id == mat.id}) {
                estado.materiais[idx].descoberto = true
            }
        }
    }
    
    func fecharFoco() {
        withAnimation {
            mostrarInfo = false
            materialFocado = nil
        }
    }
}

#Preview(traits: .landscapeLeft) {
    let exemplo = EstadoDoJogo()
    return TelaDescoberta(estado: exemplo)
}
