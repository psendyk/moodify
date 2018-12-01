//
//  PlaylistViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit
import Alamofire


class PlaylistViewController: UIViewController, MoodifyViewController, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentSongTitle: UILabel!
    @IBOutlet weak var currentSongArtist: UILabel!
    var currTrack = 0
    // need outlet as well as action to change play/puase image
    @IBOutlet weak var playPauseButton: UIButton!
    
    private var playerState: SPTAppRemotePlayerState?
    
    @IBAction func playPause(_ sender: Any) {
        if let paused = self.playerState?.isPaused {
            if paused {
                startPlayback()
            } else {
                pausePlayback()
            }
        }
    }
    
    private func updatePlayPauseButtonState(_ paused: Bool) {
        if paused {
            self.playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
            self.playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }
    
    private func updateCurrentTrack() {
        self.currentSongTitle.text = self.playerState!.track.name
        self.currentSongArtist.text = self.playerState!.track.artist.name
    }
    
    
    // show pause button when playing, play button when not playing
    var playing: Bool?
    var currTrackId: String?
    
    var spotifyController: SpotifyController!
    var currentUser: CurrentUser!
    
    var playlist: Playlist?
    var latest: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.appRemote.connectionParameters.accessToken = self.spotifyController.session.accessToken
        self.appRemote.connect()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let playlist = self.playlist {
            self.name.text = playlist.name
            let trackId = "spotify:track:" + self.playlist!.tracks[0].getId()
            self.playTrack(trackId: trackId)
            self.currTrack = 0
        }
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("connected")
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
        debugPrint("Track name: %@", playerState.track.name)
        self.playerState = playerState
        updatePlayPauseButtonState(self.playerState!.isPaused)
        updateCurrentTrack()
    }
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.spotifyController.configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
        
    }()
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    
    fileprivate func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /* UI */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = playlist {
            return p.tracks.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackTableViewCell
        let track = (playlist?.tracks[indexPath.item])
        if let track = track {
            if track.name.count >= 34 {
                cell.trackTitle.text = String(track.name.prefix(31)) + "..."
            } else {
                 cell.trackTitle.text = track.name
            }
            cell.trackArtist.text = track.artist
            Alamofire.request(track.coverUrl).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    cell.trackImage.image = image
                }
            })
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackTableViewCell
        if let track = cell.track {
            playTrack(trackId: track.id)
        }
        */
        if let track = self.playlist?.tracks[indexPath.item] {
            let trackId = "spotify:track:"+track.id
            playTrack(trackId: trackId)
            
        }
        self.currTrack = indexPath.item
    }

    
    /*
     Controlling the Spotify remote
     */

    
    private func playTrack(trackId: String) {
        print(trackId)
        appRemote.playerAPI?.play(trackId, callback: defaultCallback)
    }
    
    private func skipNext() {
        if self.currTrack < self.playlist!.tracks.count - 1 {
            playTrack(trackId: self.playlist!.tracks[self.currTrack + 1].getId())
            self.currTrack += 1
        }
    }
    
    private func skipPrevious() {
        if self.currTrack > 0 {
            playTrack(trackId: self.playlist!.tracks[self.currTrack - 1].getId())
            self.currTrack -= 1
        }
    }
    
    fileprivate func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    fileprivate func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }

}
