import Foundation
import SwiftData

@Model
final class BreedAssignment {
    var id: UUID
    var breedName: String
    var count: Int
    var time: Date
    var ring: Int
    var notes: String?
    var show: Show?
    
    init(breedName: String, count: Int, time: Date, ring: Int, notes: String? = nil, show: Show? = nil) {
        self.id = UUID()
        self.breedName = breedName
        self.count = count
        self.time = time
        self.ring = ring
        self.notes = notes
        self.show = show
    }
} 