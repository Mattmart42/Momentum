//
//  SpeechActivityViewController.swift
//  Momentm_
//
//  Created by Matthew Martinez on 3/20/25.
//

import UIKit
import Speech
import AVFoundation

class SpeechActivityViewController: UIViewController {
    
    // MARK: - Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isRecording = false {
        didSet {
            recordButton.backgroundColor = isRecording ? .red : .systemBlue
            recordButton.setTitle(isRecording ? "Stop Recording" : "Start Recording", for: .normal)
        }
    }
    
    // MARK: - UI Elements
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Recording", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var transcriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the button to start recording"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Record Activity"
        
        view.addSubview(statusLabel)
        view.addSubview(recordButton)
        view.addSubview(transcriptionTextView)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            recordButton.widthAnchor.constraint(equalToConstant: 200),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            transcriptionTextView.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 30),
            transcriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transcriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            transcriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            nextButton.topAnchor.constraint(equalTo: transcriptionTextView.bottomAnchor, constant: 30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 150),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Speech Recognition
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.statusLabel.text = "Ready to record"
                    self?.recordButton.isEnabled = true
                    
                case .denied:
                    self?.statusLabel.text = "Speech recognition access denied by user"
                    self?.recordButton.isEnabled = false
                    
                case .restricted, .notDetermined:
                    self?.statusLabel.text = "Speech recognition not authorized"
                    self?.recordButton.isEnabled = false
                    
                @unknown default:
                    self?.statusLabel.text = "Speech recognition not available"
                    self?.recordButton.isEnabled = false
                }
            }
        }
    }
    
    private func startRecording() {
        // Clear previous recognition task
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
            statusLabel.text = "Audio session setup failed"
            return
        }
        
        // Set up recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check for audio input
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            statusLabel.text = "Unable to create recognition request"
            return
        }
        
        // Allow partial results
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcriptionTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                // Enable the next button if we have text
                if !self.transcriptionTextView.text.isEmpty {
                    self.nextButton.isEnabled = true
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.isRecording = false
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
            statusLabel.text = "Recording... Speak now"
            isRecording = true
        } catch {
            statusLabel.text = "Audio engine couldn't start: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        isRecording = false
        statusLabel.text = "Recording stopped"
    }
    
    // MARK: - Actions
    @objc private func recordButtonTapped() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc private func nextButtonTapped() {
        // Create activity edit view controller and pass the transcribed text
        let editVC = ActivityEditViewController(transcriptionText: transcriptionTextView.text)
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// Simple placeholder for the edit screen
class ActivityEditViewController: UIViewController {
    private let transcriptionText: String
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    init(transcriptionText: String) {
        self.transcriptionText = transcriptionText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Edit Activity"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(textView)
        textView.text = transcriptionText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    @objc private func saveButtonTapped() {
        // Here you would process and save the activity
        // For now, just pop back to the main screen
        navigationController?.popToRootViewController(animated: true)
    }
}
