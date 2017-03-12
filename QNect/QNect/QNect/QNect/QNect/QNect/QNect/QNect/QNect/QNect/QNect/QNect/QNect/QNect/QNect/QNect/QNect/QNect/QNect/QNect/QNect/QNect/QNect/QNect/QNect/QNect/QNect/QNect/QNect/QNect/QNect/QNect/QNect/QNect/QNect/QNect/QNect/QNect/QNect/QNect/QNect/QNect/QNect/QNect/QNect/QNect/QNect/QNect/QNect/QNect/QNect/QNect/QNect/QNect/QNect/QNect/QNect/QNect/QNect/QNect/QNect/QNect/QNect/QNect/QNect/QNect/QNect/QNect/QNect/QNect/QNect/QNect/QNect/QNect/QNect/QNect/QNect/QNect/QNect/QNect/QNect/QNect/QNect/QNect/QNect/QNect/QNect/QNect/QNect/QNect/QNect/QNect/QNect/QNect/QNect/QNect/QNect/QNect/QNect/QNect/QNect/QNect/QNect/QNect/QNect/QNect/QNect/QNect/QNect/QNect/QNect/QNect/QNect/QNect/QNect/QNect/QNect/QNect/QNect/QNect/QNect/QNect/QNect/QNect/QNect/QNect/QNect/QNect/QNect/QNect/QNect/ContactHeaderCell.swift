//
//  ContactHeaderCell.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import UIKit

class ContactHeaderCell: UITableViewCell {
    
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerCellSpinner: UIActivityIndicatorView! {
        didSet{
            headerCellSpinner.isHidden = true
            headerCellSpinner.hidesWhenStopped = true
        }
    }
}
