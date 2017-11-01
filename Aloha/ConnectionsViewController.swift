//
//  ConnectionsViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/13/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import ReachabilitySwift
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import RKDropdownAlert
import EasyTipView

class ConnectionsViewController: UITableViewController {

    
    //MARK: Constants
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    
    //MARK: Properties
    
    var following = ConnectionsModel(connections: [User]())
    var selectedConnection: User?
    let searchController = UISearchController(searchResultsController: nil)
    var noConnectionsTip: EasyTipView!
    
    //MARK: Outlets
    
    //MARK: Actions
    
    //MARK: Lifecycle
    

    //MARK: Lifecycle

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QnClient.sharedInstance.getFollowing { (users) in
            DispatchQueue.main.async {
                self.following = ConnectionsModel(connections: users)
                self.tableView.reloadData()
            }
        }
 
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = .clear
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        
        self.navigationController?.navigationBar.barTintColor = .main
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        navigationItem.titleView = searchController.searchBar
        
        self.extendedLayoutIncludesOpaqueBars = true
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        searchController.searchBar.isHidden = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if following.numberOfFilteredConnectionSections() == 0 {
                return 0
            }else {
                self.tableView.backgroundView = nil
                return following.numberOfFilteredConnectionSections()
            }
        }
        
        if following.numberOfConnectionSections() == 0 {
            let emptyView = EmptyView(frame: self.view.frame, image: nil, titleText: "No Connections", descriptionText: "When you follow a new connection you will see them here")
            
            self.tableView.backgroundView = emptyView
            self.searchController.searchBar.isHidden = true
            
            return 0
        }else {
            
            self.tableView.backgroundView = nil
            return following.numberOfConnectionSections()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return following.numberOfFilteredConnectionsInSection(section)
        }else {
            return following.numberOfConnectionsInSection(section)
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
        cell.backgroundColor = .clear
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = following.filteredConnectionAt(indexPath)
        }else {
            connection = following.connectionAtIndexPath(indexPath)
        }
        
        
        if let connection = connection  {
            let firstName = connection.firstName!
            let lastName = connection.lastName!
            
            cell.nameLabel.text = firstName + " " + lastName
            cell.otherLabel.text = connection.username
            
            cell.profileImageView.image = ProfileImageCreator.create(firstName, last: lastName)
            
            if let profileImage = connection.profileImage {
                cell.profileImageView.image = profileImage
                connection.profileImage = profileImage
            }else {
                QnClient.sharedInstance.getProfileImageForUser(user: connection, began: { 
                    
                }, completion: { (result) in
                    switch result {
                    case .success(let image):
                        cell.profileImageView.image = image
                        connection.profileImage = image
                    default:
                        break
                    }
                })
            }
        }
    
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return following.filteredTitleForSection(section)
        }else {
            return following.titleForSection(section)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return following.filtedIndexTitle()
        }else {
            return following.indexTitle()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = following.filteredConnectionAt(indexPath)
        }else {
            connection = following.connectionAtIndexPath(indexPath)
        }


        if let connection = connection{
            let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewControllerOtherUser") as! ProfileViewControllerOtherUser
            profileViewController.configureViewController(user: connection)
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }

        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc(positionForBar:) func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
}

extension ConnectionsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
}

extension ConnectionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let seachBar = searchController.searchBar
        following.filterContentsForSearch(text: seachBar.text!)
        tableView.reloadData()
    }
    
    
}

extension ConnectionsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let point = gestureRecognizer.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return false
        }
        
        let connection = following.connectionAtIndexPath(indexPath)
        print(connection ?? "no connection")
        
        return true
    }
    
}
