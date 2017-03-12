//
//  ContactCell.swift
//  QNect
//
//  Created by Julian on 11/6/2016
//  Copyright (c) 2016 QNect. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet var addButton: UIButton!
    
    
  
    
    @IBOutlet weak var coloredView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

      nameLabel.adjustsFontSizeToFitWidth = true
      phoneLabel.adjustsFontSizeToFitWidth = true
      emailLabel.adjustsFontSizeToFitWidth = true
    }


  
}
