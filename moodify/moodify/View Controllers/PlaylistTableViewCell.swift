//
//  PlaylistTableViewCell.swift
//  moodify
//
//  Created by Pawel Sendyk on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var numTracks: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
