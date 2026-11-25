import SwiftUI

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
