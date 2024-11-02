import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationDays") private var notificationDays = 1
    @AppStorage("notificationTime") private var notificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @AppStorage("useDarkMode") private var useDarkMode = false
    @State private var showingNotificationAlert = false
    @State private var showingClearDataAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    NavigationLink(destination: ProfileSetupView()) {
                        HStack(spacing: 15) {
                            // Profile Image
                            if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if let name = UserDefaults.standard.string(forKey: "judgeName"), !name.isEmpty {
                                    Text(name)
                                        .font(.headline)
                                } else {
                                    Text("Set up your profile")
                                        .font(.headline)
                                }
                                
                                if let judgeNumber = UserDefaults.standard.string(forKey: "judgeNumber"), !judgeNumber.isEmpty {
                                    Text("Judge #\(judgeNumber)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                if let specialties = UserDefaults.standard.string(forKey: "judgeSpecialties"), !specialties.isEmpty {
                                    Text(specialties)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if notificationsEnabled {
                        Stepper("Remind \(notificationDays) day\(notificationDays == 1 ? "" : "s") before", 
                               value: $notificationDays, in: 1...7)
                        
                        DatePicker("Notification Time",
                                 selection: $notificationTime,
                                 displayedComponents: .hourAndMinute)
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $useDarkMode)
                }
                
                // Help Center Section
                Section("Help Center") {
                    NavigationLink {
                        HelpCenterView()
                    } label: {
                        Label("How to Use iJudge", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink {
                        FAQView()
                    } label: {
                        Label("FAQ", systemImage: "list.bullet")
                    }
                    
                    NavigationLink {
                        ContactSupportView()
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("iJudge © 2024")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                }
            }
            .navigationTitle("Settings")
            .alert("Notifications Disabled", isPresented: $showingNotificationAlert) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive show reminders")
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

// New Help Center View
struct HelpCenterView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("Adding Your First Show") {
                    HowToView(
                        title: "Adding Your First Show",
                        steps: [
                            "Tap the 'Shows' tab at the bottom",
                            "Tap the '+' button in the top right",
                            "Fill in the show details",
                            "Tap 'Save' to add the show"
                        ]
                    )
                }
                
                NavigationLink("Managing Breeds") {
                    HowToView(
                        title: "Managing Breeds",
                        steps: [
                            "Tap the 'Breeds' tab",
                            "Add breeds you'll be judging",
                            "Assign breeds to specific shows",
                            "View breed assignments in show details"
                        ]
                    )
                }
                
                NavigationLink("Scanning Contracts") {
                    HowToView(
                        title: "Scanning Contracts",
                        steps: [
                            "Tap 'Scan Contract' on the home screen",
                            "Position the contract within the camera frame",
                            "Tap the capture button",
                            "Review and save the scanned contract"
                        ]
                    )
                }
                
                NavigationLink("Setting Up Notifications") {
                    HowToView(
                        title: "Setting Up Notifications",
                        steps: [
                            "Go to the Settings tab",
                            "Enable notifications toggle",
                            "Choose how many days before to be notified",
                            "Set your preferred notification time",
                            "Allow notifications when prompted"
                        ]
                    )
                }
                
                NavigationLink("Customizing Your Profile") {
                    HowToView(
                        title: "Customizing Your Profile",
                        steps: [
                            "Navigate to Settings",
                            "Tap on the Judge Profile section",
                            "Add your judging credentials",
                            "Set your preferred settings",
                            "Save your changes"
                        ]
                    )
                }
            }
            
            Section("Advanced Features") {
                NavigationLink("Using the Calendar") {
                    HowToView(
                        title: "Using the Calendar",
                        steps: [
                            "Access the Shows tab",
                            "View shows in monthly or list view",
                            "Tap dates to see show details",
                            "Use filters to find specific shows",
                            "Sync with your device calendar"
                        ]
                    )
                }
                
                NavigationLink("Managing Contracts") {
                    HowToView(
                        title: "Managing Contracts",
                        steps: [
                            "Go to the Contracts tab",
                            "View all scanned contracts",
                            "Organize by show date",
                            "Add notes to contracts",
                            "Access contract details quickly"
                        ]
                    )
                }
                
                NavigationLink("Breed Assignment Tips") {
                    HowToView(
                        title: "Breed Assignment Tips",
                        steps: [
                            "Use the Breeds tab efficiently",
                            "Create breed groups for quick assignment",
                            "Set recurring assignments",
                            "Review assignments before shows",
                            "Update assignments as needed"
                        ]
                    )
                }
            }
        }
        .navigationTitle("How to Use iJudge")
    }
}

// FAQ View
struct FAQView: View {
    var body: some View {
        List {
            Section("Common Questions") {
                FAQItem(
                    question: "How do I edit a show after creating it?",
                    answer: "Open the Shows tab, tap on the show you want to edit, then tap the 'Edit' button in the top right corner."
                )
                
                FAQItem(
                    question: "Can I export my show data?",
                    answer: "Currently, show data is stored locally on your device. We're working on adding export functionality in a future update."
                )
                
                FAQItem(
                    question: "How far in advance will I get notifications?",
                    answer: "You can set notifications from 1-7 days before each show in the Settings tab under Notifications."
                )
                
                FAQItem(
                    question: "How does the weather feature work?",
                    answer: "The app automatically fetches weather data for your next upcoming show location and displays it on the home screen."
                )
                
                FAQItem(
                    question: "Can I share show details with others?",
                    answer: "Yes, you can share show details by opening a show and tapping the share button in the top right corner."
                )
                
                FAQItem(
                    question: "Can I use the app offline?",
                    answer: "Yes, most features work offline. Weather updates and new contract scanning require internet connection."
                )
                
                FAQItem(
                    question: "How do I backup my data?",
                    answer: "Your data is automatically backed up with your iPhone backup. Make sure to regularly backup your device to iCloud or your computer."
                )
                
                FAQItem(
                    question: "Can I sync between multiple devices?",
                    answer: "Currently, data is stored locally on your device. We're working on iCloud sync for a future update."
                )
                
                FAQItem(
                    question: "How do I organize multiple shows?",
                    answer: "Use the calendar view in the Shows tab to see all your upcoming events. You can also filter and search for specific shows."
                )
                
                FAQItem(
                    question: "What happens if I delete the app?",
                    answer: "All app data will be removed. Make sure to backup any important information before deleting the app."
                )
                
                FAQItem(
                    question: "Can I print show information?",
                    answer: "Yes, use the share button in show details to print or save as PDF."
                )
                
                FAQItem(
                    question: "How accurate is the weather data?",
                    answer: "Weather data is updated regularly from reliable sources, but conditions can change. We recommend checking local weather closer to show date."
                )
            }
            
            Section("Technical Support") {
                FAQItem(
                    question: "The app is running slowly",
                    answer: "Try closing other apps, restarting the app, or restarting your device. If issues persist, contact support."
                )
                
                FAQItem(
                    question: "Notifications aren't working",
                    answer: "Check your device settings to ensure notifications are enabled for iJudge. You can also reset notification settings in the app."
                )
            }
        }
        .navigationTitle("FAQ")
    }
}

// Helper Views
struct HowToView: View {
    let title: String
    let steps: [String]
    
    var body: some View {
        List {
            ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                    Text(step)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(title)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
            Text(answer)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// Add new ContactSupportView
struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            Section {
                Button {
                    openEmailClient()
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Email Support")
                        Spacer()
                        Text("support@ijudge.com")
                            .foregroundColor(.gray)
                    }
                }
            } footer: {
                Text("We typically respond within 24 hours during business days.")
            }
        }
        .navigationTitle("Contact Support")
    }
    
    private func openEmailClient() {
        let email = "support@ijudge.com"
        let subject = "iJudge Support Request"
        let body = "App Version: 1.0.0\n\nPlease describe your issue:"
        
        let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = URL(string: urlString ?? "") {
            openURL(url)
        }
    }
}

// Add new ProfileSetupView
struct ProfileSetupView: View {
    @AppStorage("judgeName") private var judgeName = ""
    @AppStorage("judgeNumber") private var judgeNumber = ""
    @AppStorage("judgeEmail") private var judgeEmail = ""
    @AppStorage("judgePhone") private var judgePhone = ""
    @AppStorage("judgeSpecialties") private var judgeSpecialties = ""
    @AppStorage("judgeYearsExperience") private var judgeYearsExperience = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var hasChanges = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Group {
                            if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                
                Text("Tap to change profile photo")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
            
            Section("Personal Information") {
                TextField("Full Name", text: $judgeName)
                    .onChange(of: judgeName) { oldValue, newValue in
                        hasChanges = true
                    }
                TextField("Judge Number", text: $judgeNumber)
                    .onChange(of: judgeNumber) { oldValue, newValue in
                        hasChanges = true
                    }
                TextField("Email", text: $judgeEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: judgeEmail) { oldValue, newValue in
                        hasChanges = true
                    }
                TextField("Phone", text: $judgePhone)
                    .keyboardType(.phonePad)
                    .onChange(of: judgePhone) { oldValue, newValue in
                        hasChanges = true
                    }
            }
            
            Section("Professional Information") {
                TextField("Years of Experience", text: $judgeYearsExperience)
                    .keyboardType(.numberPad)
                    .onChange(of: judgeYearsExperience) { oldValue, newValue in
                        hasChanges = true
                    }
                
                TextField("Specialties/Groups", text: $judgeSpecialties)
                    .textInputAutocapitalization(.words)
                    .onChange(of: judgeSpecialties) { oldValue, newValue in
                        hasChanges = true
                    }
            }
            
            Section {
                Button(action: saveProfile) {
                    HStack {
                        Spacer()
                        Text("Save Profile")
                            .bold()
                        Spacer()
                    }
                }
                .disabled(!hasChanges)
                .foregroundColor(hasChanges ? .blue : .gray)
            }
            
            Section("Profile Usage") {
                Text("Your profile information will be used to:")
                    .font(.caption)
                Text("• Auto-fill show registration forms")
                    .font(.caption)
                Text("• Customize contract scanning")
                    .font(.caption)
                Text("• Personalize app experience")
                    .font(.caption)
            }
        }
        .navigationTitle("Judge Profile")
        .alert("Profile Saved", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully.")
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { oldValue, newValue in
            if let image = newValue {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    UserDefaults.standard.set(imageData, forKey: "profileImage")
                    hasChanges = true
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    private func saveProfile() {
        // Profile is automatically saved via @AppStorage
        showingSaveAlert = true
        hasChanges = false
    }
}

// Add ImagePicker struct
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#Preview {
    SettingsView()
}
