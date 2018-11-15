//
//  Playlist.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation


class Playlist {
    
    var id: Int
    var name: String
    var tracks: [Track]
    
    init(tracks: [Track], id: Int) {
        self.id = id
        self.name = "Playlist" + String(id)
        self.tracks = tracks
    }
}
