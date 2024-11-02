import Foundation
import SwiftUI

class BreedService {
    static let shared = BreedService()
    private var breedGroups: [BreedGroup] = []
    
    init() {
        loadBreeds()
    }
    
    func loadBreeds() {
        if let path = Bundle.main.path(forResource: "breeds", ofType: "json") {
            print("Found breeds.json at path:", path)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                print("Successfully loaded data, size:", data.count)
                let decoder = JSONDecoder()
                let breedData = try decoder.decode(BreedData.self, from: data)
                
                self.breedGroups = breedData.groups.map { group in
                    BreedGroup(
                        name: group.name,
                        description: group.description,
                        breeds: group.breeds.map { breedName in
                            AKCBreed(
                                name: breedName,
                                group: group.name,
                                generalAppearance: nil,
                                size: nil,
                                proportion: nil,
                                gait: nil,
                                temperament: nil,
                                judgingTips: nil,
                                commonIssues: nil
                            )
                        },
                        judgingEmphasis: group.judgingEmphasis
                    )
                }
                print("Successfully loaded \(breedGroups.count) breed groups with \(breedGroups.flatMap { $0.breeds }.count) total breeds")
            } catch {
                print("Error loading breeds: \(error)")
                self.breedGroups = []
            }
        } else {
            print("Could not find breeds.json in bundle")
            self.breedGroups = []
        }
    }
    
    func searchBreeds(_ query: String) -> [AKCBreed] {
        guard !query.isEmpty else { return [] }
        let results = breedGroups.flatMap { $0.breeds }.filter { breed in
            breed.name.localizedCaseInsensitiveContains(query)
        }
        print("Search query '\(query)' returned \(results.count) results")
        return results
    }
    
    func getBreedGroups() -> [BreedGroup] {
        print("Returning \(breedGroups.count) breed groups")
        return breedGroups
    }
    
    func getBreedsByGroup() -> [String: [AKCBreed]] {
        let result = Dictionary(grouping: breedGroups.flatMap { $0.breeds }) { $0.group }
        print("Returning breeds grouped by \(result.keys.count) groups")
        return result
    }
}

struct BreedData: Codable {
    let groups: [GroupData]
}

struct GroupData: Codable {
    let name: String
    let description: String
    let judgingEmphasis: String
    let breeds: [String]
} 