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
        profilePicture.image = UIImage(named: "profilepic")
        // pull name from Spotify
        //username.text = currentUser.name
        profilePicture.layer.borderWidth = 4
        profilePicture.layer.masksToBounds = false
        switch(currentUser.currentMood) {
            case "Joy":
                profilePicture.layer.borderColor = UIColor.yellow.cgColor
            case "Sadness":
                profilePicture.layer.borderColor = UIColor.blue.cgColor
            case "Anger":
                profilePicture.layer.borderColor = UIColor.red.cgColor
            case "Fear":
                profilePicture.layer.borderColor = UIColor.gray.cgColor
            default:
                profilePicture.layer.borderColor = UIColor.black.cgColor
        }
        profilePicture.layer.cornerRadius = (profilePicture.frame.height)/2
        profilePicture.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
