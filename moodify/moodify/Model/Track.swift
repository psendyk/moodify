//
//  Track.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation

class Track {
    
    var id: String
    var name: String
    var artist: String
    var cover: UIImage?
    
    init(id: String, name: String, artist: String) {
        self.id = id
        self.name = name
        self.artist = artist
    }
}
