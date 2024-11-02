import SwiftUI
import SwiftData

struct BreedAssignmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var show: Show
    @State private var showingAddBreed = false
    @State private var selectedBreed: BreedAssignment?
    
    var body: some View {
        List {
            ForEach(show.breedAssignments.sorted(by: { $0.time < $1.time })) { breed in
                BreedAssignmentRow(breed: breed)
                    .onTapGesture {
                        selectedBreed = breed
                    }
            }
            .onDelete(perform: deleteBreeds)
            
            Button(action: { showingAddBreed = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Breed")
                }
            }
        }
        .navigationTitle("Breed Assignments")
        .sheet(isPresented: $showingAddBreed) {
            AddBreedAssignmentView { breed in
                breed.show = show
                show.breedAssignments.append(breed)
                modelContext.insert(breed)
            }
        }
        .sheet(item: $selectedBreed) { breed in
            EditBreedAssignmentView(breed: breed)
        }
    }
    
    private func deleteBreeds(at offsets: IndexSet) {
        for index in offsets {
            let breed = show.breedAssignments.sorted(by: { $0.time < $1.time })[index]
            show.breedAssignments.removeAll { $0.id == breed.id }
            modelContext.delete(breed)
        }
    }
}

struct BreedAssignmentRow: View {
    let breed: BreedAssignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(breed.breedName)
                .font(.headline)
            
            HStack {
                Text(breed.time.formatted(date: .omitted, time: .shortened))
                Text("•")
                Text("Ring \(breed.ring)")
                Text("•")
                Text("\(breed.count) entries")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if let notes = breed.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Show.self, BreedAssignment.self, configurations: config)
    let show = Show(name: "Test Show", date: Date(), location: "Test City", state: "TS", eventNumber: "123", ringNumber: 1)
    
    return BreedAssignmentsView(show: show)
        .modelContainer(container)
} 