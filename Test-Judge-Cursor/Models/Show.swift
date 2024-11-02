import Foundation
import SwiftData

@Model
final class Show {
    enum ShowStatus: String, Codable {
        case upcoming = "Upcoming"
        case past = "Past"
    }
    
    enum CompensationType: String, Codable {
        case flatFee = "Flat Fee"
        case perDog = "Per Dog"
    }
    
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
    
    // Make compensation details optional
    var compensationType: CompensationType?
    var flatFeeAmount: Double?
    var perDogRate: Double?
    
    // Make travel expenses optional
    var mileageRate: Double?
    var mileageTraveled: Double?
    var hotelExpense: Double?
    var airfareExpense: Double?
    var otherExpenses: Double?
    var expenseNotes: String?
    
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
        self.compensationType = .flatFee
        self.flatFeeAmount = 0
        self.perDogRate = 0
        self.mileageRate = 0.655
        self.mileageTraveled = 0
        self.hotelExpense = 0
        self.airfareExpense = 0
        self.otherExpenses = 0
    }
    
    var totalDogs: Int {
        breedAssignments.reduce(0) { $0 + $1.count }
    }
    
    var judgingFee: Double {
        switch compensationType ?? .flatFee {
        case .flatFee:
            return flatFeeAmount ?? 0
        case .perDog:
            return Double(totalDogs) * (perDogRate ?? 0)
        }
    }
    
    var totalTravelExpenses: Double {
        let mileageExpense = (mileageRate ?? 0) * (mileageTraveled ?? 0)
        let hotel = hotelExpense ?? 0
        let airfare = airfareExpense ?? 0
        let other = otherExpenses ?? 0
        return mileageExpense + hotel + airfare + other
    }
    
    var totalCompensation: Double {
        judgingFee + totalTravelExpenses
    }
} 