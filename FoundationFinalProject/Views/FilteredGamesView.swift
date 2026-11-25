import SwiftUI

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
