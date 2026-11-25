import SwiftUI

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
            .navigationDestination(for: Game.self) { selectedGame in
                GameDetailView(game: selectedGame)
            }
        }
    }
}
