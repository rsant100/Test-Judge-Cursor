import SwiftUI
import SwiftData

struct BreedAssignmentsView: View {
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
        }
        .navigationTitle("Breed Assignments")
        .toolbar {
            Button(action: { showingAddBreed = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddBreed) {
            AddBreedAssignmentView(show: show)
        }
        .sheet(item: $selectedBreed) { breed in
            EditBreedAssignmentView(breed: breed)
        }
    }
    
    private func deleteBreeds(at offsets: IndexSet) {
        for index in offsets {
            let breed = show.breedAssignments.sorted(by: { $0.time < $1.time })[index]
            show.breedAssignments.removeAll { $0.id == breed.id }
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