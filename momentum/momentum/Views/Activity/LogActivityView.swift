//
//  LogActivityView.swift
//  Momentm_
//
//  Created by matt on 10/24/24.
//

import SwiftUI

@MainActor
final class LogActivityViewModel: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
}

struct LogActivityView: View {
    
//    @StateObject private var viewModel = LogActivityViewModel()
//    @Binding var showSignInView: Bool
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var distanceWhole: Int = 0
    @State private var distanceDecimal: Int = 0
    @State private var distanceUnit: String = "mi"
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var durationSeconds: Int = 0
    @State private var timeOfDay: Date = Date()
    
    @State private var distance: Double = 0.0
    @State private var duration: Double = 0.0

    @State private var showingDistancePicker = false
    @State private var showingDurationPicker = false
    
    @StateObject private var viewModel = LogActivityViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Section(header: Text("Activity Details")) {
                        TextField("Activity Name", text: $title)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        TextEditor(text: $description)
                            .padding(8) // Add padding
                            .frame(minHeight: 100) // Set a minimum height
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .font(.system(size: 16)) // Set font size
                    }
                    
                    Section(header: Text("Activity Data")) {
                        // Distance Input
                        Button(action: {
                            showingDistancePicker.toggle()
                        }) {
                            HStack {
                                Text("\(distanceWhole).\(distanceDecimal) \(distanceUnit)")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding() // Add padding for the button area
                            .background(Color(UIColor.systemGray6)) // Background color
                            .cornerRadius(8) // Rounded corners
                        }
                        
                        // Duration Input
                        Button(action: {
                            showingDurationPicker.toggle()
                        }) {
                            HStack {
                                Text(String(format: "%02d:%02d:%02d", durationHours, durationMinutes, durationSeconds))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding() // Add padding for the button area
                            .background(Color(UIColor.systemGray6)) // Background color
                            .cornerRadius(8) // Rounded corners
                        }
                        
                        // Time of Day Picker
                        DatePicker("Date and Time", selection: $timeOfDay, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(DefaultDatePickerStyle())
                            .labelsHidden()
                    }
                    
                    Section {
                        Button(action: {
                            Task {
                                await saveActivity()
                            }
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save Activity")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Full width
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Log Activity")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.vertical, 5) // Adjust vertical padding
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showingDistancePicker) {
                DistancePicker(distanceWhole: $distanceWhole, distanceDecimal: $distanceDecimal, distanceUnit: $distanceUnit)
            }
            .sheet(isPresented: $showingDurationPicker) {
                DurationPicker(hours: $durationHours, minutes: $durationMinutes, seconds: $durationSeconds)
            }
        }
    }
    
    func saveActivity() async {
        viewModel.loadAuthUser()
        setDistance()
        setDuration()
        
        guard let userId = viewModel.authUser?.uid else {
            print("User ID is nil. Cannot save activity.")
            return
        }
        
        do {
            try await ActivityManager.shared.createActivity(userId: userId,
                title: title.isEmpty ? nil : title,
                description: description.isEmpty ? nil : description,
                distance: distance,
                duration: duration,
                timeOfDay: timeOfDay
            )
        } catch {
            print("Failed to update user data: \(error.localizedDescription)")
        }
    }
    
    func setDistance() {
        distance = Double(distanceWhole) + Double(distanceDecimal) / 10
    }
    
    func setDuration() {
        duration = Double(durationHours * 3600 + durationMinutes * 60 + durationSeconds)
    }
}

struct DistancePicker: View {
    @Binding var distanceWhole: Int
    @Binding var distanceDecimal: Int
    @Binding var distanceUnit: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            HStack {
                Picker("Whole", selection: $distanceWhole) {
                    ForEach(0..<1000, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Text(".")

                Picker("Decimal", selection: $distanceDecimal) {
                    ForEach(0..<10, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())

                Picker("Unit", selection: $distanceUnit) {
                    Text("mi").tag("mi")
                    Text("km").tag("km")
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationTitle("Select Distance")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DurationPicker: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            HStack {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Text(":")

                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Text(":")

                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationTitle("Select Duration")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
