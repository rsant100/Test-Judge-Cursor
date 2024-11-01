import SwiftUI
import SwiftData

struct AddBreedAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var show: Show
    
    @State private var breedName = ""
    @State private var count = 0
    @State private var time = Date()
    @State private var ring = 1
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Breed Information") {
                    TextField("Breed Name", text: $breedName)
                    Stepper("Count: \(count)", value: $count, in: 0...999)
                }
                
                Section("Schedule") {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    Stepper("Ring: \(ring)", value: $ring, in: 1...99)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Breed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let breed = BreedAssignment(
                            breedName: breedName,
                            count: count,
                            time: time,
                            ring: ring,
                            notes: notes.isEmpty ? nil : notes,
                            show: show
                        )
                        show.breedAssignments.append(breed)
                        dismiss()
                    }
                }
            }
        }
    }
} 