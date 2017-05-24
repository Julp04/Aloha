//
//  ViewController.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/22/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class FollowersViewController: UITableViewController {
    
    //MARK: Constants
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    
    //MARK: Properties
    
    var followers = ConnectionsModel(connections: [User]())
    var selectedConnection: User?
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: Outlets
    
    //MARK: Actions
    
    //MARK: Lifecycle
    
    
    //MARK: Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.lightGray
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
        
        
        navigationController?.navigationBar.topItem?.titleView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        QnClient.sharedInstance.getFollowers { (users) in
            self.followers = ConnectionsModel(connections: users)
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        searchController.searchBar.isHidden = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if followers.numberOfFilteredConnectionSections() == 0 {
                return 0
            }else {
                self.tableView.backgroundView = nil
                return followers.numberOfFilteredConnectionSections()
                
            }
        }
        
        if followers.numberOfConnectionSections() == 0 {
            let empytImage = #imageLiteral(resourceName: "tiki_guy")
            let emptyView = EmptyView(frame: self.view.frame, image: empytImage, titleText: "No Followers", descriptionText: "When you follow a new connection you will see them here")
            
            self.tableView.backgroundView = emptyView
            self.searchController.searchBar.isHidden = true
            
            return 0
        }else {
            
            self.tableView.backgroundView = nil
            return followers.numberOfConnectionSections()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return followers.numberOfFilteredConnectionsInSection(section)
        }else {
            return followers.numberOfConnectionsInSection(section)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
        cell.backgroundColor = .clear
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = followers.filteredConnectionAt(indexPath)
        }else {
            connection = followers.connectionAtIndexPath(indexPath)
        }
        
        
        if let connection = connection  {
            let firstName = connection.firstName!
            let lastName = connection.lastName!
            
            cell.nameLabel.text = firstName + " " + lastName
            cell.otherLabel.text = connection.username
            
            
            if let profileImage = connection.profileImage {
                cell.profileImageView.image = profileImage
                connection.profileImage = profileImage
            }else {
                cell.profileImageView.image = ProfileImageCreator.create(connection.firstName, last: connection.lastName)
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return followers.filteredTitleForSection(section)
        }else {
            return followers.titleForSection(section)
        }
        
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return followers.filtedIndexTitle()
        }else {
            return followers.indexTitle()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = followers.filteredConnectionAt(indexPath)
        }else {
            connection = followers.connectionAtIndexPath(indexPath)
        }
        
        
        if let connection = connection{
            
            let profileNavController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewControllerOtherUserNav") as! UINavigationController
            let profileViewController = profileNavController.viewControllers.first as! ProfileViewControllerOtherUser
            profileViewController.configureViewController(user: connection)
            present(profileNavController, animated: true, completion: nil)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc(positionForBar:) func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
}

extension FollowersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
}

extension FollowersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let seachBar = searchController.searchBar
        followers.filterContentsForSearch(text: seachBar.text!)
        tableView.reloadData()
    }
    
    
}


extension FollowersViewController: ImageDownloaderDelegate {
    
    func imageDownloaded(image: UIImage?) {
        self.tableView.reloadData()
    }
    
}

extension FollowersViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let point = gestureRecognizer.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return false
        }
        
        let connection = followers.connectionAtIndexPath(indexPath)
        print(connection ?? "no connection")
        
        return true
    }
    
}
