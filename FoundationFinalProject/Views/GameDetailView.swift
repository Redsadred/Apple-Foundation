import SwiftUI

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
