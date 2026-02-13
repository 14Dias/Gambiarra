import SwiftUI
import SpriteKit

struct TelaCraft: View {
    @ObservedObject var estado: EstadoDoJogo
    
    // Scene Holder
    @State private var scene = WorkbenchScene()
    
    @State private var ferramentaSelecionada: ToolType = .hand
    @State private var mostrarConfirmacao = false
    
    var body: some View {
        ZStack {
            // 1. O Mundo SpriteKit
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.size = CGSize(width: 1024, height: 768)
                    scene.scaleMode = .aspectFill
                    scene.baseType = estado.rodadaCraftAtual == 1 ? .rolo : .papel
                    scene.selectedTool = ferramentaSelecionada
                }
                .onChange(of: ferramentaSelecionada) { newTool in
                    scene.selectedTool = newTool
                }
            
            // 2. Interface do Usuário (Overlay)
            VStack {
                // Header
                HStack {
                    Button(action: {
                        withAnimation {
                            let novaCena = WorkbenchScene()
                            novaCena.size = CGSize(width: 1024, height: 768)
                            novaCena.scaleMode = .aspectFill
                            novaCena.baseType = estado.rodadaCraftAtual == 1 ? .rolo : .papel
                            novaCena.selectedTool = ferramentaSelecionada
                            scene = novaCena
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                    
                    Spacer()
                    
                    Text("Modo Criação Livre")
                        .font(.headline)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    Button(action: {
                        mostrarConfirmacao = true
                    }) {
                        Text("Concluir")
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 3)
                    }
                }
                .padding()
                
                Spacer()
                
                // 3. Tool Palette (Apple Pencil Style)
                HStack(spacing: 20) {
                    ForEach(ToolType.allCases) { tool in
                        Button(action: {
                            ferramentaSelecionada = tool
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: tool.rawValue)
                                    .font(.system(size: 28))
                                    .frame(width: 50, height: 50)
                                    .background(ferramentaSelecionada == tool ? Color.white : Color.clear)
                                    .foregroundColor(ferramentaSelecionada == tool ? .black : .white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                                    .scaleEffect(ferramentaSelecionada == tool ? 1.2 : 1.0)
                                    .animation(.spring(), value: ferramentaSelecionada)
                                
                                Text(nomeFerramenta(tool))
                                    .font(.caption2)
                                    .foregroundColor(.black)
                                    .opacity(ferramentaSelecionada == tool ? 1 : 0.6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial)
                .cornerRadius(40)
                .shadow(radius: 10)
                .padding(.bottom, 20)
            }
        }
        .alert("Terminou sua criação?", isPresented: $mostrarConfirmacao) {
            Button("Sim, ficou ótimo!", role: .none) {
                estado.avancarParaCraft() // Ou lógica de salvar
            }
            Button("Ainda não", role: .cancel) {}
        }
    }
    
    func nomeFerramenta(_ tool: ToolType) -> String {
        switch tool {
        case .hand: return "Mover"
        case .scissors: return "Cortar"
        case .glue: return "Cola"
        case .tape: return "Fita"
        case .clip: return "Clips"
        case .button: return "Botão"
        }
    }
}

#Preview(traits: .landscapeLeft) {
    TelaCraft(estado: EstadoDoJogo())
}
