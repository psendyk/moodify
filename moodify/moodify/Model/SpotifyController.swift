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
    var trackAttributes = ["Joy": ["energy": "0.8", "danceability": "0.8", "instrumentalness": "0.5", "valence": "0.9"],
                           "Sadness": ["energy": "0.3", "danceability": "0.1", "instrumentalness": "0.8", "valence": "0.3"],
                           "Anger": ["energy": "0.9", "danceability": "0.4", "instrumentalness": "0.3", "valence": "0.3"],
                           "Fear": ["energy": "0.4", "danceability": "0.2", "instrumentalness": "0.8", "valence": "0.9"]]
    
    // Get the email from User's Spotify account
    func getUsersEmail(completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = ["Authorization": "Bearer " + self.session.accessToken]
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                completion(json["email"].string!)
            } else {
                completion(nil)
            }
        }
    }
    
    // Get user's Spotify profile picture
    func getUsersPicture(completion: @escaping ((UIImage?) -> Void)) {
        completion(UIImage())
        // TODO: Get profile picture from the Web API
    }
    
    // Get user's Spotify name
    func getUsersName(completion: @escaping ((String?) -> Void)) {
        completion("")
        // TODO: Get user's name from the Web API
    }

    
    // creates playlist for user's current mood
    func createPlaylist(currentUser: CurrentUser, mood: String, name: String, completion: @escaping ((Playlist?) -> Void)) {
        getRecommendations(currentUser: currentUser, completion: { tracks in
            if let tracks = tracks {
                let playlist = Playlist(tracks: tracks, id: String(currentUser.getPlaylists().count + 1), mood: currentUser.getCurrentMood(), name: name)
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
                for i in 0...json["items"].count-1 {
                    for genre in json["items"][i]["genres"] {
                        topGenre.append(genre.1.string!)
                    }
                }
                var counts = [String:Int]()
                for item in topGenre {
                    counts[item] = (counts[item] ?? 0) + 1
                }
                let topCounts = counts.sorted { $0.value > $1.value }.map { $0.key }
                completion(Array(topCounts[0...4]))
            } else {
                completion(nil)
            }
        }
    }
    
    func getRecommendations(currentUser: CurrentUser, completion: @escaping ([Track]?) -> Void) {
    // Get recommendations based on current user's top artists/genres and current mood
        var tracks = [Track]()
        let mood = currentUser.getCurrentMood()
        let trackAttributes = self.trackAttributes[mood]!
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        getTopGenre(currentUser: currentUser, completion: { topGenre in
            if let topGenre = topGenre {
                let limitStr = "?limit=" + currentUser.getSetting(setting: "numTracks")
                let popularityStr = "&popularity=" + currentUser.getSetting(setting: "popularity")
                let genreStr = "&seed_genres=" + topGenre.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
                let attrStr = "&target_energy=" + trackAttributes["energy"]! + "&target_danceability=" + trackAttributes["danceability"]! + "&target_instrumentalness=" + trackAttributes["instrumentalness"]! + "&target_valence=" + trackAttributes["valence"]! // We can later randomzie this part a little bit
                let urlStr = "https://api.spotify.com/v1/recommendations" + limitStr + popularityStr + genreStr + attrStr
                let url = URL(string: urlStr)!
                print(url)
                Alamofire.request(url, headers: headers).responseJSON { response in
                    if let data = response.data {
                        let json = JSON(data)
                        for (_, track) in json["tracks"]{
                            tracks.append(Track(id: track["id"].string!, name: track["name"].string!, artist: track["artists"][0]["name"].string!, coverUrl: track["album"]["images"][2]["url"].string!))
                        }
                        completion(tracks)
                    } else {
                        completion(nil)
                    }
                }
            }
        })
    }
}
