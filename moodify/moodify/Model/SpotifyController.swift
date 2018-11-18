//
//  SpotifyController.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/9/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation
import Alamofire

class SpotifyController {
    
    var sessionManager: SPTSessionManager!
    var session: SPTSession!
    var configuration: SPTConfiguration!
    
    
    // creates playlist for user's current mood
    func createPlaylist(currentUser: CurrentUser, mood: String) -> Playlist {
        let tracks = getRecommendations(currentUser: currentUser)
        let playlist = Playlist(tracks: tracks, id: currentUser.getPlaylists().count + 1, mood: currentUser.currentMood!)
        return playlist
    }
    
    func getTopArtists(currentUser: CurrentUser) -> [String] {
    // Get current user's top artists
        var topArtists = [String]()
        // make request "https://api.spotify.com/v1/me/top/artists?limit=5"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.session.accessToken
        ]
        Alamofire.request("https://api.spotify.com/v1/me/top/artists?limit=5", headers: headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        return topArtists
    }
    
    func getTopGenre(currentUser: CurrentUser) -> [String] {
    // Get current user's top genres
        let topArtists = getTopArtists(currentUser: currentUser)
        var topGenre = [String]()
        // make request to classify artists by genre
        return topGenre
    }
    
    func getRecommendations(currentUser: CurrentUser) -> [Track] {
    // Get recommendations based on current user's top artists/genres and current mood
        var tracks = [Track]()
        let mood = currentUser.currentMood
        let topGenre = getTopGenre(currentUser: currentUser)
        // make request
        return tracks
    }
    
}
