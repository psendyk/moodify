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
    var currentMood: String! // Everyone is happy at the beginning
    var settings: [String : String]! // Allow the user to change those in the settings
    
    // The following we get from Spotify API since they're not specific to our app and might change
    var playlists: [Playlist]!
    var name: String!
    
    let dbRef = Database.database().reference()
    
    init(username: String) {
        let charactersToRemove = NSCharacterSet.alphanumerics.inverted
        let ref = username.components(separatedBy: charactersToRemove).joined()
        self.username = ref
        self.playlists = [Playlist]()
        self.dbRef.child("Users/\(self.username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.loadPlaylists()
                self.loadMood()
                self.loadSettings()
            } else {
                let userRef = self.dbRef.child("Users/\(self.username)")
                userRef.child("Mood").setValue("Joy")
                userRef.child("Playlists").setValue([String : [String : String]]())
                userRef.child("Settings").setValue(["numTracks": "25", "popularity": "80"])
                self.loadSettings()
                self.currentMood = "Joy"
            }
        })
    }
    
    func loadPlaylists() {
        // Load all of user's playlist from the Firebase
        self.dbRef.child("Users/\(self.username)/Playlists").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let playlistsDict = snapshot.value as! [String : AnyObject]
                    for keyVal in playlistsDict {
                        if let playlistDict = keyVal.1 as? [String : [String]] {
                            self.getTracks(trackIds: playlistDict["Tracks"]!, completion: { tracks in
                                if let tracks = tracks {
                                    self.playlists.append(Playlist(tracks: tracks, id: keyVal.0, mood: playlistDict["Mood"]![0], name: playlistDict["Name"]![0]))
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
                            tracks.append(Track(id: track["ID"]!, name: track["Name"]!, artist: track["Artist"]!, coverUrl: track["Cover"]!))
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
        self.dbRef.child("Users/\(self.username)/Mood").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let mood = snapshot.value as! String
                self.currentMood = mood
            }
        })
    }
    
    func loadSettings() {
        self.dbRef.child("Users/\(self.username)/Settings").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let settings = snapshot.value as! [String : String]
                self.settings = settings
            }
        })
    }
    
    func updateMood(mood: String) {
        // Update user's current mood
        self.currentMood = mood
        let moodRef = self.dbRef.child("Users/\(self.username)/Mood")
        moodRef.setValue(mood)
    }
    
    func getCurrentMood() -> String {
        return self.currentMood
    }
    
    func getPlaylists() -> [Playlist] {
        return self.playlists
    }
    
    func addPlaylist(playlist: Playlist) {
        self.playlists.append(playlist)
        // First put the tracks in the database
        let tracksRef = self.dbRef.child("Tracks")
        tracksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for track in playlist.getTracks() {
                if !snapshot.hasChild(track.getId()) {
                    let trackDict = ["ID" : track.getId(), "Name" : track.getName(), "Artist" : track.getArtist(), "Cover" : track.getCover()]
                    tracksRef.child(track.getId()).setValue(trackDict)
                }
            }
        })
        // Now add the playlist
        let playlistRef = self.dbRef.child("Users/\(self.username)/Playlists")
        let playlistDict = ["Name" : [playlist.getName()], "Mood" : [playlist.getMood()], "Tracks" : playlist.getTracks().map { $0.getId() } ]
        playlistRef.child(playlist.getId()).setValue(playlistDict)
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
        let settingsRef = self.dbRef.child("Users/\(self.username)/Settings")
        settingsRef.child(setting).setValue(newValue)
    }
    
}
