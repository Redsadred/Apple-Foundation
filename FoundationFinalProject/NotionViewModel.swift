import Foundation
import Combine

@MainActor
class NotionViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    
    // Suas credenciais do Notion
    private let notionToken = "SEU_TOKEN_AQUI"
    private let databaseId = "SEU_DATABASE_ID_AQUI"
    
    let genres: [GenreItem] = [
        GenreItem(name: "FPS", imageName: "genre_fps"),
        GenreItem(name: "Terror", imageName: "genre_terror"),
        GenreItem(name: "Ação", imageName: "genre_acao"),
        GenreItem(name: "RPG", imageName: "genre_rpg"),
        GenreItem(name: "Indie", imageName: "genre_indie"),
        GenreItem(name: "Casual", imageName: "genre_casual"),
        GenreItem(name: "Mistério", imageName: "genre_misterio"),
        GenreItem(name: "Co-op", imageName: "genre_coop")
    ]
    
    init() {
        loadMockData() // Carrega dados de exemplo para visualização imediata
        // Task { await fetchGamesFromNotion() } // Descomente quando configurar a API
    }
    
    func fetchGamesFromNotion() async {
        guard let url = URL(string: "https://api.notion.com/v1/databases/\(databaseId)/query") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(notionToken)", forHTTPHeaderField: "Authorization")
        request.addValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            // Aqui você faz o decode do JSON do Notion mapeando as propriedades
            // para o struct Game e atualiza self.games
            print("Dados recebidos do Notion: \(data.count) bytes")
        } catch {
            print("Erro ao buscar no Notion: \(error)")
        }
    }
    
    func loadMockData() {
        self.games = [
            Game(
                id: "1",
                title: "Capote",
                fullTitle: "Capote: Truco e Boteco",
                rating: 5.0,
                thumbnailURL: "https://picsum.photos/id/101/400/240",
                screenshotsURL: ["https://picsum.photos/id/101/500/300", "https://picsum.photos/id/102/500/300"],
                developer: "Luski Game Studio",
                publisher: "CriticalLeap",
                releaseDate: "20/ago./2026",
                description: "Jogue cartas com seus amigos ou conheça novos oponentes em um boteco brasileiro onde cada partida é um novo desafio! Teste sua estratégia em 3 modos de jogo diferentes, incluindo Capote Clássico, 21 da Bete e Truco!",
                ageRating: "14",
                storeURL: "https://store.steampowered.com",
                genres: ["Indie", "Casual", "Co-op"],
                section: .populares
            ),
            Game(
                id: "2",
                title: "Pimbolas",
                fullTitle: "Pimbolas",
                rating: 4.7,
                thumbnailURL: "https://picsum.photos/id/103/400/240",
                screenshotsURL: ["https://picsum.photos/id/103/500/300"],
                developer: "Studio Brasil",
                publisher: "IndieBR",
                releaseDate: "10/mai./2026",
                description: "Futebol arcade frenético com amigos.",
                ageRating: "L",
                storeURL: "https://store.steampowered.com",
                genres: ["Indie", "Casual"],
                section: .populares
            ),
            Game(
                id: "3",
                title: "A Investigação...",
                fullTitle: "A Investigação Póstuma",
                rating: 4.5,
                thumbnailURL: "https://picsum.photos/id/104/400/240",
                screenshotsURL: ["https://picsum.photos/id/104/500/300"],
                developer: "Noir Dev",
                publisher: "Noir Pub",
                releaseDate: "15/jun./2026",
                description: "Resolva mistérios em uma cidade sombria.",
                ageRating: "12",
                storeURL: "https://store.steampowered.com",
                genres: ["Indie", "Mistério"],
                section: .novos
            ),
            Game(
                id: "4",
                title: "Ghetto Zumbi",
                fullTitle: "Ghetto Zombies",
                rating: 4.7,
                thumbnailURL: "https://picsum.photos/id/106/400/240",
                screenshotsURL: ["https://picsum.photos/id/106/500/300"],
                developer: "Favela Games",
                publisher: "CriticalLeap",
                releaseDate: "01/set./2026",
                description: "Ação e tiros contra hordas de zumbis.",
                ageRating: "16",
                storeURL: "https://store.steampowered.com",
                genres: ["Indie", "Ação", "FPS"],
                section: .novos
            ),
            Game(
                id: "5",
                title: "Neverway",
                fullTitle: "Neverway",
                rating: 4.8,
                thumbnailURL: "https://picsum.photos/id/108/400/240",
                screenshotsURL: ["https://picsum.photos/id/108/500/300"],
                developer: "Coldblood Inc",
                publisher: "Coldblood",
                releaseDate: "12/dez./2026",
                description: "Um RPG de terror psicológico surreal.",
                ageRating: "14",
                storeURL: "https://store.steampowered.com",
                genres: ["Indie", "Terror", "RPG"],
                section: .emBreve
            )
        ]
    }
}