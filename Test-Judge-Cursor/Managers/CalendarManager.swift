import EventKit
import SwiftUI

class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                Task {
                    do {
                        let granted = try await eventStore.requestFullAccessToEvents()
                        continuation.resume(returning: granted)
                    } catch {
                        print("Error requesting calendar access: \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("Error requesting calendar access: \(error)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func addShowToCalendar(_ show: Show) async -> Bool {
        guard await requestAccess() else { return false }
        
        // Get the default calendar
        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            print("No default calendar found")
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        let eventTitle = "Dog Show: \(show.name)"
        event.title = eventTitle
        event.location = "\(show.location), \(show.state)"
        
        // Set event start and end times
        event.startDate = show.date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 8, to: show.date) ?? show.date
        
        // Add notes including breed assignments
        var notes = "Event Number: \(show.eventNumber)\nRing: \(show.ringNumber)"
        if !show.breedAssignments.isEmpty {
            notes += "\n\nBreed Assignments:"
            for breed in show.breedAssignments.sorted(by: { $0.time < $1.time }) {
                notes += "\n\(breed.time.formatted(date: .omitted, time: .shortened)) - \(breed.breedName) (\(breed.count) entries)"
            }
        }
        if let showNotes = show.notes, !showNotes.isEmpty {
            notes += "\n\nNotes:\n\(showNotes)"
        }
        event.notes = notes
        
        // Add alarm
        let alarm = EKAlarm(relativeOffset: -3600) // 1 hour before
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Successfully added event: \(eventTitle)")
            return true
        } catch {
            print("Error saving event to calendar: \(error)")
            return false
        }
    }
    
    func removeShowFromCalendar(_ show: Show) async {
        guard await requestAccess(),
              let defaultCalendar = eventStore.defaultCalendarForNewEvents else { return }
        
        let predicate = eventStore.predicateForEvents(
            withStart: Calendar.current.startOfDay(for: show.date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: show.date) ?? show.date,
            calendars: [defaultCalendar]
        )
        
        let events = eventStore.events(matching: predicate)
        let eventTitle = "Dog Show: \(show.name)"
        let matchingEvents = events.filter { $0.title == eventTitle }
        
        for event in matchingEvents {
            do {
                try eventStore.remove(event, span: .thisEvent)
                print("Successfully removed event: \(eventTitle)")
            } catch {
                print("Error removing event: \(error)")
            }
        }
    }
} 
