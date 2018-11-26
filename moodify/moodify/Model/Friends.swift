//
//  Friends.swift
//  moodify
//
//  Created by Stephen Boyle on 11/25/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import Foundation



class Friends {
    var image: UIImage!
    var name: String!
    
    init(image: UIImage, name: String) {
        self.image = image
        self.name = name
    }
}

var friends: [Friends] = [Friends(image: UIImage(named: "barry")!, name: "Barrak"), Friends(image: UIImage(named: "bey")!, name: "Beyonce"), Friends(image: UIImage(named: "boo")!, name: "Honey Boo Boo"), Friends(image: UIImage(named: "ellen")!, name: "Ellen"), Friends(image: UIImage(named: "hillary")!, name: "Hillary"), Friends(image: UIImage(named: "kim")!, name: "Kim"), Friends(image: UIImage(named: "phil")!, name: "Phil")]
