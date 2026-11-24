import SwiftUI

// Cores exatas baseadas nas suas telas
extension Color {
    static let appBackground = Color(red: 43/255, green: 48/255, blue: 58/255)   // #2B303A
    static let cardDark = Color(red: 32/255, green: 36/255, blue: 44/255)        // #20242C
    static let pillBackground = Color(red: 158/255, green: 163/255, blue: 170/255)
    static let activeGreen = Color(red: 46/255, green: 92/255, blue: 32/255)
}

enum GameCategory: String, CaseIterable, Identifiable {
    case populares = "Populares"
    case novos = "Novos"
    case emBreve = "Em Breve"
    
    var id: String { rawValue }
}

struct GenreItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String // Nome da imagem nos Assets ou URL
}

struct Game: Identifiable, Hashable {
    let id: String
    let title: String
    let fullTitle: String
    let rating: Double
    let thumbnailURL: String
    let screenshotsURL: [String]
    let developer: String
    let publisher: String
    let releaseDate: String
    let description: String
    let ageRating: String
    let storeURL: String
    let genres: [String]
    let section: GameCategory
}