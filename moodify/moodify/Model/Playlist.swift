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
    
    var id: String
    var name: String
    var tracks: [Track]
    var mood: String
    var timestamp: String
    var moodImage: UIImage?

    init(tracks: [Track], id: String, mood: String, name: String) {
        self.id = "p" + id
        self.name = name // Set an actual name later (maybe the phrase that the user said?)
        self.tracks = tracks
        self.mood = mood
        self.moodImage = Playlist.moodImages[mood]?[Int.random(in: 0 ..< Playlist.moodImages.count)]
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        self.timestamp =  formatter.string(from: Date()) // Get current timestamp
    }
    
    func getTracks() -> [Track] {
        return self.tracks
    }
    
    func getId() -> String {
        return self.id
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getMood() -> String {
        return self.mood
    }
    
    func getTimestamp() -> String {
        return self.timestamp
    }
    
}
