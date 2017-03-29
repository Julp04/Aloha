//
//  ProfileViewContoller.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/29/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import JPLoadingButton

class ProfileViewContoller: UITableViewController {
    
    //MARK: Properties
    
   
    //MARK: Outlets
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followOrEditProfileButton: JPLoadingButton!
    @IBOutlet weak var contactActionContainerView: UIView!
    @IBOutlet weak var statsContainerView: UIView!
    
    @IBOutlet weak var profileCell: UITableViewCell!
    //MARK: Actions
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        //can change position of objects based on if they are available
        //(ex: user may not have added a location info, so we do not show that and move about label up)
        let yLocationLabel = contactActionContainerView.frame.origin.y
        
        statsContainerView.frame.origin = CGPoint(x: statsContainerView.frame.origin.x, y: yLocationLabel)
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            //todo: Calculate profileCell based on objects that are available to show
            return 500
        }
        
        return 50
    }


}

