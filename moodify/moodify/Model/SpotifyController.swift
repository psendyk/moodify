//
//  SpotifyController.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/9/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON



class SpotifyController {
    
    var sessionManager: SPTSessionManager!
    var session: SPTSession!
    var configuration: SPTConfiguration!
    
    // We make it a variable because we'll either let user adjust it or adjust it on their listening history
    var trackAttributes = ["happy": ["energy": 0.8, "danceability": 0.8, "instrumentalness": 0.5, "valence": 0.9],
                           "sad": ["energy": 0.3, "danceability": 0.1, "instrumentalness": 0.8, "valence": 0.3],
                           "angry": ["energy": 0.9, "danceability": 0.4, "instrumentalness": 0.3, "valence": 0.3],
                           "stressed": ["energy": 0.4, "danceability": 0.2, "instrumentalness": 0.8, "valence": 0.9]]
    
    // creates playlist for user's current mood
    func createPlaylist(currentUser: CurrentUser, mood: String, completion: @escaping ((Playlist?) -> Void)) {
        getRecommendations(currentUser: currentUser, completion: { tracks in
            if let tracks = tracks {
                let playlist = Playlist(tracks: tracks, id: currentUser.getPlaylists().count + 1, mood: currentUser.currentMood!)
                completion(playlist)
            } else {
                completion(nil)
            }
        })
    }
    
    func getTopArtists(currentUser: CurrentUser, completion: @escaping ([String]?) -> Void) {
    // Get current user's top artists
        var topArtists = [String]()
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        
        Alamofire.request("https://api.spotify.com/v1/me/top/artists?limit=5", headers: headers).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                for i in 0...json["items"].count-1 {
                    topArtists.append(json["items"][i]["name"].string!)
                }
                completion(topArtists)
            } else {
                completion(nil)
            }
        }
    }
    
    func getTopGenre(currentUser: CurrentUser, completion: @escaping ([String]?) -> Void) {
    // Get current user's top genres
        var topGenre = [String]()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        
        Alamofire.request("https://api.spotify.com/v1/me/top/artists?limit=5", headers: headers).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                print(json)
                for i in 0...json["items"].count-1 {
                    for genre in json["items"][i]["genres"] {
                        topGenre.append(genre.1.string!)
                    }
                    completion(topGenre)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getRecommendations(currentUser: CurrentUser, completion: @escaping ([Track]?) -> Void) {
    // Get recommendations based on current user's top artists/genres and current mood
        var tracks = [Track]()
        let mood = currentUser.getCurrentMood()
        let trackAttributes = self.trackAttributes[mood]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        getTopGenre(currentUser: currentUser, completion: { topGenre in
            Alamofire.request("https://api.spotify.com/v1/recommendations?limit=10", headers: headers).responseJSON { response in
                if let data = response.data {
                    let json = JSON(data)
                    for (key, subJson) in json {
                        if key == "error" {
                            completion(nil)
                        }
                    }
                    print(json)
                    completion(tracks)
                } else {
                    completion(nil)
                }
            }
        })
        // make request
    }
    
}
