import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotionViewModel()
    @State private var selectedTab: AppTab = .jogos
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Pilha de Navegação principal
            NavigationStack {
                Group {
                    switch selectedTab {
                    case .jogos:
                        HomeView(viewModel: viewModel)
                    case .generos:
                        FiltersView(viewModel: viewModel)
                    case .pesquisa:
                        SearchView(viewModel: viewModel)
                    }
                }
                // Destinos de navegação tipados
                .navigationDestination(for: Game.self) { game in
                    GameDetailView(game: game)
                }
                .navigationDestination(for: GenreItem.self) { genre in
                    FilteredGamesView(genre: genre, viewModel: viewModel)
                }
            }
            
            // Barra de navegação flutuante sobreposta ao conteúdo
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard) // Evita que a barra suba junto com o teclado na pesquisa
    }
}

#Preview {
    ContentView()
}