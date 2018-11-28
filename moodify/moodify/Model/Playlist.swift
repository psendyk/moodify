//
//  Playlist.swift
//  moodify
//

//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation

class Playlist {
    
    static let moodImages: [String : [UIImage]] = [
        "Joy": [UIImage(named: "yellow1")!, UIImage(named: "yellow2")!, UIImage(named: "yellow3")!],
        "Sadness": [UIImage(named: "blue1")!, UIImage(named: "blue2")!, UIImage(named: "blue3")!],
        "Anger": [UIImage(named: "red1")!, UIImage(named: "red2")!, UIImage(named: "red3")!],
        "Fear": [UIImage(named: "gray1")!, UIImage(named: "gray2")!, UIImage(named: "gray3")!]
    ]
    
    var id: Int
    var name: String
    var tracks: [Track]
    var mood: String
    var moodImage: UIImage?
    
    init(tracks: [Track], id: Int, mood: String) {
        self.id = id
        self.name = "Playlist " + String(id)
        self.tracks = tracks
        self.mood = mood
        self.moodImage = Playlist.moodImages[mood]?[Int.random(in: 0 ..< Playlist.moodImages.count)]
    }
}
