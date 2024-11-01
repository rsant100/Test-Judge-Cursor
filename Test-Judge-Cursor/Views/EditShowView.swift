import SwiftUI
import SwiftData

struct EditShowView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var show: Show
    
    var body: some View {
        NavigationView {
            Form {
                Section("Show Details") {
                    TextField("Show Name", text: $show.name)
                    DatePicker("Show Date", selection: $show.date, displayedComponents: .date)
                    TextField("Location (City)", text: $show.location)
                    TextField("State", text: $show.state)
                }
                
                Section("Event Information") {
                    TextField("Event Number", text: $show.eventNumber)
                    TextField("Ring Number", value: $show.ringNumber, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Section("Notes") {
                    TextEditor(text: Binding(
                        get: { show.notes ?? "" },
                        set: { show.notes = $0 }
                    ))
                    .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        NotificationManager.shared.cancelNotification(for: show)
                        NotificationManager.shared.scheduleShowNotification(for: show)
                        dismiss()
                    }
                }
            }
        }
    }
} 