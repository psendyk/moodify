//
//  LoginViewController.swift
//  moodify
//
//  Created by Stephen Boyle on 11/7/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit
import TransitionButton

class LoginViewController: UIViewController, SPTSessionManagerDelegate {
    
    var spotifyController: SpotifyController!
    var currentUser: CurrentUser?
    
    let button = TransitionButton(frame: CGRect(x: 50, y: 100, width: 180, height: 40))
    // please use Autolayout in real project
    
    //replace when we have logo
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotifyController = SpotifyController()
        self.spotifyController.configuration = self.configuration
        self.spotifyController.sessionManager = self.sessionManager
        
        //logoImage.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2 - 150)
        self.view.addSubview(button)
        button.setTitle("Log in with Spotify", for: .normal)
        button.frame.size = CGSize(width: 260, height: 60)
        button.frame.origin = CGPoint(x: self.view.frame.size.width/2 - 130, y: self.view.frame.size.height - 460)
        button.backgroundColor = UIColor(red:0.11, green:0.73, blue:0.33, alpha:1.0)
        button.titleLabel?.font =  .boldSystemFont(ofSize: 24)
        button.cornerRadius = 30
        button.spinnerColor = .white
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(1) // 3: Do your networking task or background work here.
            let requestedScopes: SPTScope = [.appRemoteControl, .userTopRead, .userReadEmail]
            self.sessionManager.initiateSession(with: requestedScopes, options: .default)
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                button.stopAnimation(animationStyle: .expand, completion: {
                    
                })
            })
        })
    }
    
    let SpotifyClientID = "991ca7685e364b6a98c3cab163e01f47"
    let SpotifyRedirectURL = URL(string: "moodify://spotify-login-callback")!
    
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )
    
    // Perform the token swap
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://polar-crag-31078.herokuapp.com/swap"),
            let tokenRefreshURL = URL(string: "https://polar-crag-31078.herokuapp.com/refresh") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = ""
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()
    
    // Session succesfully initiated
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        debugPrint("success", session)
        self.spotifyController.session = session
        createCurrentUser(completion: { currentUser in
            if let currentUser = currentUser {
                self.currentUser = currentUser
                self.performSegue(withIdentifier: "logInToSpeaker", sender: self)
            }
        })
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        debugPrint("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    func createCurrentUser(completion: @escaping ((CurrentUser?) -> Void)) {
        // Create a new user
        spotifyController.getUsersEmail(completion: { email in
            if let email = email {
                let currentUser = CurrentUser(username: email)
                self.spotifyController.getUsersPicture(completion: { image in
                    if let image = image {
                        currentUser.profilePicture = image
                        self.spotifyController.getUsersName(completion: { name in
                            if let name = name {
                                currentUser.name = name
                                completion(currentUser)
                            } else {
                                completion(nil)
                            }
                        })
                    } else {
                        completion(nil)
                    }
                })
            } else {
                completion(nil)
            }
        })
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
