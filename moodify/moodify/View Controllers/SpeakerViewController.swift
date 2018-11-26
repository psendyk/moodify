//
//  SpeakerViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import ToneAnalyzer
import TransitionButton


class SpeakerViewController: UIViewController, MoodifyViewController, SFSpeechRecognizerDelegate {
    
    
    
    let toneAnalyzer = ToneAnalyzer(version: "2018-11-23", apiKey: "EaVbmU9ob6iq7n7p4RIrV29rt19t4TDmbQ8N_PSYoFFe")
    
    var spotifyController: SpotifyController!
    var currentUser: CurrentUser!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let createPlaylistButton = TransitionButton(frame: CGRect(x: 50, y: 100, width: 180, height: 40))
    
    
    var textHeightConstraint: NSLayoutConstraint?
    
    
    
    @IBOutlet var textView: UITextView!
    
    var origTVConstraintHeight: CGFloat?
    
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    
    @IBAction func toProfile(_ sender: Any) {
        performSegue(withIdentifier: "speakerToProfile", sender: sender)
    }
    
    // MARK: UIViewController

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        profileButton.setTitle("", for: .normal)
        profileButton.setImage(UIImage(named: "profilepic"), for: .normal) //set profile image
        profileButton.imageView?.layer.borderWidth = 4
        profileButton.imageView?.layer.masksToBounds = false
        profileButton.imageView?.layer.borderColor = UIColor.black.cgColor //set mood color
        profileButton.imageView?.layer.cornerRadius = (profileButton.imageView?.frame.height)!/2
        profileButton.imageView?.clipsToBounds = true
        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
        self.view.addSubview(createPlaylistButton)
        createPlaylistButton.frame.origin = CGPoint(x: self.view.frame.size.width/2 - 90, y: self.view.frame.size.height - 350)
        createPlaylistButton.backgroundColor = .brown
        createPlaylistButton.setTitle("Create Playlist", for: .normal)
        createPlaylistButton.cornerRadius = 20
        createPlaylistButton.spinnerColor = .white
        createPlaylistButton.addTarget(self, action: #selector(playlistButtonAction(_:)), for: .touchUpInside)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 22.0
        self.textHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 59)
        self.textHeightConstraint?.isActive = true
        origTVConstraintHeight = self.textView.contentSize.height
    }
    
    @IBAction func playlistButtonAction(_ button: TransitionButton) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(1) // 3: Do your networking task or background work here.
            if let text = self.textView.text {
                self.extractMood(text, completion: { mood in
                    if let mood = mood {
                        self.currentUser.updateMood(mood: mood)
                        self.spotifyController.createPlaylist(currentUser: self.currentUser, mood: mood, completion: { playlist in
                            if let playlist = playlist {
                                self.currentUser.addPlaylist(playlist: playlist)
                                self.performSegue(withIdentifier: "speakerToPlaylist", sender: self)
                            }
                        })
                    }
                })
                
            }
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                button.stopAnimation(animationStyle: .normal, completion: {
                    
                })
            })
        })
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        
        // Make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    
    
    func adjustTextViewHeight() {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint?.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                
                self.textView.text = result.bestTranscription.formattedString
                
                var frame = self.textView.frame
                frame.size.height = self.textView.contentSize.height
                self.textView.frame = frame
                self.adjustTextViewHeight()
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            // process the text from textView
        } else {
            do {
                try startRecording()
                recordButton.setTitle("Stop Recording", for: [])
                self.textHeightConstraint?.constant = origTVConstraintHeight ?? 0
                self.view.layoutIfNeeded()
            } catch {
                recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
    
    func extractMood(_ text: String, completion: @escaping ((String?) -> Void)) {
        toneAnalyzer.serviceURL = "https://gateway.watsonplatform.net/tone-analyzer/api"
        let toneInput = ToneInput(text: text)
        toneAnalyzer.tone(toneInput: toneInput, success: { tone in
            if let tones = tone.documentTone.tones {
                completion(tones[0].toneName)
            } else {
                completion("")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dest = segue.destination as? MoodifyViewController {
            dest.currentUser = self.currentUser
            dest.spotifyController = self.spotifyController
        }
        if let dest = segue.destination as? PlaylistViewController {
            if let playlist = self.currentUser.latestPlaylist() {
                dest.playlist = playlist
            }
        }
    }
}
