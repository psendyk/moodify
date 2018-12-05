//
//  ProfileViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, MoodifyViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    var spotifyController: SpotifyController!
    var currentUser: CurrentUser!
    var selectedPlaylist: Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        profilePicture.image = self.currentUser.profilePicture
        // pull name from Spotify
        //username.text = currentUser.name
        profilePicture.layer.borderWidth = 8
        profilePicture.layer.masksToBounds = false
        switch(currentUser.currentMood) {
            case "Joy":
                profilePicture.layer.borderColor = UIColor(red:0.99, green:0.87, blue:0.16, alpha:1.0).cgColor
            case "Sadness":
                profilePicture.layer.borderColor = UIColor(red:0.14, green:0.40, blue:0.64, alpha:1.0).cgColor
            case "Anger":
                profilePicture.layer.borderColor = UIColor(red:0.99, green:0.20, blue:0.16, alpha:1.0).cgColor
            case "Fear":
                profilePicture.layer.borderColor = UIColor(red:0.74, green:0.74, blue:0.74, alpha:1.0).cgColor
            default:
                profilePicture.layer.borderColor = UIColor(red:0.99, green:0.87, blue:0.16, alpha:1.0).cgColor
        }
        profilePicture.layer.cornerRadius = (profilePicture.frame.height)/2
        profilePicture.clipsToBounds = true

        self.username.text = self.currentUser.name

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTableViewCell
        let playlist = currentUser.getPlaylists()[indexPath.item]
        cell.name.text = playlist.name
        cell.numTracks.text = String(playlist.tracks.count) + " songs"
        cell.moodImage.image = playlist.moodImage
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlaylist = currentUser.getPlaylists()[indexPath.item]
        performSegue(withIdentifier: "profileToPlaylist", sender: self)
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete playlist from database
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dest = segue.destination as? MoodifyViewController {
            dest.currentUser = self.currentUser
            dest.spotifyController = self.spotifyController
        }
        if let dest = segue.destination as? PlaylistViewController {
            if let playlist = selectedPlaylist {
                dest.playlist = playlist
            }
        }
    }
    
}
