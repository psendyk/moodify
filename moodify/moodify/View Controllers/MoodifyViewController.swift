//
//  MoodifyViewController.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation

protocol MoodifyViewController {
    
    var spotifyController: SpotifyController! { get set }
    var currentUser: CurrentUser! { get set }
    
}
