import Foundation
import Combine

// Os modelos Game, GenreItem e PlatformItem vivem em GameModels.swift
// (fonte única de verdade para evitar redeclaração duplicada).

// MARK: - ViewModel
@MainActor
class NotionViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Suas credenciais e IDs dos bancos do Notion
    private let notionToken = "BEARER_TOKEN"
    private let gamesDatabaseId = "410aa772600e808a85aedcf158552c21"
    private let developersDatabaseId = "410aa772600e802580f5c0777656ed1a"
    private let publishersDatabaseId = "414aa772600e8059a8acd490922e07cf"
    private let platformsDatabaseId = "414aa772600e8076b307c2fb0efc1682"
    
    // Gêneros alinhados com o banco de dados do Notion
    // (iconName = SF Symbol usado caso a imagem não exista nos Assets)
    let genres: [GenreItem] = [
        GenreItem(name: "Casual", imageName: "genre_casual", iconName: "face.smiling"),
        GenreItem(name: "Indie", imageName: "genre_indie", iconName: "paintbrush.pointed"),
        GenreItem(name: "Simulação", imageName: "genre_simulacao", iconName: "slider.horizontal.3"),
        GenreItem(name: "Estratégia", imageName: "genre_estrategia", iconName: "chessboard"),
        GenreItem(name: "Jogo de cartas", imageName: "genre_cartas", iconName: "rectangle.on.rectangle"),
        GenreItem(name: "Esporte", imageName: "genre_esporte", iconName: "figure.run"),
        GenreItem(name: "Arcade", imageName: "genre_arcade", iconName: "gamecontroller.fill"),
        GenreItem(name: "Horror", imageName: "genre_horror", iconName: "mask.face"),
        GenreItem(name: "Survival", imageName: "genre_survival", iconName: "flame.fill"),
        GenreItem(name: "Ação", imageName: "genre_acao", iconName: "bolt.fill"),
        GenreItem(name: "Aventura", imageName: "genre_aventura", iconName: "map.fill"),
        GenreItem(name: "Plataforma", imageName: "genre_plataforma", iconName: "square.stack.3d.up")
    ]
    
    init() {
        Task { await fetchGamesFromNotion() }
    }
    
    func fetchGamesFromNotion() async {
        // Sem token configurado não adianta chamar a API: usa os dados de exemplo
        // para que a interface continue funcionando.
        guard isTokenConfigured else {
            games = SampleData.games
            errorMessage = "Token do Notion não configurado. Exibindo jogos de exemplo."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // 1. Busca os 4 bancos de dados em paralelo
            async let gamesTask = queryDatabase(id: gamesDatabaseId, type: NotionGamePage.self)
            async let devsTask = queryDatabase(id: developersDatabaseId, type: NotionEntityPage.self)
            async let pubsTask = queryDatabase(id: publishersDatabaseId, type: NotionEntityPage.self)
            async let platsTask = queryDatabase(id: platformsDatabaseId, type: NotionEntityPage.self)
            
            let (gamePages, devPages, pubPages, platPages) = try await (gamesTask, devsTask, pubsTask, platsTask)
            
            // 2. Cria dicionários de lookup (ID -> Nome e URL) para resolver as relações
            let devMap = Dictionary(uniqueKeysWithValues: devPages.map { ($0.id, $0.properties) })
            let pubMap = Dictionary(uniqueKeysWithValues: pubPages.map { ($0.id, $0.properties) })
            let platMap = Dictionary(uniqueKeysWithValues: platPages.map { ($0.id, $0.properties) })
            
            // 3. Mapeia cada página do Notion para o struct Game
            self.games = gamePages.map { page in
                mapToGame(page: page, devMap: devMap, pubMap: pubMap, platMap: platMap)
            }
            
        } catch {
            self.errorMessage = "Erro ao buscar no Notion: \(error.localizedDescription)"
            print("Erro ao buscar no Notion: \(error)")
            // Mantém a interface utilizável mesmo com a API indisponível
            if games.isEmpty {
                games = SampleData.games
            }
        }
    }

    // O token real deve ser colocado aqui (ou lido de Info.plist / Secret)
    private var isTokenConfigured: Bool {
        let trimmed = notionToken.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != "BEARER_TOKEN"
    }
    
    // MARK: - Chamada Genérica à API do Notion
    private func queryDatabase<T: Decodable>(id: String, type: T.Type) async throws -> [T] {
        guard let url = URL(string: "https://api.notion.com/v1/databases/\(id)/query") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(notionToken)", forHTTPHeaderField: "Authorization")
        request.addValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "NotionAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: body])
        }
        
        let decoded = try JSONDecoder().decode(NotionQueryResponse<T>.self, from: data)
        return decoded.results
    }
    
    // MARK: - Mapeamento de Propriedades
    private func mapToGame(
        page: NotionGamePage,
        devMap: [String: NotionEntityProperties],
        pubMap: [String: NotionEntityProperties],
        platMap: [String: NotionEntityProperties]
    ) -> Game {
        let props = page.properties
        
        // Nome
        let fullTitle = props.nome?.title.map(\.plainText).joined() ?? "Sem Título"
        let shortTitle = fullTitle.count > 18 ? String(fullTitle.prefix(15)) + "..." : fullTitle
        
        // Foto (Capa = primeira imagem; Screenshots = demais imagens anexadas)
        let imageURLs = props.foto?.files.compactMap { $0.url } ?? []
        let thumbnail = imageURLs.first ?? ""
        let screenshots = imageURLs.count > 1 ? Array(imageURLs.dropFirst()) : imageURLs
        
        // Relações: Desenvolvedora e Distribuidora
        let developerNames = (props.desenvolvedora?.relation ?? [])
            .compactMap { devMap[$0.id]?.nomeText }
            .joined(separator: ", ")
        
        let publisherNames = (props.distribuidora?.relation ?? [])
            .compactMap { pubMap[$0.id]?.nomeText }
            .joined(separator: ", ")
        
        // Relação: Plataformas (Nome + URL)
        let resolvedPlatforms: [PlatformItem] = (props.plataformas?.relation ?? []).compactMap { rel in
            guard let plat = platMap[rel.id] else { return nil }
            return PlatformItem(id: rel.id, name: plat.nomeText, url: plat.urlText)
        }
        
        // URL principal da loja (pega a URL da primeira plataforma vinculada, se houver)
        let primaryStoreURL = resolvedPlatforms.first(where: { !$0.url.isEmpty })?.url ?? ""
        
        // Sinopse
        let synopsis = props.sinopse?.richText.map(\.plainText).joined() ?? ""
        
        // Data de Lançamento
        let rawDate = props.dataDeLancamento?.date?.start ?? ""
        let formattedDate = formatNotionDate(rawDate)
        
        // Classificação Indicativa (suporta propriedade Select, RichText ou Number)
        let ageRating = props.classificacao?.stringValue ?? "L"
        
        // Avaliação (suporta Number ou Select)
        let rating = props.avaliacao?.numericValue ?? 0.0
        
        // Gêneros (Multi-select)
        let gameGenres = props.genero?.multiSelect.map(\.name) ?? []
        
        // Define a seção automaticamente
        let section = determineSection(rawDate: rawDate, rating: rating)
        
        return Game(
            id: page.id,
            title: shortTitle,
            fullTitle: fullTitle,
            rating: rating,
            thumbnailURL: thumbnail,
            screenshotsURL: screenshots,
            developer: developerNames.isEmpty ? "Desconhecida" : developerNames,
            publisher: publisherNames.isEmpty ? "Independente" : publisherNames,
            platforms: resolvedPlatforms,
            releaseDate: formattedDate,
            description: synopsis,
            ageRating: ageRating,
            storeURL: primaryStoreURL,
            genres: gameGenres,
            section: section
        )
    }
    
    // MARK: - Helpers de Data e Seção
    private func formatNotionDate(_ isoString: String) -> String {
        guard !isoString.isEmpty else { return "Em breve" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: String(isoString.prefix(10))) else {
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "pt_BR")
        outputFormatter.dateFormat = "dd/MMM/yyyy"
        return outputFormatter.string(from: date).lowercased()
    }
    
    private func determineSection(rawDate: String, rating: Double) -> GameSection {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let releaseDate = formatter.date(from: String(rawDate.prefix(10))) {
            if releaseDate > Date() {
                return .emBreve
            }
            // Lançados nos últimos 60 dias vão para "Novos"
            if let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date()),
               releaseDate >= sixtyDaysAgo {
                return .novos
            }
        }
        return .populares
    }
}

// MARK: - Structs de Decodificação da API do Notion
nonisolated struct NotionQueryResponse<T: Decodable>: Decodable {
    let results: [T]
}

nonisolated struct NotionGamePage: Decodable {
    let id: String
    let properties: NotionGameProperties
}

nonisolated struct NotionGameProperties: Decodable {
    let nome: NotionTitleProperty?
    let foto: NotionFilesProperty?
    let desenvolvedora: NotionRelationProperty?
    let distribuidora: NotionRelationProperty?
    let plataformas: NotionRelationProperty?
    let sinopse: NotionRichTextProperty?
    let dataDeLancamento: NotionDateProperty?
    let classificacao: NotionFlexibleValueProperty?
    let avaliacao: NotionFlexibleValueProperty?
    let genero: NotionMultiSelectProperty?
    
    enum CodingKeys: String, CodingKey {
        case nome = "Nome"
        case foto = "Foto"
        case desenvolvedora = "Desenvolvedora"
        case distribuidora = "Distribuidora"
        case plataformas = "Plataformas"
        case sinopse = "Sinopse"
        case dataDeLancamento = "Data de lançamento"
        case classificacao = "Classificação"
        case avaliacao = "Avaliação"
        case genero = "Gênero"
    }
}

// Bancos Auxiliares: Desenvolvedora, Distribuidora e Plataformas
nonisolated struct NotionEntityPage: Decodable {
    let id: String
    let properties: NotionEntityProperties
}

nonisolated struct NotionEntityProperties: Decodable {
    let nome: NotionTitleProperty?
    let urlProp: NotionFlexibleURLProperty?
    
    var nomeText: String {
        nome?.title.map(\.plainText).joined() ?? ""
    }
    
    var urlText: String {
        urlProp?.value ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case nome = "Nome"
        case urlProp = "URL"
    }
}

// MARK: - Tipos de Propriedades do Notion
nonisolated struct NotionTitleProperty: Decodable {
    let title: [NotionTextItem]
}

nonisolated struct NotionRichTextProperty: Decodable {
    let richText: [NotionTextItem]
    enum CodingKeys: String, CodingKey {
        case richText = "rich_text"
    }
}

nonisolated struct NotionTextItem: Decodable {
    let plainText: String
    enum CodingKeys: String, CodingKey {
        case plainText = "plain_text"
    }
}

nonisolated struct NotionRelationProperty: Decodable {
    let relation: [NotionRelationItem]
}

nonisolated struct NotionRelationItem: Decodable {
    let id: String
}

nonisolated struct NotionFilesProperty: Decodable {
    let files: [NotionFileItem]
}

nonisolated struct NotionFileItem: Decodable {
    let file: NotionFileURL?
    let external: NotionFileURL?
    
    var url: String? {
        file?.url ?? external?.url
    }
}

nonisolated struct NotionFileURL: Decodable {
    let url: String
}

nonisolated struct NotionDateProperty: Decodable {
    let date: NotionDateValue?
}

nonisolated struct NotionDateValue: Decodable {
    let start: String
}

nonisolated struct NotionMultiSelectProperty: Decodable {
    let multiSelect: [NotionSelectOption]
    enum CodingKeys: String, CodingKey {
        case multiSelect = "multi_select"
    }
}

nonisolated struct NotionSelectOption: Decodable {
    let name: String
}

// Lida com "URL" tanto se estiver como Texto (rich_text) quanto como URL nativa no Notion
nonisolated struct NotionFlexibleURLProperty: Decodable {
    let url: String?
    let richText: [NotionTextItem]?
    
    var value: String {
        if let url, !url.isEmpty { return url }
        return richText?.map(\.plainText).joined() ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case richText = "rich_text"
    }
}

// Lida com "Classificação" e "Avaliação" independentemente de serem Number, Select ou Text no Notion
nonisolated struct NotionFlexibleValueProperty: Decodable {
    let number: Double?
    let select: NotionSelectOption?
    let richText: [NotionTextItem]?
    
    var stringValue: String? {
        if let select { return select.name }
        if let text = richText?.map(\.plainText).joined(), !text.isEmpty { return text }
        if let number { return String(format: "%.0f", number) }
        return nil
    }
    
    var numericValue: Double? {
        if let number { return number }
        if let select { return Double(select.name.replacingOccurrences(of: ",", with: ".")) }
        if let text = richText?.map(\.plainText).joined() {
            return Double(text.replacingOccurrences(of: ",", with: "."))
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case number
        case select
        case richText = "rich_text"
    }
}
