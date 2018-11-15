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
    var currentMood: String?
    
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
    
    func getPlaylists() -> [Playlist] {
        return self.playlists
    }
    
}
