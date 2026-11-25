import SwiftUI

// 1. TELA PRINCIPAL (Jogos)
struct HomeView: View {
    @ObservedObject var viewModel: NotionViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                Text("Jogos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                
                // Aviso discreto quando o token não está configurado ou a API falhou
                if let message = viewModel.errorMessage {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                        Text(message)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(Color.cardDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }
                
                if viewModel.isLoading && viewModel.games.isEmpty {
                    ProgressView("Carregando jogos...")
                        .tint(.white)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                }
                
                ForEach(GameSection.allCases) { category in
                    let sectionGames = viewModel.games.filter { $0.section == category }
                    
                    if !sectionGames.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.rawValue)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                            
                            // REQUISITO 2: Lista horizontal que pode ser mexida (Scroll)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(sectionGames) { game in
                                        GameCardView(game: game)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            // Espaço extra embaixo para não ficar escondido atrás da barra flutuante
            .padding(.bottom, 100)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// 2. TELA DE DETALHES DO JOGO
import SwiftUI

struct GameDetailView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @State private var isDescriptionExpanded = false
    @State private var sharePreviewImage: Image?
    
    // Estados para o zoom centralizado da imagem
    @State private var selectedScreenshotURL: String?
    @State private var zoomScale: CGFloat = 1.0
    
    // Define se a sinopse é longa o suficiente para precisar do botão "..."
    private var isLongDescription: Bool {
        game.description.count > 160
    }
    
    // Preview usado na folha de compartilhamento (Nome + Imagem ao lado)
    private var sharePreview: SharePreview<Image, Never> {
        if let sharePreviewImage {
            return SharePreview(game.fullTitle, image: sharePreviewImage)
        } else {
            return SharePreview(game.fullTitle, image: Image(systemName: "gamecontroller.fill"))
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // HEADER COM BOTÃO VOLTAR E ÍCONE DE COMPARTILHAR
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.pillBackground)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Ícone de compartilhar (3 bolinhas conectadas) com preview da imagem
                        if let shareURL = URL(string: game.storeURL), !game.storeURL.isEmpty {
                            ShareLink(
                                item: shareURL,
                                subject: Text(game.fullTitle),
                                message: Text("Confira \(game.fullTitle)!"),
                                preview: sharePreview
                            ) {
                                shareIconButton
                            }
                        } else {
                            ShareLink(
                                item: "\(game.fullTitle)\n\n\(game.description)",
                                preview: sharePreview
                            ) {
                                shareIconButton
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // NOME DO JOGO LOGO ACIMA DA IMAGEM
                    Text(game.fullTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    
                    // CARROSSEL DE SCREENSHOTS (SEM PLAY E CLICÁVEL PARA ZOOM)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(game.screenshotsURL.enumerated()), id: \.offset) { _, urlString in
                                let cleanURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                AsyncImage(url: URL(string: cleanURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Color.cardDark
                                    }
                                }
                                .frame(width: 240, height: 145)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    zoomScale = 1.0
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                        selectedScreenshotURL = cleanURL
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // FAIXA ETÁRIA E CLASSIFICAÇÃO LOGO ABAIXO DAS IMAGENS
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", game.rating))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text(game.ageRating)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(ageRatingColor(for: game.ageRating))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 16)
                    
                    // SINOPSE COM EXPANSÃO NOS TRÊS PONTINHOS ("...")
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .lineLimit(isDescriptionExpanded ? nil : 4)
                        
                        if isLongDescription {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isDescriptionExpanded.toggle()
                                }
                            } label: {
                                Text(isDescriptionExpanded ? "ver menos" : "...")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .padding(.top, 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // DESENVOLVEDOR, DISTRIBUIDORA E DATA DE LANÇAMENTO ABAIXO DA SINOPSE
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(label: "Desenvolvedor:", value: game.developer, isLink: true)
                        infoRow(label: "Distribuidora:", value: game.publisher, isLink: true)
                        infoRow(label: "Data de lançamento:", value: game.releaseDate, isLink: false)
                    }
                    .padding(.horizontal, 16)
                    
                    // BOTÃO ONDE COMPRAR
                    if let url = URL(string: game.storeURL), !game.storeURL.isEmpty {
                        HStack {
                            Spacer()
                            Link(destination: url) {
                                Text("Onde comprar")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 26)
                                    .padding(.vertical, 12)
                                    .background(Color.cardDark)
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color.appBackground.ignoresSafeArea())
            
            // OVERLAY DE ZOOM CENTRALIZADO NO MEIO DA TELA
            if let zoomedURL = selectedScreenshotURL {
                ZStack {
                    Color.black.opacity(0.88)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeZoom()
                        }
                    
                    AsyncImage(url: URL(string: zoomedURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 16)
                                .scaleEffect(zoomScale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            zoomScale = max(1.0, min(value, 3.0))
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                zoomScale = 1.0
                                            }
                                        }
                                )
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        default:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Botão fechar no canto superior direito
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                closeZoom()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 38, height: 38)
                                    .background(Color.pillBackground)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 16)
                        }
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadSharePreviewImage()
        }
    }
    
    private func closeZoom() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedScreenshotURL = nil
            zoomScale = 1.0
        }
    }
    
    // Baixa a thumbnail (ou pega dos Assets) e converte para SwiftUI Image
    private func loadSharePreviewImage() async {
        let cleanURL = game.thumbnailURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanURL.isEmpty else { return }
        
        if let url = URL(string: cleanURL), cleanURL.hasPrefix("http") {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let uiImage = UIImage(data: data) {
                sharePreviewImage = Image(uiImage: uiImage)
            }
        } else {
            sharePreviewImage = Image(cleanURL)
        }
    }
    
    // Visual do botão de compartilhar no topo (3 bolinhas conectadas)
    private var shareIconButton: some View {
        Image(systemName: "point.3.connected.trianglepath.dotted")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 40, height: 40)
            .background(Color.pillBackground)
            .clipShape(Circle())
    }
    
    private func infoRow(label: String, value: String, isLink: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isLink ? .cyan : .gray)
                .underline(isLink)
        }
    }
    
    // Cor automática para o selo de classificação indicativa brasileira
    private func ageRatingColor(for rating: String) -> Color {
        switch rating.uppercased() {
        case "L", "LIVRE": return .green
        case "10": return .blue
        case "12": return .yellow
        case "14": return .orange
        case "16": return .red
        case "18": return .black
        default: return .orange
        }
    }
}

// 3. TELA DE PESQUISA (Requisito 3)
struct SearchView: View {
    @ObservedObject var viewModel: NotionViewModel
    @State private var searchText = ""
    
    var filteredGames: [Game] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return viewModel.games
        }
        return viewModel.games.filter {
            $0.fullTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Barra de pesquisa no topo + botão X
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Pesquisar jogos...", text: $searchText)
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                    
                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Resultados em Scroll que cortam atrás da barra inferior
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(filteredGames) { game in
                        NavigationLink(value: game) {
                            HStack(spacing: 16) {
                                AsyncImage(url: URL(string: game.thumbnailURL)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .frame(width: 82, height: 82)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                Text(game.fullTitle)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                // Padding inferior permite rolar até o último item acima da barra flutuante
                .padding(.bottom, 100)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// 4. TELA DE FILTROS / GÊNEROS (Requisito 4)
struct FiltersView: View {
    @ObservedObject var viewModel: NotionViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Filtros")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 12)
                    
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(viewModel.genres) { genre in
                            NavigationLink(value: genre) {
                                GenreCardView(genre: genre)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 100)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(for: GenreItem.self) { selectedGenre in
                FilteredGamesView(genre: selectedGenre, viewModel: viewModel)
            }
            // ADICIONE ESTE DESTINO PARA ABRIR A GameDetailView:
            .navigationDestination(for: Game.self) { selectedGame in
                GameDetailView(game: selectedGame)
            }
        }
    }
}

// 5. TELA DE JOGOS FILTRADOS POR GÊNERO (Ex: Indie)
struct FilteredGamesView: View {
    let genre: GenreItem
    @ObservedObject var viewModel: NotionViewModel
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var gamesInGenre: [Game] {
            viewModel.games.filter { game in
                game.genres.contains { notionGenre in
                    notionGenre
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .compare(genre.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                }
            }
        }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Header com botão voltar + Nome do Gênero
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Color.pillBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(genre.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Grade de 2 colunas
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(gamesInGenre) { game in
                        NavigationLink(value: game) {
                            GameCardView(game: game, width: 170)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
