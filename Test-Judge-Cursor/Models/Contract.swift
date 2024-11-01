import Foundation
import SwiftData

@Model
final class Contract {
    var id: UUID
    var showName: String
    var scanDate: Date
    var documentData: Data?
    var notes: String?
    
    init(showName: String, documentData: Data? = nil) {
        self.id = UUID()
        self.showName = showName
        self.scanDate = Date()
        self.documentData = documentData
        self.notes = nil
    }
} 