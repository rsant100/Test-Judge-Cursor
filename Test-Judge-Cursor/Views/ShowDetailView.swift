import SwiftUI
import SwiftData
import MapKit

struct ShowDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var show: Show
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false
    
    var body: some View {
        List {
            Section("Show Information") {
                LabeledContent("Show Name", value: show.name)
                LabeledContent("Date", value: show.date.formatted(date: .long, time: .omitted))
                LabeledContent("Location", value: "\(show.location), \(show.state)")
                if let status = show.status {
                    LabeledContent("Status", value: status.rawValue)
                }
            }
            
            Section("Event Details") {
                LabeledContent("Event Number", value: show.eventNumber)
                LabeledContent("Ring Number", value: String(show.ringNumber))
            }
            
            Section("Location") {
                ShowMapView(show: show)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .listRowInsets(EdgeInsets())
                
                Button(action: openInMaps) {
                    Label("Get Directions", systemImage: "map.fill")
                }
            }
            
            Section("Breed Assignments") {
                NavigationLink(destination: BreedAssignmentsView(show: show)) {
                    HStack {
                        Text("View Assignments")
                        Spacer()
                        Text("\(show.breedAssignments.count)")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section("Notes") {
                TextEditor(text: Binding(
                    get: { show.notes ?? "" },
                    set: { show.notes = $0 }
                ))
                .frame(minHeight: 100)
            }
            
            Section("Weather") {
                WeatherView(show: show)
            }
            
            Section("Calendar") {
                HStack {
                    Text("Add to Calendar")
                    Spacer()
                    Button(action: {
                        Task {
                            let success = await CalendarManager.shared.addShowToCalendar(show)
                            if success {
                                // Show success message
                            }
                        }
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Show Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditShowView(show: show)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareText()])
        }
    }
    
    private func openInMaps() {
        let address = "\(show.location), \(show.state)"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = show.name
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
        }
    }
    
    private func createShareText() -> String {
        """
        Dog Show: \(show.name)
        Date: \(show.date.formatted(date: .long, time: .omitted))
        Location: \(show.location), \(show.state)
        Event Number: \(show.eventNumber)
        Ring: \(show.ringNumber)
        
        Breed Assignments:
        \(formatBreedAssignments())
        """
    }
    
    private func formatBreedAssignments() -> String {
        if show.breedAssignments.isEmpty {
            return "No breed assignments"
        }
        
        return show.breedAssignments
            .sorted { $0.time < $1.time }
            .map { breed in
                "\(breed.time.formatted(date: .omitted, time: .shortened)) - \(breed.breedName) (\(breed.count) entries)"
            }
            .joined(separator: "\n")
    }
} 