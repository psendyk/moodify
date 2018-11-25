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
            cell.trackTitle.text = track.name
            cell.trackArtist.text = track.artist
            Alamofire.request(track.coverUrl).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    cell.trackImage.image = image
                }
            })
        }
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
            self.appRemote.playerAPI?.play(trackId, callback: defaultCallback)
        }
    }

    
    /*
     Controlling the Spotify remote
     */
    private func playTrack(trackId: String) {
        appRemote.playerAPI?.play(trackId, callback: defaultCallback)
    }

}
