import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotionViewModel()
    @State private var selectedTab: AppTab = .jogos

    var body: some View {
        ZStack(alignment: .bottom) {
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
                .navigationDestination(for: Game.self) { game in
                    GameDetailView(game: game)
                }
                .navigationDestination(for: GenreItem.self) { genre in
                    FilteredGamesView(genre: genre, viewModel: viewModel)
                }
            }

            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .task {
            
        }
    }
}

#Preview {
    ContentView()
}
