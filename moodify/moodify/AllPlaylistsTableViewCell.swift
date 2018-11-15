//
//  AllPlaylistsTableViewCell.swift
//  moodify
//
//  Created by Grace Hunter on 11/14/18.
//  Copyright © 2018 Pawel Sendyk. All rights reserved.
//

import UIKit

class AllPlaylistsTableViewCell: UITableViewCell {

    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var numSongs: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
