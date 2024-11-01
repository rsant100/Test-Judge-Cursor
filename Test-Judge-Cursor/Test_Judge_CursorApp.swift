//
//  Test_Judge_CursorApp.swift
//  Test-Judge-Cursor
//
//  Created by Robert Santini on 11/1/24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct Test_Judge_CursorApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([Show.self, Contract.self, BreedAssignment.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Request notification permissions at app launch
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Check notification settings when app appears
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(settings.authorizationStatus == .authorized, forKey: "notificationsEnabled")
                        }
                    }
                }
        }
        .modelContainer(container)
    }
}
