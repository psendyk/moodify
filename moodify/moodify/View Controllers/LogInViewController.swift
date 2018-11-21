//
//  LoginViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SPTSessionManagerDelegate {

    var spotifyController: SpotifyController!
    var currentUser: CurrentUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spotifyController = SpotifyController()
        self.spotifyController.configuration = self.configuration
        self.spotifyController.sessionManager = self.sessionManager

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let requestedScopes: SPTScope = [.appRemoteControl, .userTopRead]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
    
    // AUTHORIZATION
    
    let SpotifyClientID = "991ca7685e364b6a98c3cab163e01f47"
    let SpotifyRedirectURL = URL(string: "moodify://spotify-login-callback")!
    
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )
    
    // Might have to set up a server later - now running locally
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://polar-crag-31078.herokuapp.com/swap"),
            let tokenRefreshURL = URL(string: "https://polar-crag-31078.herokuapp.com/refresh") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()
    
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        debugPrint("success", session)
        createCurrentUser()
        self.spotifyController.session = session
        performSegue(withIdentifier: "logInToSpeaker", sender: self)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        debugPrint("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    func createCurrentUser() {
        // Authorize or sign up in the Firebase
        let username = "Dan Garcia"
        self.currentUser = CurrentUser(username: username)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? UINavigationController {
            if var moodifyViewController = dest.topViewController as? MoodifyViewController {
                moodifyViewController.spotifyController = self.spotifyController
                moodifyViewController.currentUser = self.currentUser
            }
        }
    }

}
