//
//  ContentView.swift
//  Test-Judge-Cursor
//
//  Created by Robert Santini on 11/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ShowsView()
                .tabItem {
                    Label("Shows", systemImage: "calendar")
                }
            
            BreedsView()
                .tabItem {
                    Label("Breeds", systemImage: "pawprint.fill")
                }
            
            ContractsView()
                .tabItem {
                    Label("Contracts", systemImage: "doc.text.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
