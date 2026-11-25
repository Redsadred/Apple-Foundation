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

    // Credencial lida da variável de ambiente BEARER_TOKEN e IDs dos bancos do Notion
    private var notionToken: String {
        (ProcessInfo.processInfo.environment["BEARER_TOKEN"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private let apiVersion = "2026-03-11"
    private let gamesDatabaseId = "410aa772600e808a85aedcf158552c21"
    private let developersDatabaseId = "410aa772600e802580f5c0777656ed1a"
    private let publishersDatabaseId = "414aa772600e8059a8acd490922e07cf"
    private let platformsDatabaseId = "414aa772600e8076b307c2fb0efc1682"

    // Gêneros alinhados com o banco de dados do Notion
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
        guard isTokenConfigured else {
            games = SampleData.games
            errorMessage = "Variável BEARER_TOKEN não configurada no Scheme. Exibindo jogos de exemplo."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1. Busca os 4 bancos de dados em paralelo
            async let gamesTask = queryDatabase(databaseId: gamesDatabaseId, type: NotionGamePage.self)
            async let devsTask = (try? queryDatabase(databaseId: developersDatabaseId, type: NotionEntityPage.self)) ?? []
            async let pubsTask = (try? queryDatabase(databaseId: publishersDatabaseId, type: NotionEntityPage.self)) ?? []
            async let platsTask = (try? queryDatabase(databaseId: platformsDatabaseId, type: NotionEntityPage.self)) ?? []

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
            if games.isEmpty {
                games = SampleData.games
            }
        }
    }

    private var isTokenConfigured: Bool {
        !notionToken.isEmpty && notionToken != "BEARER_TOKEN"
    }

    // MARK: - Chamada Genérica à API do Notion (Versão 2026-03-11)
    private func queryDatabase<T: Decodable>(databaseId: String, type: T.Type) async throws -> [T] {
        // Passo 1: Resolve database_id -> data_source_id
        let dataSourceId = try await resolveDataSourceId(for: databaseId)

        // Passo 2: Consulta as páginas no data_source
        guard let url = URL(string: "https://api.notion.com/v1/data_sources/\(dataSourceId)/query") else {
            throw URLError(.badURL)
        }

        var request = makeRequest(url: url, method: "POST")
        request.httpBody = Data("{}".utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(NotionQueryResponse<T>.self, from: data)
        return decoded.results
    }

    private func resolveDataSourceId(for databaseId: String) async throws -> String {
        guard let url = URL(string: "https://api.notion.com/v1/databases/\(databaseId)") else {
            throw URLError(.badURL)
        }

        let request = makeRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let dbInfo = try JSONDecoder().decode(NotionDatabaseInfo.self, from: data)
        guard let firstSource = dbInfo.dataSources.first else {
            throw NSError(
                domain: "NotionAPI",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Nenhum data_source encontrado no banco \(databaseId)."]
            )
        }
        return firstSource.id
    }

    private func makeRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(notionToken)", forHTTPHeaderField: "Authorization")
        request.addValue(apiVersion, forHTTPHeaderField: "Notion-Version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validate(response: URLResponse, data: Data) throws {
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "NotionAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: body])
        }
    }

    // MARK: - Mapeamento de Propriedades
    private func mapToGame(
        page: NotionGamePage,
        devMap: [String: NotionEntityProperties],
        pubMap: [String: NotionEntityProperties],
        platMap: [String: NotionEntityProperties]
    ) -> Game {
        let props = page.properties

        let fullTitle = props.nome?.title.map(\.plainText).joined() ?? "Sem Título"
        let shortTitle = fullTitle.count > 18 ? String(fullTitle.prefix(15)) + "..." : fullTitle

        let imageURLs = props.foto?.files.compactMap { $0.url } ?? []
        let thumbnail = imageURLs.first ?? ""
        let screenshots = imageURLs.count > 1 ? Array(imageURLs.dropFirst()) : imageURLs

        let developerNames = (props.desenvolvedora?.relation ?? [])
            .compactMap { devMap[$0.id]?.nomeText }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        let publisherNames = (props.distribuidora?.relation ?? [])
            .compactMap { pubMap[$0.id]?.nomeText }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        let resolvedPlatforms: [PlatformItem] = (props.plataformas?.relation ?? []).compactMap { rel in
            guard let plat = platMap[rel.id], !plat.nomeText.isEmpty else { return nil }
            return PlatformItem(id: rel.id, name: plat.nomeText, url: plat.urlText)
        }

        let primaryStoreURL = resolvedPlatforms.first(where: { !$0.url.isEmpty })?.url ?? ""
        let synopsis = props.sinopse?.richText.map(\.plainText).joined() ?? ""

        let rawDate = props.dataDeLancamento?.date?.start ?? ""
        let formattedDate = formatNotionDate(rawDate)

        let ageRating = props.classificacao?.stringValue ?? "L"
        let rating = props.avaliacao?.numericValue ?? 0.0
        let gameGenres = props.genero?.multiSelect.map(\.name) ?? []
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
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
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
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        if let releaseDate = formatter.date(from: String(rawDate.prefix(10))) {
            if releaseDate > Date() {
                return .emBreve
            }
            if let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date()),
               releaseDate >= sixtyDaysAgo {
                return .novos
            }
        }
        return .populares
    }
}

// MARK: - Structs de Decodificação da API do Notion
nonisolated struct NotionDatabaseInfo: Decodable {
    let dataSources: [DataSourceRef]

    struct DataSourceRef: Decodable {
        let id: String
    }

    enum CodingKeys: String, CodingKey {
        case dataSources = "data_sources"
    }
}

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
