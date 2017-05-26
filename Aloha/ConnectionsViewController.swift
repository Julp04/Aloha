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

class ConnectionsViewController: UITableViewController {

    
    //MARK: Constants
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    
    //MARK: Properties
    
    var following = ConnectionsModel(connections: [User]())
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
        
        navigationController?.navigationBar.topItem?.titleView = searchController.searchBar
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = .clear
        tableView.sectionIndexColor = .white
        tableView.sectionIndexBackgroundColor = .clear
        
    
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
        
        self.navigationController?.navigationBar.barTintColor = .main
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Disable transition manager so we cannot transition to code view controllwer when we hold on buttons and swipe
        //bug i was having (this might be temp fix ?? 😜
        guard let mainController = self.parent?.parent?.parent as? MainController else {
            return
        }
        
        mainController.transitionManager.isEnabled = false
        
        QnClient.sharedInstance.getFollowing { (users) in
            self.following = ConnectionsModel(connections: users)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Enable the transition manager when we leave this view controler
        guard let mainController = self.parent?.parent?.parent as? MainController else {
            return
        }
        mainController.transitionManager.isEnabled = true
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
