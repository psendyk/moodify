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
    
    // The following are stored in the Firebase
    var username: String
    var profilePicture: UIImage!
    var currentMood = "Joy" // Everyone is happy at the beginning
    var settings = ["numTracks": "25", "popularity": "80"] // Allow the user to change those in the settings
    
    // The following we get from Spotify API since they're not specific to our app and might change
    var playlists: [Playlist]!
    var name: String!
    
    let dbRef = Database.database().reference()
    
    init(username: String) {
        self.username = username
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error == nil {
                self.dbRef.child("Users/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        self.loadPlaylists()
                        self.loadMood()
                    } else {
                        // Create the user reference in the firebase
                    }
                })
            } else {
                print("Can't sign in to the Firebase")
            }
        })
    }
    
    func loadPlaylists() {
        // Load all of user's playlist from the Firebase
        self.dbRef.child("Users/\(username)/Playlists").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let playlistsDict = snapshot.value as? [String : [String : [String]]] {
                    for keyVal in playlistsDict {
                        self.getTracks(trackIds: keyVal.1["Tracks"]!, completion: { tracks in
                            if let tracks = tracks {
                                self.playlists.append(Playlist(tracks: tracks, id: keyVal.0, mood: keyVal.1["Mood"]![0], name: keyVal.1["Name"]![0]))
                            }
                        })
                    }
                }
             }
        })
    }
    
    func getTracks(trackIds: [String], completion: @escaping (([Track]?) -> Void)) {
        
        var tracks = [Track]()
        self.dbRef.child("Tracks").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let tracksDict = snapshot.value as? [String : [String : String]] {
                    for trackId in trackIds {
                        if let track = tracksDict[trackId] {
                            tracks.append(Track(id: track["ID"]!, name: track["Name"]!, artist: track["Artist"]!, coverUrl: track["coverUrl"]!))
                        }
                    }
                }
                completion(tracks)
            } else {
                completion(nil)
            }
        })
    }
    
    func loadMood() {
        // Get the most recent mood from the Firebase
    }
    
    func updateMood(mood: String) {
        // Update user's current mood
        self.currentMood = mood
    }
    
    func getCurrentMood() -> String {
        return self.currentMood
    }
    
    func getPlaylists() -> [Playlist] {
        return self.playlists
    }
    
    func addPlaylist(playlist: Playlist) {
        self.playlists.append(playlist)
        // TODO: Write to the Firebase
    }
    
    func latestPlaylist() -> Playlist? {
        if self.playlists.count > 0 {
            return self.playlists[self.playlists.count-1]
        }
        return nil
    }
    
    func getSetting(setting: String) -> String {
        return self.settings[setting]!
    }
    
    func updateSetting(setting: String, newValue: String) -> Void {
        self.settings[setting] = newValue
        // TODO: Write to the Firebase
    }
    
}
