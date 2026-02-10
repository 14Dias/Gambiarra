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

// MARK: - ESTADO DO JOGO

class EstadoDoJogo: ObservableObject {
    @Published var telaAtual: TelaJogo = .inicio
    @Published var materiais: [MaterialDescoberto] = []
    @Published var combinacoes: [CombinacaoCraft] = []
    @Published var rodadaCraftAtual: Int = 1
    
    // Controle da Explicação
    @Published var textoExplicacaoIndex: Int = 0
    let textosExplicacao = [
        "Sabias que tudo à tua volta foi criado por alguém?",
        "Antes de existir, cada objeto foi um PROTÓTIPO...",
        "Uma primeira versão para testar ideias!",
        "Hoje vais aprender a criar os teus próprios protótipos.",
        "Vamos começar por descobrir os materiais necessários!"
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
            MaterialDescoberto(nome: "Rolo de Papelão", assetImagem: "PapelaoUnico", descricao: "A estrutura base do nosso projeto.", descoberto: false, offsetX: -100, offsetY: 50),
            MaterialDescoberto(nome: "Cola", assetImagem: "Cola", descricao: "Essencial para unir peças permanentemente.", descoberto: false, offsetX: 120, offsetY: -120),
            MaterialDescoberto(nome: "Tesoura", assetImagem: "Tesoura", descricao: "Use com cuidado para cortar e moldar.", descoberto: false, offsetX: -140, offsetY: -100),
            MaterialDescoberto(nome: "Fita Adesiva", assetImagem: "Fita", descricao: "Ótima para fixações rápidas.", descoberto: false, offsetX: 80, offsetY: 100),
            MaterialDescoberto(nome: "Papel Colorido", assetImagem: "Papel", descricao: "Dá cor e vida ao protótipo.", descoberto: false, offsetX: 0, offsetY: 160),
            MaterialDescoberto(nome: "Botões", assetImagem: "Botao", descricao: "Perfeitos para detalhes e decoração.", descoberto: false, offsetX: -80, offsetY: 0),
            MaterialDescoberto(nome: "Clips", assetImagem: "Clips", descricao: "Servem de arame ou suporte.", descoberto: false, offsetX: 150, offsetY: 0)
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
    @StateObject private var estado = EstadoDoJogo()
    
    var body: some View {
        ZStack {
            Image("Telainicial")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.8)
            
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

// MARK: - TELA DE INÍCIO

struct TelaInicio: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var escalaBotao: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 600, height: 600)
                .offset(y: -200)
                .shadow(radius: 10)
            
            VStack(spacing: 10) {
                Text("CRIANDO PROTÓTIPOS")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                
                Text("Descobre como criar coisas incríveis!")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .fontWeight(.medium)
            }
            
            Button(action: {
                withAnimation {
                    estado.telaAtual = .explicacao
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("COMEÇAR")
                }
                .font(.title.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(Color.orange)
                .cornerRadius(30)
                .shadow(radius: 5)
                .scaleEffect(escalaBotao)
                .padding(20)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    escalaBotao = 1.1
                }
            }
        }
    }
}

// MARK: - TELA DE EXPLICAÇÃO (CORRIGIDA)

struct TelaExplicacao: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var textoExibido: String = ""
    @State private var textoCompleto: Bool = false
    
    // CORREÇÃO: Usamos Task em vez de Timer para segurança de concorrência
    @State private var digitacaoTask: Task<Void, Never>?
    
    var textoAtual: String {
        if estado.textoExplicacaoIndex < estado.textosExplicacao.count {
            return estado.textosExplicacao[estado.textoExplicacaoIndex]
        }
        return ""
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 10)
                    .frame(height: 250)
                    .padding()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(textoExibido)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                        .id("textoTyper")
                    
                    HStack {
                        Spacer()
                        if textoCompleto {
                            Text("Toque para continuar >>")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .frame(height: 250)
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

// MARK: - TELA DE DESCOBERTA

struct TelaDescoberta: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var materialFocado: MaterialDescoberto? = nil
    @State private var mostrarInfo: Bool = false
    
    var body: some View {
        ZStack {
            ForEach(estado.materiais.indices, id: \.self) { index in
                let material = estado.materiais[index]
                
                if !material.descoberto || materialFocado?.id != material.id {
                    Image(material.assetImagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
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
                HStack {
                    Text("Encontra os materiais!")
                        .font(.title2.bold())
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    Spacer()
                    Text("\(estado.materiais.filter{$0.descoberto}.count)/\(estado.materiais.count)")
                        .font(.title3.bold())
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                .padding()
                Spacer()
                
                if estado.todosMateriaisDescobertos {
                    Button(action: {
                        withAnimation { estado.avancarParaCraft() }
                    }) {
                        Text("VAMOS CRIAR!")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            if let focado = materialFocado, mostrarInfo {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { fecharFoco() }
                
                VStack(spacing: 20) {
                    Image(focado.assetImagem)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .shadow(radius: 20)
                    
                    Text(focado.nome)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text(focado.descricao)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Entendi!") {
                        fecharFoco()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(15)
                }
                .padding()
                .transition(.scale)
                .zIndex(10)
            }
        }
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

// MARK: - TELA DE CRAFT (CORRIGIDA)

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
        // CORREÇÃO: Sintaxe nova do onChange para iOS 17+
        .onChange(of: slot1) { verificarCombinacao() }
        .onChange(of: slot2) { verificarCombinacao() }
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

struct SlotView: View {
    var material: MaterialDescoberto?
    var placeholder: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 100, height: 100)
                .overlay(
                    Circle().stroke(Color.white, style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
            
            if let mat = material {
                Image(mat.assetImagem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .transition(.scale)
            } else {
                Text(placeholder)
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - TELA DE PARABENIZAÇÃO

struct TelaParabenizacao: View {
    @ObservedObject var estado: EstadoDoJogo
    @State private var rotacaoMedalha = 0.0
    @State private var escala = 0.0
    
    var body: some View {
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
#Preview (traits: .landscapeLeft){
    ContentView()
}
