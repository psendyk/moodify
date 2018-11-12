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
    
    init() {
        playlists = []
    }
    
    func createPlaylist(mood: String) {
        tracks = []
        playlist = Playlist(tracks, id: playlists.count + 1)
        playlists.append(playlist)
    }
    
    func getTopTracks() {
        
    }
    
    func filterByMood() {
        
    }
}

class Playlist {

    var id: int
    var name: String
    var tracks: [Track]
        
    init(tracks: [Track], id: int) {
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

