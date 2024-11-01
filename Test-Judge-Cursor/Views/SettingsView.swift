import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationDays") private var notificationDays = 1
    @AppStorage("notificationTime") private var notificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var showingNotificationAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) {
                            if notificationsEnabled {
                                requestNotificationPermission()
                            }
                        }
                    
                    if notificationsEnabled {
                        Stepper("Remind \(notificationDays) day\(notificationDays == 1 ? "" : "s") before", value: $notificationDays, in: 1...7)
                        
                        DatePicker("Notification Time",
                                 selection: $notificationTime,
                                 displayedComponents: .hourAndMinute)
                        
                        Button("Test Notification") {
                            let content = UNMutableNotificationContent()
                            content.title = "Test Notification"
                            content.body = "This is a test notification"
                            content.sound = .default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                            let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if let error = error {
                                    print("Error scheduling test notification: \(error.localizedDescription)")
                                } else {
                                    print("Test notification scheduled")
                                }
                            }
                        }
                    }
                }
                
                Section("Profile") {
                    NavigationLink("Edit Profile") {
                        Text("Profile settings coming soon")
                    }
                    NavigationLink("Notifications") {
                        Text("Additional notification settings coming soon")
                    }
                }
                
                Section("App Settings") {
                    NavigationLink("Preferences") {
                        Text("Preferences coming soon")
                    }
                    NavigationLink("About") {
                        Text("About this app")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Notifications Disabled", isPresented: $showingNotificationAlert) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive show reminders")
            }
            .onAppear {
                NotificationManager.shared.checkNotificationStatus()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
            
            if !granted {
                notificationsEnabled = false
                showingNotificationAlert = true
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
#Preview {
    SettingsView()
}
