import SwiftUI
import UIKit

struct GameCardView: View {
    let game: Game
    var width: CGFloat = 175

    var body: some View {
        NavigationLink(value: game) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: game.thumbnailURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color.cardDark)
                            .overlay(
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white.opacity(0.35))
                            )
                    default:
                        Rectangle()
                            .fill(Color.cardDark)
                            .overlay(ProgressView().tint(.white))
                    }
                }
                .frame(width: width, height: width * 0.58)
                .clipShape(RoundedRectangle(cornerRadius: 12))

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

struct GenreCardView: View {
    let genre: GenreItem

    var body: some View {
        NavigationLink(value: genre) {
            ZStack(alignment: .leading) {
                Color.cardDark

                HStack {
                    Spacer()
                    genreArtwork
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

    @ViewBuilder
    private var genreArtwork: some View {
        if UIImage(named: genre.imageName) != nil {
            Image(genre.imageName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.white.opacity(0.16), Color.white.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: genre.iconName)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }
}

enum AppTab {
    case jogos, generos, pesquisa
}

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 0) {
                tabButton(title: "Jogos", icon: "gamecontroller.fill", isSelected: selectedTab == .jogos) {
                    selectedTab = .jogos
                }

                tabButton(title: "Gêneros", icon: "line.3.horizontal.decrease", isSelected: selectedTab == .generos) {
                    selectedTab = .generos
                }
            }
            .padding(4)
            .background(Color.pillBackground)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.35), radius: 10, y: 5)

            Spacer()

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
