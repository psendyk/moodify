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
    var playlists: [Playlist] = [Playlist]()
    var profilePicture: UIImage?
    var topArtists: [String] = [String]()
    var topGenres: [String] = [String]()
    var currentMood: String?
    
    init(username: String) {
        self.username = username;
    }
    
}
