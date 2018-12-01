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
    // need outlet as well as action to change play/puase image
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBAction func playPause(_ sender: Any) {
        if let trackId = currTrackId {
            if playing! {
                playTrack(trackId: trackId)
                playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
                playing = false
            } else {
                // pause
                playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
                playing = true
            }
        }
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
        
        if let playlist = self.playlist {
            self.name.text = playlist.name
        }
        
        self.appRemote.connectionParameters.accessToken = self.spotifyController.session.accessToken
        self.appRemote.connect()
        
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
            currTrackId = "spotify:track:"+track.id
            if track.name.count >= 37 {
                currentSongTitle.text = String(track.name.prefix(34)) + "..."
            } else {
                currentSongTitle.text = track.name
            }
            currentSongArtist.text = track.artist
            playing = true
            playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
            self.appRemote.playerAPI?.play(currTrackId!, callback: defaultCallback)
        }
    }

    
    /*
     Controlling the Spotify remote
     */
    private func playTrack(trackId: String) {
        appRemote.playerAPI?.play(trackId, callback: defaultCallback)
    }

}
