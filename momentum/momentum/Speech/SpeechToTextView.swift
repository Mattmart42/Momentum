//
//  SpeechToTextView.swift
//  Momentm_
//
//  Created by Matthew Martinez on 3/21/25.
//

import SwiftUI
import Speech
import AVFoundation



// MARK: - SpeechToTextView
struct SpeechToTextView: View {
    @StateObject private var recognitionManager = SpeechRecognitionManager()
    @State private var navigateToEdit = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Status indicator
                Text(getStatusText())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                // Record button
                Button(action: {
                    if recognitionManager.isRecording {
                        recognitionManager.stopRecording()
                    } else {
                        recognitionManager.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(recognitionManager.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: recognitionManager.isRecording ? "stop.fill" : "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
                .disabled(recognitionManager.authorizationStatus != .authorized)
                
                // Transcription text
                ScrollView {
                    Text(recognitionManager.transcribedText)
                        .padding()
                        .frame(minHeight: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                NavigationLink(destination: SpeechProcessingView(transcribedText: recognitionManager.transcribedText), isActive: $navigateToEdit) {
                    Button(action: {
                        if !recognitionManager.transcribedText.isEmpty {
                            navigateToEdit = true
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(recognitionManager.transcribedText.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(recognitionManager.transcribedText.isEmpty)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Record Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()  // Use the dismiss action
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
            }
            .onDisappear {
                if recognitionManager.isRecording {
                    recognitionManager.stopRecording()
                }
            }
        }
    }
    
    private func getStatusText() -> String {
        switch recognitionManager.authorizationStatus {
        case .authorized:
            return recognitionManager.isRecording ? "Recording... Speak now" : "Ready to record"
        case .denied:
            return "Speech recognition access denied"
        case .restricted:
            return "Speech recognition restricted on this device"
        case .notDetermined:
            return "Requesting speech recognition access..."
        @unknown default:
            return "Speech recognition status unknown"
        }
    }
}

struct SpeechToTextView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechToTextView()
    }
}
