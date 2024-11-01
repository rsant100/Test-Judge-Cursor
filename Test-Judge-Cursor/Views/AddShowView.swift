import SwiftUI
import SwiftData

struct AddShowView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showName = ""
    @State private var showDate = Date()
    @State private var location = ""
    @State private var state = ""
    @State private var eventNumber = ""
    @State private var ringNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Show Details") {
                    TextField("Show Name", text: $showName)
                    DatePicker("Show Date", selection: $showDate, displayedComponents: .date)
                    TextField("Location (City)", text: $location)
                    TextField("State", text: $state)
                }
                
                Section("Event Information") {
                    TextField("Event Number", text: $eventNumber)
                    TextField("Ring Number", text: $ringNumber)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveShow()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveShow() {
        let newShow = Show(
            name: showName,
            date: showDate,
            location: location,
            state: state,
            eventNumber: eventNumber,
            ringNumber: Int(ringNumber) ?? 0
        )
        modelContext.insert(newShow)
        
        do {
            try modelContext.save()
            NotificationManager.shared.scheduleShowNotification(for: newShow)
        } catch {
            print("Error saving show: \(error.localizedDescription)")
        }
    }
}
#Preview {
    AddShowView()
}
