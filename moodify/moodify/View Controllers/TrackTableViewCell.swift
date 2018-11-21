//
//  PlaylistTableViewCell.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackArtist: UILabel!
    var track: Track?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let track = self.track {
            self.trackTitle.text = track.name
            self.trackArtist.text = track.artist
            Alamofire.request(track.coverUrl).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    self.trackImage.image = image
                }
            })
        }
    }
}
