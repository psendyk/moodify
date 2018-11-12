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
    var currentMood: String
    
    init() {
        playlists = []
    }
    
    func createPlaylist(mood: String) {
        var tracks = []
        var playlist = Playlist(tracks, id: playlists.count + 1)
        playlists.append(playlist)
    }
    
    // gets user's top artists and genres
    func getUserFavorites() {
        // make request 
    }
    
    // gets recommendations based on artists, genres, and
    func getRecommendations() {
        
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

class Mood {
    
    var name: String
    var danceability: Int
    var energy: Int
    var instrumentalness: Int
    var tempo: Int
    var valence: Int
    
    init(name: String, danceability: Int, energy: Int, instrumentalness: Int, tempo: Int, valence: Int) {
        self.danceability = danceability
        self.energy = energy
        self.instrumentalness = instrumentalness
        self.tempo = tempo
        self.valence = valence
    }
}

