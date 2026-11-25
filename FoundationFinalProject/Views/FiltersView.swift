import SwiftUI

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
