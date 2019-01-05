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
    var trackAttributes = ["Joy": ["energy": 0.8, "danceability": 0.9, "instrumentalness": 0.3, "valence": 1],
                           "Sadness": ["energy": 0, "danceability": 0, "instrumentalness": 0.8, "valence": 0],
                           "Anger": ["energy": 1, "danceability": 0.2, "instrumentalness": 0.3, "valence": 0.1],
                           "Fear": ["energy": 0.4, "danceability": 0, "instrumentalness": 0.8, "valence": 0.1]]
    
    func getAttrWithNoise(mood: String, attr: String) -> String {
        print(mood)
        let r = Double.random(in: -0.1...0.1)
        return String(min(1, max(0, trackAttributes[mood]![attr]! + r)))
    }
    
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
        let headers: HTTPHeaders = ["Authorization": "Bearer " + self.session.accessToken]
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                if let imageUrl = json["images"][0]["url"].string {
                    Alamofire.request(imageUrl).responseImage(completionHandler: { response in
                        if let image = response.result.value {
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    })
                } else {
                    let image = UIImage(named: "oski")
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    // Get user's Spotify name
    func getUsersName(completion: @escaping ((String?) -> Void)) {
        let headers: HTTPHeaders = ["Authorization": "Bearer " + self.session.accessToken]
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                completion(json["display_name"].string!)
            } else {
                completion(nil)
            }
        }
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
                    topArtists.append(json["items"][i]["id"].string!)
                }
                topArtists = topArtists.filter{$0 != "Travis Scott"}
                let shuffled = Array(topArtists.shuffled()[0...1])
                completion(shuffled)
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
        
        Alamofire.request("https://api.spotify.com/v1/me/top/artists?limit=25", headers: headers).responseJSON { response in
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
                var topCounts_ = Array(topCounts[0...1])
                topCounts_.append("edm")
                completion(topCounts_)
            } else {
                completion(nil)
            }
        }
    }
    
    func getRecommendations(currentUser: CurrentUser, completion: @escaping ([Track]?) -> Void) {
    // Get recommendations based on current user's top artists/genres and current mood
        var tracks = [Track]()
        let mood = currentUser.getCurrentMood()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        getTopArtists(currentUser: currentUser, completion: { topArtists in
            if let topArtists = topArtists {
                self.getTopGenre(currentUser: currentUser, completion: { topGenre in
                    if let topGenre = topGenre {
                        let numTracks = currentUser.getSetting(setting: "numTracks")
                        let limitStr = "?limit=" + String(50)
                        let popularityStr = "&popularity=" + String(currentUser.getSetting(setting: "popularity"))
                        let artistsStr = "&seed_artists=" + topArtists.joined(separator: ",")
                        let genreStr = "&seed_genre=" + topGenre.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
                        let attrStr = "&target_energy=" + self.getAttrWithNoise(mood: mood, attr: "energy") + "&target_danceability=" + self.getAttrWithNoise(mood: mood, attr: "danceability") + "&target_instrumentalness=" + self.getAttrWithNoise(mood: mood, attr: "instrumentalness") + "&target_valence=" + self.getAttrWithNoise(mood: mood, attr: "valence")
                        let urlStr = "https://api.spotify.com/v1/recommendations" + limitStr + popularityStr + artistsStr + genreStr + attrStr
                        print(urlStr)
                        let url = URL(string: urlStr)!
                        Alamofire.request(url, headers: headers).responseJSON { response in
                            if let data = response.data {
                                let json = JSON(data)
                                for (_, track) in json["tracks"]{
                                    tracks.append(Track(id: track["id"].string!, name: track["name"].string!, artist: track["artists"][0]["name"].string!, coverUrl: track["album"]["images"][2]["url"].string!))
                                }
                                completion(Array(tracks.shuffled()[0...numTracks]))
                            } else {
                                completion(nil)
                            }
                        }
                    }
                })
            }
        })
    }
}
