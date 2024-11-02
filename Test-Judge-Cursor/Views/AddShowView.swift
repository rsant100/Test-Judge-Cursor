import SwiftUI
import SwiftData

struct AddShowView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showName = ""
    @State private var showDate = Date()
    @State private var location = ""
    @State private var state = ""
    @State private var eventNumber = ""
    @State private var ringNumber = ""
    @State private var breedAssignments: [BreedAssignment] = []
    @State private var showingAddBreedSheet = false
    @State private var compensationType: Show.CompensationType = .flatFee
    @State private var flatFeeAmount: Double = 0
    @State private var perDogRate: Double = 0
    @State private var mileageRate: Double = 0.655  // Default IRS rate
    @State private var mileageTraveled: Double = 0
    @State private var hotelExpense: Double = 0
    @State private var airfareExpense: Double = 0
    @State private var otherExpenses: Double = 0
    @State private var expenseNotes: String = ""
    
    var totalMileageExpense: Double {
        mileageRate * mileageTraveled
    }
    
    var totalExpenses: Double {
        totalMileageExpense + hotelExpense + airfareExpense + otherExpenses
    }
    
    var judgingFee: Double {
        switch compensationType {
        case .flatFee:
            return flatFeeAmount
        case .perDog:
            let totalDogs = breedAssignments.reduce(0) { $0 + $1.count }
            return Double(totalDogs) * perDogRate
        }
    }
    
    var totalCompensation: Double {
        judgingFee + totalExpenses
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Show Details") {
                    TextField("Show Name", text: $showName)
                    DatePicker("Show Date", selection: $showDate, displayedComponents: .date)
                    TextField("Location (City)", text: $location)
                    TextField("State", text: $state)
                }
                
                Section("Event Information") {
                    TextField("Event Number", text: $eventNumber)
                    TextField("Ring Number", text: $ringNumber)
                        .keyboardType(.numberPad)
                }
                
                Section("Breed Assignments") {
                    ForEach(breedAssignments) { breed in
                        VStack(alignment: .leading) {
                            Text(breed.breedName)
                                .font(.headline)
                            HStack {
                                Text(breed.time.formatted(date: .omitted, time: .shortened))
                                Text("•")
                                Text("Ring \(breed.ring)")
                                Text("•")
                                Text("\(breed.count) entries")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteBreed)
                    
                    Button(action: { showingAddBreedSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Breed")
                        }
                    }
                }
                
                Section("Compensation") {
                    Picker("Type", selection: $compensationType) {
                        Text("Flat Fee").tag(Show.CompensationType.flatFee)
                        Text("Per Dog").tag(Show.CompensationType.perDog)
                    }
                    
                    if compensationType == .flatFee {
                        TextField("Flat Fee Amount", value: $flatFeeAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    } else {
                        TextField("Rate Per Dog", value: $perDogRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Travel Expenses") {
                    HStack {
                        Text("Mileage Rate")
                        Spacer()
                        TextField("$0.655/mile", value: $mileageRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.plain)
                    }
                    
                    HStack {
                        Text("Miles Traveled")
                        Spacer()
                        TextField("Enter miles", value: Binding(
                            get: { mileageTraveled == 0 ? nil : mileageTraveled },
                            set: { mileageTraveled = $0 ?? 0 }
                        ), format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Hotel Expense")
                        Spacer()
                        TextField("Enter amount", value: Binding(
                            get: { hotelExpense == 0 ? nil : hotelExpense },
                            set: { hotelExpense = $0 ?? 0 }
                        ), format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Airfare Expense")
                        Spacer()
                        TextField("Enter amount", value: Binding(
                            get: { airfareExpense == 0 ? nil : airfareExpense },
                            set: { airfareExpense = $0 ?? 0 }
                        ), format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Other Expenses")
                        Spacer()
                        TextField("Enter amount", value: Binding(
                            get: { otherExpenses == 0 ? nil : otherExpenses },
                            set: { otherExpenses = $0 ?? 0 }
                        ), format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Expense Notes", text: $expenseNotes, axis: .vertical)
                }
                
                Section("Summary") {
                    LabeledContent("Judging Fee", value: judgingFee, format: .currency(code: "USD"))
                    LabeledContent("Mileage Expense", value: totalMileageExpense, format: .currency(code: "USD"))
                    LabeledContent("Other Expenses", value: (hotelExpense + airfareExpense + otherExpenses), format: .currency(code: "USD"))
                    LabeledContent("Total Expenses", value: totalExpenses, format: .currency(code: "USD"))
                        .fontWeight(.semibold)
                    Divider()
                    LabeledContent("Total Compensation", value: totalCompensation, format: .currency(code: "USD"))
                        .fontWeight(.bold)
                }
                
                if compensationType == .perDog {
                    Section("Estimated Earnings") {
                        let totalDogs = breedAssignments.reduce(0) { $0 + $1.count }
                        Text("Based on \(totalDogs) dogs: \(judgingFee, format: .currency(code: "USD"))")
                    }
                }
            }
            .navigationTitle("Add Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveShow()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddBreedSheet) {
                AddBreedAssignmentView { breed in
                    breedAssignments.append(breed)
                    showingAddBreedSheet = false
                }
            }
        }
    }
    
    private func deleteBreed(at offsets: IndexSet) {
        breedAssignments.remove(atOffsets: offsets)
    }
    
    private func saveShow() {
        let newShow = Show(
            name: showName,
            date: showDate,
            location: location,
            state: state,
            eventNumber: eventNumber,
            ringNumber: Int(ringNumber) ?? 0
        )
        
        // Set compensation details
        newShow.compensationType = compensationType
        newShow.flatFeeAmount = flatFeeAmount
        newShow.perDogRate = perDogRate
        
        // Set travel expenses
        newShow.mileageRate = mileageRate
        newShow.mileageTraveled = mileageTraveled
        newShow.hotelExpense = hotelExpense
        newShow.airfareExpense = airfareExpense
        newShow.otherExpenses = otherExpenses
        newShow.expenseNotes = expenseNotes
        
        // Add breed assignments
        breedAssignments.forEach { breed in
            breed.show = newShow
            newShow.breedAssignments.append(breed)
            modelContext.insert(breed)
        }
        
        modelContext.insert(newShow)
        
        do {
            try modelContext.save()
            NotificationManager.shared.scheduleShowNotification(for: newShow)
        } catch {
            print("Error saving show: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddShowView()
}
