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
    var playlists: [Playlist]
    var profilePicture: UIImage?
    var topArtists: [String]
    var topGenres: [String]
    var currentMood: Mood
    
    init() {
        playlists = []
    }
    
}

class Playlist {

    var id: Int
    var name: String
    var tracks: [Track]
        
    init(tracks: [Track], id: Int) {
        self.id =
        self.name = "Playlist" + String(id)
        self.tracks = tracks
    }
}
    
class Track {
    
    var id: String
    var name: String
    var artist: String
        
    init(id: String, name: String, artist: String) {
        self.id = id
        self.name = name
        self.artist = artist
    }
}

