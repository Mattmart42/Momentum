//
//  SpeechActivityViewController.swift
//  Momentm_
//
//  Created by Matthew Martinez on 3/20/25.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeechActivityView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss  // Add this for dismissal
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                StatusLabel(status: speechRecognizer.status)
                
                RecordButton(
                    isRecording: isRecording,
                    isEnabled: speechRecognizer.isAuthorized,
                    action: toggleRecording
                )
                
                TranscriptionTextView(text: speechRecognizer.transcription)
                    .frame(height: 250)
                
                NavigationLink(
                    destination: ActivityEditView(transcriptionText: speechRecognizer.transcription),
                    isActive: $showEditView
                ) {
                    ContinueButton(isEnabled: !speechRecognizer.transcription.isEmpty) {
                        showEditView = true
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Record Activity")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()  // Use the dismiss action
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                speechRecognizer.requestAuthorization()
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
        isRecording.toggle()
    }
}

// MARK: - Subviews

struct StatusLabel: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.subheadline)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isRecording ? "Stop Recording" : "Start Recording")
                .foregroundColor(.white)
                .padding()
                .frame(width: 200, height: 50)
                .background(isRecording ? Color.red : Color.blue)
                .cornerRadius(25)
        }
        .disabled(!isEnabled)
    }
}

struct TranscriptionTextView: View {
    let text: String
    
    var body: some View {
        TextEditor(text: .constant(text))
            .font(.system(size: 16))
            .border(Color.gray, width: 1)
            .cornerRadius(8)
            .disabled(true)
    }
}

struct ContinueButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Continue")
                .foregroundColor(.white)
                .padding()
                .frame(width: 150, height: 40)
                .background(Color.green)
                .cornerRadius(15)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Speech Recognizer

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcription = ""
    @Published var status = "Tap the button to start recording"
    @Published var isAuthorized = false
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.status = "Ready to record"
                    self?.isAuthorized = true
                    
                case .denied:
                    self?.status = "Speech recognition access denied by user"
                    self?.isAuthorized = false
                    
                case .restricted, .notDetermined:
                    self?.status = "Speech recognition not authorized"
                    self?.isAuthorized = false
                    
                @unknown default:
                    self?.status = "Speech recognition not available"
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    func startRecording() {
        // Clear previous task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            status = "Audio session setup failed"
            return
        }
        
        // Set up recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check for audio input
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            status = "Unable to create recognition request"
            return
        }
        
        // Configure request
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcription = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            status = "Recording... Speak now"
        } catch {
            status = "Audio engine couldn't start: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        status = "Recording stopped"
    }
}

// MARK: - Edit View

struct ActivityEditView: View {
    @State private var text: String
    @Environment(\.dismiss) private var dismiss
    
    init(transcriptionText: String) {
        _text = State(initialValue: transcriptionText)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .font(.system(size: 16))
                .border(Color.gray, width: 1)
                .cornerRadius(8)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Edit Activity")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Here you would process and save the activity
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview

struct SpeechActivityView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechActivityView()
    }
}
