//
//  FollowRequestCell.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/24/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import JPLoadingButton

class FollowRequestCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var acceptButton: JPLoadingButton!
    @IBOutlet weak var declineButton: JPLoadingButton!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var statusButton: JPLoadingButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
