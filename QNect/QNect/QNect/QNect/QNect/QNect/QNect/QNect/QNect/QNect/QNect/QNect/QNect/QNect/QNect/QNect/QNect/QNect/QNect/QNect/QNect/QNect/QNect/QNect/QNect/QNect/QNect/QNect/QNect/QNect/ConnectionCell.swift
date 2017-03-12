//
//  ConnectionCell.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.frame.size = CGSize(width: 55.5, height: 55.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
