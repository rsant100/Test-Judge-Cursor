import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func scheduleShowNotification(for show: Show) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("Notifications are disabled in settings")
            return
        }
        
        let notificationDays = UserDefaults.standard.integer(forKey: "notificationDays")
        let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
        
        let calendar = Calendar.current
        let notificationDate = calendar.date(byAdding: .day, value: -notificationDays, to: show.date) ?? show.date
        
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        let finalDate = calendar.date(bySettingHour: components.hour ?? 9,
                                    minute: components.minute ?? 0,
                                    second: 0,
                                    of: notificationDate) ?? notificationDate
        
        print("Scheduling notification for show: \(show.name)")
        print("Notification will fire at: \(finalDate)")
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Show: \(show.name)"
        content.body = "You have a show in \(notificationDays) day\(notificationDays == 1 ? "" : "s") at \(show.location), \(show.state)"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                from: finalDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "show-\(show.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification")
                
                // List all pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("Current pending notifications: \(requests.count)")
                    for request in requests {
                        print("- \(request.identifier)")
                    }
                }
            }
        }
    }
    
    func cancelNotification(for show: Show) {
        print("Cancelling notification for show: \(show.name)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["show-\(show.id.uuidString)"]
        )
    }
    
    // Add a function to check notification status
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings:")
            print("Authorization status: \(settings.authorizationStatus.rawValue)")
            print("Alert setting: \(settings.alertSetting.rawValue)")
            print("Sound setting: \(settings.soundSetting.rawValue)")
            print("Badge setting: \(settings.badgeSetting.rawValue)")
        }
    }
} 