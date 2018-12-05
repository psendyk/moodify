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
import Material


struct ButtonLayout {
    struct Raised {
        static let width: CGFloat = 150
        static let height: CGFloat = 44
        static let offsetY: CGFloat = 35
    }
}


class SpeakerViewController: UIViewController, MoodifyViewController, SFSpeechRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 7
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = friendCollectionView.dequeueReusableCell(withReuseIdentifier: "friend", for: indexPath) as? friendCollectionViewCell
        cell?.friendButton.setImage(friends[indexPath.row].image, for: .normal)
        cell?.friendButton.imageView?.layer.borderWidth = 4
        cell?.friendButton.imageView?.layer.masksToBounds = false
        cell?.friendButton.imageView?.layer.borderColor = UIColor.black.cgColor //set mood color
        cell?.friendButton.imageView?.layer.cornerRadius = (cell?.friendButton.imageView?.frame.height)!/2
        cell?.friendButton.imageView?.clipsToBounds = true
        cell?.name.text = friends[indexPath.row].name
        return cell!
    }
    
    
    @IBOutlet weak var friendCollectionView: UICollectionView!
    
    
    let toneAnalyzer = ToneAnalyzer(version: "2018-11-23", apiKey: "EaVbmU9ob6iq7n7p4RIrV29rt19t4TDmbQ8N_PSYoFFe")
    
    var spotifyController: SpotifyController!
    var currentUser: CurrentUser!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let createPlaylistButton = TransitionButton(frame: CGRect(x: 97.5, y: 100, width: 180, height: 40))
    
    let raisedRecordButton = RaisedButton(title: "Press to Record", titleColor: .white)
    
    /*let recordGesture = UILongPressGestureRecognizer(target: self, action: #selector(record()))
    recordGesture.minimumPressDuration = 0.1 // seconds
    recordGesture.allowableMovement = 15 // points
    recordGesture.delegate = self
    raisedRecordButton.addGestureRecognizer(recordGesture)*/
    
    var textHeightConstraint: NSLayoutConstraint?
    
    
    
    @IBOutlet var textView: UITextView!
    
    var origTVConstraintHeight: CGFloat?
    
    
    @IBOutlet weak var profileButton: UIButton!
    
    
    @IBAction func toProfile(_ sender: Any) {
        performSegue(withIdentifier: "speakerToProfile", sender: sender)
    }
    
    // MARK: UIViewController

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        profileButton.setTitle("", for: .normal)
        profileButton.setImage(self.currentUser.profilePicture, for: .normal) //set profile image
        profileButton.imageView?.layer.borderWidth = 4
        profileButton.imageView?.layer.masksToBounds = false
        profileButton.imageView?.layer.cornerRadius = (profileButton.imageView?.frame.height)!/2
        profileButton.imageView?.clipsToBounds = true
        // Disable the record buttons until authorization has been granted.
        self.view.addSubview(createPlaylistButton)
        createPlaylistButton.frame.size = CGSize(width: 260, height: 60)
        createPlaylistButton.frame.origin = CGPoint(x: self.view.frame.size.width/2 - createPlaylistButton.frame.width/2, y: 13 * self.view.frame.size.height/16)
        createPlaylistButton.titleLabel?.font =  .boldSystemFont(ofSize: 24)
        createPlaylistButton.backgroundColor = UIColor(red:0.11, green:0.73, blue:0.33, alpha:1.0)
        createPlaylistButton.setTitle("Create Playlist", for: .normal)
        createPlaylistButton.cornerRadius = 30
        createPlaylistButton.spinnerColor = .white
        createPlaylistButton.addTarget(self, action: #selector(playlistButtonAction(_:)), for: .touchUpInside)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 22.0
        self.textHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 59)
        self.textHeightConstraint?.isActive = true
        origTVConstraintHeight = self.textView.contentSize.height
        
        
        raisedRecordButton.pulseColor = .white
        //raisedRecordButton.setImage(UIImage(named: "mic_black_192x192"), for: .normal)
        raisedRecordButton.setImage(UIImage(named: "mic_button_red"), for: .normal)
        raisedRecordButton.addTarget(self, action: #selector(raisedRecordButton(_:)), for: .touchUpInside)
        raisedRecordButton.layer.cornerRadius = 80
        raisedRecordButton.clipsToBounds = true
        
        view.layout(raisedRecordButton)
            .width(CGFloat(160))
            .height(CGFloat(160))
            .center(offsetY: self.view.frame.size.height/8)
        
    }
    
    @IBAction func raisedRecordButton(_ button: RaisedButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            raisedRecordButton.isEnabled = false
            raisedRecordButton.setTitle("Stopping", for: .disabled)
            // process the text from textView
        } else {
            do {
                try startRecording()
                raisedRecordButton.setTitle("Stop Recording", for: [])
                self.textHeightConstraint?.constant = origTVConstraintHeight ?? 0
                self.view.layoutIfNeeded()
            } catch {
                raisedRecordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
    
    @IBAction func playlistButtonAction(_ button: TransitionButton) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        if let text = self.textView.text {
        backgroundQueue.async(execute: {
            
            sleep(1) // 3: Do your networking task or background work here.
                self.extractMood(text, completion: { mood in
                    if let mood = mood {
                        self.currentUser.updateMood(mood: mood)
                        var name = text
                        if name.count > 27 {
                            name = String(name.prefix(27)) + "..."
                        }
                        self.spotifyController.createPlaylist(currentUser: self.currentUser, mood: mood, name: name, completion: { playlist in
                            if let playlist = playlist {
                                self.currentUser.addPlaylist(playlist: playlist)
                                self.performSegue(withIdentifier: "speakerToPlaylist", sender: self)
                            }
                        })
                    }
                })
                
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
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        
        if let name =  self.currentUser.name.components(separatedBy: " ").first {
            self.textView.text = "How's it going, " + name + "?"
        }
        
        switch(currentUser.currentMood) {
        case "Joy":
            profileButton.imageView?.layer.borderColor = UIColor(red:0.99, green:0.87, blue:0.16, alpha:1.0).cgColor
        case "Sadness":
            profileButton.imageView?.layer.borderColor = UIColor(red:0.14, green:0.40, blue:0.64, alpha:1.0).cgColor
        case "Anger":
            profileButton.imageView?.layer.borderColor = UIColor(red:0.99, green:0.20, blue:0.16, alpha:1.0).cgColor
        case "Fear":
            profileButton.imageView?.layer.borderColor = UIColor(red:0.74, green:0.74, blue:0.74, alpha:1.0).cgColor
        default:
            profileButton.imageView?.layer.borderColor = UIColor(red:0.99, green:0.87, blue:0.16, alpha:1.0).cgColor
        }
        
        // Make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.raisedRecordButton.isEnabled = true
                    
                case .denied:
                    self.raisedRecordButton.isEnabled = false
                    self.raisedRecordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.raisedRecordButton.isEnabled = false
                    self.raisedRecordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.raisedRecordButton.isEnabled = false
                    self.raisedRecordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
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
                
                self.raisedRecordButton.isEnabled = true
                self.raisedRecordButton.setTitle("Press to Record", for: [])
    
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
            raisedRecordButton.isEnabled = true
            raisedRecordButton.setTitle("Start Recording", for: [])
        } else {
            raisedRecordButton.isEnabled = false
            raisedRecordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
    // MARK: Interface Builder actions
    
    
    
    func extractMood(_ text: String, completion: @escaping ((String?) -> Void)) {
        toneAnalyzer.serviceURL = "https://gateway.watsonplatform.net/tone-analyzer/api"
        let toneInput = ToneInput(text: text)
        toneAnalyzer.tone(toneInput: toneInput, success: { tone in
            if let tones = tone.documentTone.tones {
                if tones.count > 0 {
                    completion(tones[0].toneName)
                }
            } else {
                completion(nil)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            raisedRecordButton.isEnabled = false
        }
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
