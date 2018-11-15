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
    
    var configuration: SPTConfiguration!
    var sessionManager: SPTSessionManager!
    var currentUser: CurrentUser!

    
    // creates playlist for user's current mood
    func createPlaylist() {
        var tracks = getRecommendations()
        var playlist = Playlist(tracks: tracks, id: currentUser.getPlaylists().count + 1)
        currentUser.playlists.append(playlist)
    }
    
    func getTopArtists() -> [String] {
    // Get current user's top artists
        var topArtists = [String]()
        // make request "https://api.spotify.com/v1/me/top/artists?limit=5"
        return topArtists
    }
    
    func getTopGenre() -> [String] {
    // Get current user's top genres
        var topGenre = getTopArtists()
        // make request to classify artists by genre
        return topGenre
    }
    
    func getRecommendations() -> [Track] {
    // Get recommendations based on current user's top artists/genres and current mood
        var tracks = [Track]()
        var mood = currentUser.currentMood
        var topGenre = getTopGenre()
        // make request
        return tracks
    }
    
}
