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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        profilePicture.setImage(UIImage(named: "profilepic"), for: .normal) //set profile image
        profilePicture.layer.borderWidth = 4
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor //set mood color
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
        cell.numTracks.text = String(playlist.tracks.count)
        cell.moodImage.image = UIImage(named: playlist.mood)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Select playlist - perform seque to the PlaylistView
        performSegue(withIdentifier: "profileToPlaylist", sender: self)
    }
    
}
