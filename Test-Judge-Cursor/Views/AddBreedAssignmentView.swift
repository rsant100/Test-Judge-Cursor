import SwiftUI
import SwiftData

struct AddBreedAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (BreedAssignment) -> Void
    
    @State private var breedName = ""
    @State private var count = 0
    @State private var time = Date()
    @State private var ring = 1
    @State private var notes = ""
    @State private var searchText = ""
    @State private var showingSuggestions = false
    
    private let breedService = BreedService.shared
    
    private var filteredBreeds: [AKCBreed] {
        guard !searchText.isEmpty else { return [] }
        return breedService.searchBreeds(searchText)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Breed Information") {
                    TextField("Search Breeds", text: $searchText)
                        .onChange(of: searchText) {
                            showingSuggestions = !searchText.isEmpty
                            print("Searching for: \(searchText)")
                            print("Found breeds: \(filteredBreeds.map { $0.name })")
                        }
                    
                    if showingSuggestions && !filteredBreeds.isEmpty {
                        ForEach(filteredBreeds, id: \.name) { breed in
                            Button(action: {
                                breedName = breed.name
                                searchText = breed.name
                                showingSuggestions = false
                            }) {
                                VStack(alignment: .leading) {
                                    Text(breed.name)
                                        .foregroundColor(.primary)
                                    Text(breed.group)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
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
                            breedName: breedName.isEmpty ? searchText : breedName,
                            count: count,
                            time: time,
                            ring: ring,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(breed)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddBreedAssignmentView { _ in }
} 