//
//  SpotifyController.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/9/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation

class SpotifyController {
    
    //var configuration: SPTConfiguration!
    //var sessionManager: SPTSessionManager!
    var currentUser: CurrentUser
    
    init() {
        //TODO: get current user?
        currentUser = CurrentUser(username: "")
    }
    
    // creates playlist for user's current mood
    func createPlaylist() {
        updateUserFavorites()
        var tracks = getRecommendations()
        var playlist = Playlist(tracks: tracks, id: currentUser.playlists.count + 1)
        currentUser.playlists.append(playlist)
    }
    
    // gets current user's top artists and genres
    func updateUserFavorites() {
        var topArtists = [String]()
        var topGenres = [String]()
        // make request "https://api.spotify.com/v1/me/top/artists?limit=5"
        currentUser.topArtists = topArtists
        currentUser.topGenres = topGenres
    }
    
    // gets recommendations based on current user's top artists/genres and current mood
    func getRecommendations() -> [Track] {
        var tracks = [Track]()
        var mood = currentUser.currentMood
        // make request
        return tracks
    }
    
}
