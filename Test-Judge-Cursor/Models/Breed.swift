import Foundation

struct AKCBreed: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let group: String
    let generalAppearance: String?
    let size: String?
    let proportion: String?
    let gait: String?
    let temperament: String?
    let judgingTips: String?
    let commonIssues: String?
    
    // Optional fields for user data
    var notes: String?
    var lastJudged: Date?
    var totalJudged: Int?
    var averageEntries: Double?
}

struct BreedGroup: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let breeds: [AKCBreed]
    let judgingEmphasis: String
} 