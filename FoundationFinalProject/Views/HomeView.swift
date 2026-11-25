import SwiftUI

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
