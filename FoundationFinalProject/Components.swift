import SwiftUI

// REQUISITO 1: Componente que exibe o jogo (Card)
struct GameCardView: View {
    let game: Game
    var width: CGFloat = 175
    
    var body: some View {
        NavigationLink(value: game) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail arredondada nas pontas
                AsyncImage(url: URL(string: game.thumbnailURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color.cardDark)
                            .overlay(ProgressView().tint(.white))
                    }
                }
                .frame(width: width, height: width * 0.58)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Nome e Classificação
                HStack(spacing: 4) {
                    Text(game.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", game.rating))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: width)
            }
        }
        .buttonStyle(.plain)
    }
}

// REQUISITO 4: Componente de Filtro (Imagem + Texto com degradê)
struct GenreCardView: View {
    let genre: GenreItem
    
    var body: some View {
        NavigationLink(value: genre) {
            ZStack(alignment: .leading) {
                Color.cardDark
                
                // Imagem na direita com máscara de degradê
                HStack {
                    Spacer()
                    Image(genre.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 95, height: 85)
                        .overlay(
                            LinearGradient(
                                colors: [Color.cardDark, Color.cardDark.opacity(0.2), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipped()
                }
                
                // Texto do gênero à esquerda
                Text(genre.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 18)
            }
            .frame(height: 85)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// Barra Inferior Flutuante (Jogos / Gêneros + Botão de Pesquisa)
enum AppTab {
    case jogos, generos, pesquisa
}

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 16) {
            // Pílula Esquerda (Jogos e Gêneros)
            HStack(spacing: 0) {
                tabButton(
                    title: "Jogos",
                    icon: "gamecontroller.fill",
                    isSelected: selectedTab == .jogos
                ) {
                    selectedTab = .jogos
                }
                
                tabButton(
                    title: "Gêneros",
                    icon: "line.3.horizontal.decrease",
                    isSelected: selectedTab == .generos
                ) {
                    selectedTab = .generos
                }
            }
            .padding(4)
            .background(Color.pillBackground)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
            
            Spacer()
            
            // Botão Circular de Pesquisa
            Button {
                selectedTab = .pesquisa
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selectedTab == .pesquisa ? .activeGreen : .black)
                    .frame(width: 56, height: 56)
                    .background(Color.pillBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    private func tabButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isSelected ? .activeGreen : .black)
            .frame(width: 95, height: 48)
            .background(isSelected ? Color.black.opacity(0.12) : Color.clear)
            .clipShape(Capsule())
        }
    }
}