import SwiftUI
import SwiftData

struct ShowsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddShow = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .date
    
    enum SortOrder {
        case date, name, location
    }
    
    var sortDescriptor: SortDescriptor<Show> {
        switch sortOrder {
        case .date:
            return SortDescriptor(\Show.date)
        case .name:
            return SortDescriptor(\Show.name)
        case .location:
            return SortDescriptor(\Show.location)
        }
    }
    
    @Query private var shows: [Show]
    
    init(searchText: String = "", sortOrder: SortOrder = .date) {
        self._searchText = State(initialValue: searchText)
        self._sortOrder = State(initialValue: sortOrder)
        
        let predicate = searchText.isEmpty ? #Predicate<Show> { _ in
            true
        } : #Predicate<Show> { show in
            show.name.localizedStandardContains(searchText) ||
            show.location.localizedStandardContains(searchText) ||
            show.state.localizedStandardContains(searchText)
        }
        
        _shows = Query(filter: predicate, sort: [SortDescriptor(\Show.date)])
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(shows) { show in
                    NavigationLink(destination: ShowDetailView(show: show)) {
                        ShowRowView(show: show)
                    }
                }
                .onDelete(perform: deleteShows)
            }
            .searchable(text: $searchText, prompt: "Search shows")
            .navigationTitle("My Shows")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Sort") {
                        Button("By Date") { sortOrder = .date }
                        Button("By Name") { sortOrder = .name }
                        Button("By Location") { sortOrder = .location }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddShow = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddShow) {
            AddShowView()
        }
    }
    
    private func deleteShows(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(shows[index])
        }
    }
}

struct ShowRowView: View {
    let show: Show
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(show.name)
                .font(.headline)
            Text(show.date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
            Text("\(show.location), \(show.state)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
} 
#Preview {
    ShowsView()
}
