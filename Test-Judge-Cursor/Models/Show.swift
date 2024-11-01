import Foundation
import SwiftData

@Model
final class Show {
    var id: UUID
    var name: String
    var date: Date
    var location: String
    var state: String
    var eventNumber: String
    var ringNumber: Int
    var notes: String?
    var status: ShowStatus?
    @Relationship(deleteRule: .cascade) var breedAssignments: [BreedAssignment]
    
    init(name: String, date: Date, location: String, state: String, eventNumber: String, ringNumber: Int) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.location = location
        self.state = state
        self.eventNumber = eventNumber
        self.ringNumber = ringNumber
        self.notes = ""
        self.status = date > Date() ? .upcoming : .past
        self.breedAssignments = []
    }
}

enum ShowStatus: String, Codable {
    case upcoming = "Upcoming"
    case past = "Past"
} 