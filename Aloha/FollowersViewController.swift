//
//  ViewController.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/22/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

enum ConnectionType {
    case followers
    case following
    case none
}

class FollowersViewController: UITableViewController {
    
    //MARK: Constants
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    
    //MARK: Properties
    
    var connections = ConnectionsModel(connections: [User]())
    var selectedConnection: User?
    let searchController = UISearchController(searchResultsController: nil)
    var type: ConnectionType = .none
    
    var emptyText = ""
    
    //MARK: Outlets
    
    //MARK: Actions
    
    //MARK: Lifecycle
    
    func configureViewController(type: ConnectionType) {
        self.type = type
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        
        
//        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = #colorLiteral(red: 0.02568417229, green: 0.4915728569, blue: 0.614921093, alpha: 1)
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        tableView.tableHeaderView = searchController.searchBar
        
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        switch self.type {
        case .followers:
            emptyText = "No followers"
            QnClient.sharedInstance.getFollowers(completion: { (users) in
                DispatchQueue.main.async {
                    self.connections = ConnectionsModel(connections: users)
                    self.tableView.reloadData()
                }
            })
        case .following:
            emptyText = "You are not following anyone"
            QnClient.sharedInstance.getFollowing(completion: { (users) in
                DispatchQueue.main.async {
                    self.connections = ConnectionsModel(connections: users)
                    self.tableView.reloadData()
                }
            })
        default:
            break
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        searchController.searchBar.isHidden = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if connections.numberOfFilteredConnectionSections() == 0 {
                return 0
            }else {
                self.tableView.backgroundView = nil
                return connections.numberOfFilteredConnectionSections()
                
            }
        }
        
        if connections.numberOfConnectionSections() == 0 {
            let emptyView = EmptyView(frame: self.view.frame, image: nil, titleText: emptyText, descriptionText: "😢")
            self.tableView.backgroundView = emptyView
            
            self.searchController.searchBar.isHidden = true
            
            return 0
        }else {
            
            self.tableView.backgroundView = nil
            return connections.numberOfConnectionSections()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return connections.numberOfFilteredConnectionsInSection(section)
        }else {
            return connections.numberOfConnectionsInSection(section)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
        cell.backgroundColor = .clear
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = connections.filteredConnectionAt(indexPath)
        }else {
            connection = connections.connectionAtIndexPath(indexPath)
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
            return connections.filteredTitleForSection(section)
        }else {
            return connections.titleForSection(section)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.backgroundColor = .white
    }
    
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return connections.filtedIndexTitle()
        }else {
            return connections.indexTitle()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var connection: User?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            connection = connections.filteredConnectionAt(indexPath)
        }else {
            connection = connections.connectionAtIndexPath(indexPath)
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
        connections.filterContentsForSearch(text: seachBar.text!)
        tableView.reloadData()
    }
    
    
}



extension FollowersViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let point = gestureRecognizer.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return false
        }
        
        let connection = connections.connectionAtIndexPath(indexPath)
        print(connection ?? "no connection")
        
        return true
    }
    
}
