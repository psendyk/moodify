//
//  Playlist.swift
//  moodify
//

//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation

class Playlist {
    
    var id: String
    var name: String
    var tracks: [Track]
    var mood: String
    var timestamp: String
    
    init(tracks: [Track], id: String, mood: String, name: String) {
        self.id = id 
        self.name = name // Set an actual name later (maybe the phrase that the user said?)
        self.tracks = tracks
        self.mood = mood
        self.timestamp = "" // Get current timestamp
    }
}
