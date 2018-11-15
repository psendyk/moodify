//
//  AllPlaylistsViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit

class AllPlaylistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var currentUser: CurrentUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // DEBUG
        currentUser = CurrentUser(username: "username")
        currentUser?.profilePicture = #imageLiteral(resourceName: "testProfilePicture")
        
        var tracks = [Track]()
        tracks.append(Track(id: "id1", name: "name1", artist: "artist1"))
        tracks.append(Track(id: "id2", name: "name2", artist: "artist2"))
        
        currentUser?.playlists.append(Playlist(tracks: tracks, id: 1))
        currentUser?.playlists.append(Playlist(tracks: tracks, id: 2))
        
        // keep
        username.text = currentUser?.username
        profilePicture.image = currentUser?.profilePicture
        //profilePicture.layer.borderColor = CGColor()
        profilePicture.layer.borderWidth = 5
        profilePicture.layer.masksToBounds = true;
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = currentUser {
            return c.playlists.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allPlaylistsCell", for: indexPath) as! AllPlaylistsTableViewCell
        let playlist = (currentUser?.playlists[indexPath.item])
        cell.name.text = playlist?.name
        if let p = playlist {
            cell.numSongs.text = String(p.tracks.count) + " songs"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
