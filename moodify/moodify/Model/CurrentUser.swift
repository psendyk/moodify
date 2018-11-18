//
//  CurrentUser.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/11/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import Alamofire

class CurrentUser {
    
    var username: String!
    var playlists: [Playlist]!
    var profilePicture: UIImage!
    var currentMood: String!
    
    var settings = ["numTracks": 20, "popularity": 0.8]
    
    init(username: String) {
        self.username = username
        self.loadPlaylists()
        self.loadPicture()
        self.loadMood()
    }
    
    func loadPlaylists() {
        self.playlists = [Playlist]()
        // Load all of user's playlist from the Firebase
    }
    
    func loadPicture() {
        // Load user's picture from the Firebase (note that it won't update if it changes in Spotify)
        self.profilePicture = UIImage(named: "oski")
    }
    
    func loadMood() {
        // Get the most recent mood from the Firebase
    }
    
    func updateMood(mood: String) {
        // Update user's current mood
        self.currentMood = mood
    }
    
    func getCurrentMood() -> String {
        return self.currentMood
    }
    
    func getPlaylists() -> [Playlist] {
        return self.playlists
    }
    
    func addPlaylist(playlist: Playlist) {
        self.playlists.append(playlist)
    }
    
    func latestPlaylist() -> Playlist {
        return self.playlists[self.playlists.count-1]
    }
    
}
