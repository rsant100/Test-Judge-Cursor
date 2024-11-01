import SwiftUI
import MapKit

struct ShowMapView: View {
    let show: Show
    @State private var position: MapCameraPosition
    @State private var annotation: ShowLocation?
    @State private var mapType: MapType = .standard
    
    init(show: Show) {
        self.show = show
        self._position = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
            span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        )))
    }
    
    var body: some View {
        Map(position: $position) {
            if let annotation = annotation {
                Marker(annotation.name, coordinate: annotation.coordinate)
                    .tint(.red)
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .mapStyle(mapType == .standard ? .standard : .hybrid)
        .overlay(alignment: .topTrailing) {
            Button(action: toggleMapType) {
                Image(systemName: mapType == .standard ? "map.fill" : "map")
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding(8)
            }
        }
        .onAppear {
            geocodeAddress()
        }
    }
    
    private func toggleMapType() {
        mapType = mapType == .standard ? .hybrid : .standard
    }
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        let address = "\(show.location), \(show.state)"
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                annotation = ShowLocation(
                    name: show.name,
                    coordinate: coordinate
                )
                position = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}

struct ShowLocation {
    let name: String
    let coordinate: CLLocationCoordinate2D
}

enum MapType {
    case standard
    case hybrid
} 