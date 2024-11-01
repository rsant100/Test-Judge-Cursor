import SwiftUI
import SwiftData

struct EditBreedAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var breed: BreedAssignment
    
    var body: some View {
        NavigationView {
            Form {
                Section("Breed Information") {
                    TextField("Breed Name", text: $breed.breedName)
                    Stepper("Count: \(breed.count)", value: $breed.count, in: 0...999)
                }
                
                Section("Schedule") {
                    DatePicker("Time", selection: $breed.time, displayedComponents: .hourAndMinute)
                    Stepper("Ring: \(breed.ring)", value: $breed.ring, in: 1...99)
                }
                
                Section("Notes") {
                    TextEditor(text: Binding(
                        get: { breed.notes ?? "" },
                        set: { breed.notes = $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle("Edit Breed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 