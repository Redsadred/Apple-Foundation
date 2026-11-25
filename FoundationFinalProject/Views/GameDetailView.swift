import SwiftUI

struct GameDetailView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @State private var isDescriptionExpanded = false
    @State private var sharePreviewImage: Image?
    
    // Estados para o zoom centralizado da imagem
    @State private var selectedScreenshotURL: String?
    @State private var zoomScale: CGFloat = 1.0
    
    // Define se a sinopse é longa o suficiente para precisar do botão "..."
    private var isLongDescription: Bool {
        game.description.count > 160
    }
    
    // Preview usado na folha de compartilhamento (Nome + Imagem ao lado)
    private var sharePreview: SharePreview<Image, Never> {
        if let sharePreviewImage {
            return SharePreview(game.fullTitle, image: sharePreviewImage)
        } else {
            return SharePreview(game.fullTitle, image: Image(systemName: "gamecontroller.fill"))
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // HEADER COM BOTÃO VOLTAR E ÍCONE DE COMPARTILHAR
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
                        
                        // Ícone de compartilhar (3 bolinhas conectadas) com preview da imagem
                        if let shareURL = URL(string: game.storeURL), !game.storeURL.isEmpty {
                            ShareLink(
                                item: shareURL,
                                subject: Text(game.fullTitle),
                                message: Text("Confira \(game.fullTitle)!"),
                                preview: sharePreview
                            ) {
                                shareIconButton
                            }
                        } else {
                            ShareLink(
                                item: "\(game.fullTitle)\n\n\(game.description)",
                                preview: sharePreview
                            ) {
                                shareIconButton
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // NOME DO JOGO LOGO ACIMA DA IMAGEM
                    Text(game.fullTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    
                    // CARROSSEL DE SCREENSHOTS (CLICÁVEL PARA ZOOM)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(game.screenshotsURL.enumerated()), id: \.offset) { _, urlString in
                                let cleanURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                AsyncImage(url: URL(string: cleanURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Color.cardDark
                                    }
                                }
                                .frame(width: 240, height: 145)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    zoomScale = 1.0
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                        selectedScreenshotURL = cleanURL
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // FAIXA ETÁRIA E CLASSIFICAÇÃO LOGO ABAIXO DAS IMAGENS
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", game.rating))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text(game.ageRating)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(ageRatingColor(for: game.ageRating))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 16)
                    
                    // SINOPSE COM EXPANSÃO NOS TRÊS PONTINHOS ("...")
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .lineLimit(isDescriptionExpanded ? nil : 4)
                        
                        if isLongDescription {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isDescriptionExpanded.toggle()
                                }
                            } label: {
                                Text(isDescriptionExpanded ? "ver menos" : "...")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .padding(.top, 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // DESENVOLVEDOR, DISTRIBUIDORA E DATA DE LANÇAMENTO ABAIXO DA SINOPSE
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(label: "Desenvolvedor:", value: game.developer, isLink: true)
                        infoRow(label: "Distribuidora:", value: game.publisher, isLink: true)
                        infoRow(label: "Data de lançamento:", value: game.releaseDate, isLink: false)
                    }
                    .padding(.horizontal, 16)
                    
                    // BOTÃO ONDE COMPRAR
                    if let url = URL(string: game.storeURL), !game.storeURL.isEmpty {
                        HStack {
                            Spacer()
                            Link(destination: url) {
                                Text("Onde comprar")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 26)
                                    .padding(.vertical, 12)
                                    .background(Color.cardDark)
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color.appBackground.ignoresSafeArea())
            
            // OVERLAY DE ZOOM CENTRALIZADO NO MEIO DA TELA
            if let zoomedURL = selectedScreenshotURL {
                ZStack {
                    Color.black.opacity(0.88)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeZoom()
                        }
                    
                    AsyncImage(url: URL(string: zoomedURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 16)
                                .scaleEffect(zoomScale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            zoomScale = max(1.0, min(value, 3.0))
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                zoomScale = 1.0
                                            }
                                        }
                                )
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        default:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Botão fechar no canto superior direito
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                closeZoom()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 38, height: 38)
                                    .background(Color.pillBackground)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 16)
                        }
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadSharePreviewImage()
        }
    }
    
    private func closeZoom() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedScreenshotURL = nil
            zoomScale = 1.0
        }
    }
    
    // Baixa a thumbnail (ou pega dos Assets) e converte para SwiftUI Image
    private func loadSharePreviewImage() async {
        let cleanURL = game.thumbnailURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanURL.isEmpty else { return }
        
        if let url = URL(string: cleanURL), cleanURL.hasPrefix("http") {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let uiImage = UIImage(data: data) {
                sharePreviewImage = Image(uiImage: uiImage)
            }
        } else {
            sharePreviewImage = Image(cleanURL)
        }
    }
    
    // Visual do botão de compartilhar no topo (3 bolinhas conectadas)
    private var shareIconButton: some View {
        Image(systemName: "point.3.connected.trianglepath.dotted")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 40, height: 40)
            .background(Color.pillBackground)
            .clipShape(Circle())
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
    
    // Cor automática para o selo de classificação indicativa brasileira
    private func ageRatingColor(for rating: String) -> Color {
        switch rating.uppercased() {
        case "L", "LIVRE": return .green
        case "10": return .blue
        case "12": return .yellow
        case "14": return .orange
        case "16": return .red
        case "18": return .black
        default: return .orange
        }
    }
}
