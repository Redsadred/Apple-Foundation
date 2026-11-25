import Foundation

// Dados de exemplo usados quando o token do Notion não está configurado
// ou quando a API não responde. Assim a interface nunca fica vazia.
enum SampleData {
    private static func shots(_ seed: String) -> [String] {
        (1...3).map { "https://picsum.photos/seed/\(seed)-\($0)/600/340" }
    }

    private static func thumb(_ seed: String) -> String {
        "https://picsum.photos/seed/\(seed)/400/230"
    }

    static let games: [Game] = [
        Game(
            id: "sample-stardew",
            title: "Stardew Valley",
            fullTitle: "Stardew Valley",
            rating: 4.8,
            thumbnailURL: thumb("stardew"),
            screenshotsURL: shots("stardew"),
            developer: "ConcernedApe",
            publisher: "ConcernedApe",
            platforms: [
                PlatformItem(id: "p1", name: "App Store", url: "https://apps.apple.com/app/stardew-valley/id1455302923")
            ],
            releaseDate: "24/05/2017",
            description: "Você herda a velha fazenda do avô e começa uma nova vida na cidade. Plante colheitas, crie animais, minere, pesque e faça amigos com os moradores da cidade.",
            ageRating: "12",
            storeURL: "https://apps.apple.com/app/stardew-valley/id1455302923",
            genres: ["Simulação", "Indie", "Casual", "Estratégia"],
            section: .populares
        ),
        Game(
            id: "sample-hades",
            title: "Hades",
            fullTitle: "Hades",
            rating: 4.9,
            thumbnailURL: thumb("hades"),
            screenshotsURL: shots("hades"),
            developer: "Supergiant Games",
            publisher: "Supergiant Games",
            platforms: [
                PlatformItem(id: "p2", name: "App Store", url: "https://apps.apple.com/app/hades/id1449835057")
            ],
            releaseDate: "17/09/2020",
            description: "Desafie o deus dos mortos em um roguelike de ação onde cada corrida é única e a história evolui a cada tentativa.",
            ageRating: "16",
            storeURL: "https://apps.apple.com/app/hades/id1449835057",
            genres: ["Ação", "Aventura", "Indie"],
            section: .populares
        ),
        Game(
            id: "sample-civ",
            title: "Civilization VI",
            fullTitle: "Civilization VI",
            rating: 4.3,
            thumbnailURL: thumb("civ6"),
            screenshotsURL: shots("civ6"),
            developer: "Firaxis Games",
            publisher: "2K",
            platforms: [
                PlatformItem(id: "p3", name: "App Store", url: "https://apps.apple.com/app/civilization-vi/id1449835058")
            ],
            releaseDate: "11/10/2017",
            description: "Construa um império para resistir ao teste do tempo. Explore o mundo, pesquise tecnologias, conduza diplomacia e derrote os rivais.",
            ageRating: "12",
            storeURL: "https://apps.apple.com/app/civilization-vi/id1449835058",
            genres: ["Estratégia", "Simulação"],
            section: .populares
        ),
        Game(
            id: "sample-ghost",
            title: "Ghost Trick",
            fullTitle: "Ghost Trick: Phantom Detective",
            rating: 4.7,
            thumbnailURL: thumb("ghosttrick"),
            screenshotsURL: shots("ghosttrick"),
            developer: "Capcom",
            publisher: "Capcom",
            platforms: [
                PlatformItem(id: "p4", name: "App Store", url: "https://apps.apple.com/app/ghost-trick/id1449835059")
            ],
            releaseDate: "30/04/2010",
            description: "Você é um fantasma com poderes especiais. Investigue o próprio assassinato e salve vidas manipulando objetos do mundo dos vivos.",
            ageRating: "12",
            storeURL: "https://apps.apple.com/app/ghost-trick/id1449835059",
            genres: ["Aventura", "Estratégia", "Indie"],
            section: .populares
        ),
        Game(
            id: "sample-monument",
            title: "Monument Valley",
            fullTitle: "Monument Valley",
            rating: 4.6,
            thumbnailURL: thumb("monument"),
            screenshotsURL: shots("monument"),
            developer: "ustwo games",
            publisher: "ustwo games",
            platforms: [
                PlatformItem(id: "p5", name: "App Store", url: "https://apps.apple.com/app/monument-valley/id728293409")
            ],
            releaseDate: "17/04/2014",
            description: "Guiada por silênciosas princesas, resolva arquiteturas impossíveis e enigmas óticos em um mundo de ilusões.",
            ageRating: "L",
            storeURL: "https://apps.apple.com/app/monument-valley/id728293409",
            genres: ["Indie", "Estratégia", "Casual"],
            section: .populares
        ),
        Game(
            id: "sample-slay",
            title: "Slay the Spire",
            fullTitle: "Slay the Spire",
            rating: 4.8,
            thumbnailURL: thumb("slayspire"),
            screenshotsURL: shots("slayspire"),
            developer: "Mega Crit",
            publisher: "Mega Crit",
            platforms: [
                PlatformItem(id: "p6", name: "App Store", url: "https://apps.apple.com/app/slay-the-spire/id1449835060")
            ],
            releaseDate: "15/01/2019",
            description: "Combine cartas poderosas, derrote inimigos e suba a torre em um deck-builder cheio de estratégias.",
            ageRating: "12",
            storeURL: "https://apps.apple.com/app/slay-the-spire/id1449835060",
            genres: ["Jogo de cartas", "Estratégia", "Indie"],
            section: .populares
        ),
        Game(
            id: "sample-balatro",
            title: "Balatro",
            fullTitle: "Balatro",
            rating: 4.9,
            thumbnailURL: thumb("balatro"),
            screenshotsURL: shots("balatro"),
            developer: "LocalThunk",
            publisher: "Playstack",
            platforms: [
                PlatformItem(id: "p7", name: "App Store", url: "https://apps.apple.com/app/balatro/id6453958888")
            ],
            releaseDate: "05/11/2026",
            description: "Um jogo de pôquer rogue-like. Crie combinações absurdas, desbloqueie jokers e supere as apostas mais difíceis.",
            ageRating: "16",
            storeURL: "https://apps.apple.com/app/balatro/id6453958888",
            genres: ["Jogo de cartas", "Estratégia", "Arcade", "Indie"],
            section: .novos
        ),
        Game(
            id: "sample-wilds",
            title: "Monster Hunter Wilds",
            fullTitle: "Monster Hunter Wilds",
            rating: 4.5,
            thumbnailURL: thumb("wilds"),
            screenshotsURL: shots("wilds"),
            developer: "Capcom",
            publisher: "Capcom",
            platforms: [
                PlatformItem(id: "p8", name: "App Store", url: "https://apps.apple.com/app/monster-hunter-wilds/id6453958889")
            ],
            releaseDate: "28/11/2026",
            description: "Explore terras selvagens em constante transformação, rastreie monstros colossais e forje armas com os materiais coletados.",
            ageRating: "16",
            storeURL: "https://apps.apple.com/app/monster-hunter-wilds/id6453958889",
            genres: ["Ação", "Aventura", "Survival"],
            section: .novos
        ),
        Game(
            id: "sample-cozy",
            title: "Cozy Grove",
            fullTitle: "Cozy Grove: New Horizons",
            rating: 4.4,
            thumbnailURL: thumb("cozygrove"),
            screenshotsURL: shots("cozygrove"),
            developer: "Spry Fox",
            publisher: "Spry Fox",
            platforms: [
                PlatformItem(id: "p9", name: "App Store", url: "https://apps.apple.com/app/cozy-grove/id1510738634")
            ],
            releaseDate: "18/10/2026",
            description: "Acampa em uma ilha encantada cheia de fantasmas fofos. Decore, pesque e ajude os espíritos a encontrarem a paz.",
            ageRating: "L",
            storeURL: "https://apps.apple.com/app/cozy-grove/id1510738634",
            genres: ["Casual", "Simulação", "Indie"],
            section: .novos
        ),
        Game(
            id: "sample-hollow",
            title: "Hollow Knight: Silksong",
            fullTitle: "Hollow Knight: Silksong",
            rating: 4.9,
            thumbnailURL: thumb("silksong"),
            screenshotsURL: shots("silksong"),
            developer: "Team Cherry",
            publisher: "Team Cherry",
            platforms: [
                PlatformItem(id: "p10", name: "App Store", url: "https://apps.apple.com/app/hollow-knight-silksong/id6453958890")
            ],
            releaseDate: "15/04/2027",
            description: "Suba como Hornet, princesa e caçadora, em uma nova aventura por reinos infestados de pragas e segredos.",
            ageRating: "12",
            storeURL: "https://apps.apple.com/app/hollow-knight-silksong/id6453958890",
            genres: ["Ação", "Aventura", "Plataforma", "Indie"],
            section: .emBreve
        ),
        Game(
            id: "sample-frostpunk",
            title: "Frostpunk 2",
            fullTitle: "Frostpunk 2",
            rating: 4.6,
            thumbnailURL: thumb("frostpunk2"),
            screenshotsURL: shots("frostpunk2"),
            developer: "11 bit studios",
            publisher: "11 bit studios",
            platforms: [
                PlatformItem(id: "p11", name: "App Store", url: "https://apps.apple.com/app/frostpunk-2/id6453958891")
            ],
            releaseDate: "20/02/2027",
            description: "Construa e governa uma cidade em um mundo congelado. Decisões morais difíceis definem o destino dos seus cidadãos.",
            ageRating: "16",
            storeURL: "https://apps.apple.com/app/frostpunk-2/id6453958891",
            genres: ["Estratégia", "Simulação", "Survival"],
            section: .emBreve
        ),
        Game(
            id: "sample-scooter",
            title: "ScooterBoy Rush",
            fullTitle: "ScooterBoy Rush",
            rating: 4.1,
            thumbnailURL: thumb("scooterboy"),
            screenshotsURL: shots("scooterboy"),
            developer: "Nimble Studio",
            publisher: "Nimble Studio",
            platforms: [
                PlatformItem(id: "p12", name: "App Store", url: "https://apps.apple.com/app/scooterboy-rush/id6453958892")
            ],
            releaseDate: "10/03/2027",
            description: "Corra de patinete pelas ruas da cidade, desvie de obstáculos e desbloqueie novos personagens e trilhas.",
            ageRating: "L",
            storeURL: "https://apps.apple.com/app/scooterboy-rush/id6453958892",
            genres: ["Arcade", "Esporte", "Casual", "Scooter"],
            section: .emBreve
        )
    ]
}
