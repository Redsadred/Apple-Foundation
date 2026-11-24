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
struct GameDetailView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header com botão voltar circular
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
                    
                    Text(game.fullTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Carrossel de Trailer / Screenshots
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(game.screenshotsURL.enumerated()), id: \.offset) { index, urlString in
                            ZStack {
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.cardDark
                                }
                                .frame(width: 240, height: 145)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                if index == 0 {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                        .shadow(radius: 6)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Metadados (Desenvolvedor, Distribuidora, Data)
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(label: "Desenvolvedor:", value: game.developer, isLink: true)
                    infoRow(label: "Distribuidora:", value: game.publisher, isLink: true)
                    infoRow(label: "Data de lançamento:", value: game.releaseDate, isLink: false)
                }
                .padding(.horizontal, 16)
                
                // Sinopse
                Text(game.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                
                // Rodapé de Avaliação, Classificação Indicativa, Compartilhar e Onde Comprar
                HStack(spacing: 18) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", game.rating))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Badge Classificação (ex: 14)
                    Text(game.ageRating)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    if let shareURL = URL(string: game.storeURL), !game.storeURL.isEmpty {
                        ShareLink(item: shareURL) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    if let url = URL(string: game.storeURL), !game.storeURL.isEmpty {
                        Link(destination: url) {
                            Text("Onde comprar")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(Color.cardDark)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.bottom, 100)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Filtros")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 12)
                
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(viewModel.genres) { genre in
                        GenreCardView(genre: genre)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
        .background(Color.appBackground.ignoresSafeArea())
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
        viewModel.games.filter { $0.genres.contains(genre.name) }
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
                        GameCardView(game: game, width: 170)
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