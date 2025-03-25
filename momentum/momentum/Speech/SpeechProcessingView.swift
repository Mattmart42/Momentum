//
//  SpeechProcessingView.swift
//  Momentm_
//
//  Created by Matthew Martinez on 3/21/25.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeechProcessingView: View {
    let transcribedText: String
    @Environment(\.presentationMode) var presentationMode
    
    // These would match your existing LogActivityView fields
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var distanceWhole: Int = 0
    @State private var distanceDecimal: Int = 0
    @State private var distanceUnit: String = "mi"
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var durationSeconds: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Recorded Activity")
                    .font(.headline)
                
                Text(transcribedText)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                
                Text("Detected Information")
                    .font(.headline)
                    .padding(.top)
                
                // In Phase 2, we'll add the automatic extraction here
                // For now, just show placeholder fields
                Group {
                    TextField("Activity Title", text: $title)
                    
                    TextField("Activity Description", text: $description)
                        .frame(height: 100)
                    
                    HStack {
                        Text("Distance:")
                        Spacer()
                        Text("\(distanceWhole).\(distanceDecimal) \(distanceUnit)")
                    }
                    
                    HStack {
                        Text("Duration:")
                        Spacer()
                        Text(String(format: "%02d:%02d:%02d", durationHours, durationMinutes, durationSeconds))
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    // In the next phase, we'll add logic to save the activity
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Process Activity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // In Phase 2, we'll add logic to process the speech here
            print("Processing text: \(transcribedText)")
        }
    }
}
