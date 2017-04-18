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

class ConnectionsViewController: UITableViewController, UIGestureRecognizerDelegate, ImageDownloaderDelegate {

    
    var following:ConnectionsModel?
    var followers:ConnectionsModel?
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    var selectedConnection:User?
    
    var  segmentControl = UISegmentedControl(items: ["Following", "Followers"])
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear
    
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        fetchFromDatabase()
    }
    
    func fetchFromDatabase()
    {
         let currentUser = FIRAuth.auth()!.currentUser!
        
        databaseRef.child("following").child(currentUser.uid).observe(.value, with: { (snapshot) in
            var following = [User]()
            
            self.following = ConnectionsModel(connections: following)
            self.tableView.reloadData()
            
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                self.databaseRef.child("users").child(item.key).observe(.value, with: { (userSnapshot) in
                    
                    let uid = userSnapshot.key
                    let user = User(snapshot: userSnapshot)
                    
                    following = following.filter(){$0.uid != uid}
                    
                    following.append(user)
                    self.following = ConnectionsModel(connections: following)
                    self.tableView.reloadData()
                    
                })
                
            }
            
            
            
        })
        
        
        databaseRef.child("followers").child(currentUser.uid).observe(.value, with: { (snapshot) in
            var followers = [User]()
            
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                self.databaseRef.child("users").child(item.key).observe(.value, with: { (userSnapshot) in
                    
                    
                    let uid = userSnapshot.key
                    let user = User(snapshot: userSnapshot)
                    
                    followers = followers.filter() {$0.uid != uid}
                    followers.append(user)
                    self.followers = ConnectionsModel(connections: followers)
                    self.tableView.reloadData()
                })
                
            }
        })
    }

    func createTitleView()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 55))
        
        segmentControl.frame = CGRect(x: 0, y: 24, width: 200, height: 23)
        segmentControl.tintColor = UIColor.white
        segmentControl.addTarget(self, action: #selector(ConnectionsViewController.segmentControlSwitched(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        
        
        
        let label = UILabel(frame: CGRect(x: 66, y: 5, width: 100, height: 15))
        label.textColor = UIColor.white
        label.text = "QNections"
        
        
        
        view.addSubview(label)
        view.addSubview(segmentControl)
        self.navigationItem.titleView = view
    }
    
    func segmentControlSwitched(_ sender:UISegmentedControl)
    {
       self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
   
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
//        if segmentControl.selectedSegmentIndex == 0 {
//        
//            if following == nil || following?.numberOfConnections() == 0{
//              
//                
//                return 0
//            }else {
//                return following!.numberOfConnectionSections()
//            }
//        }else {
//            if followers == nil || followers?.numberOfConnections() == 0 {
//                return 1
//            }else {
//                return followers!.numberOfConnectionSections()
//            }
//        }
        
        
        let emptyView = EmptyView(frame: self.view.frame, image: #imageLiteral(resourceName: "connections_icon"), titleText: "No Connections", descriptionText: "When you follow a new connection you will see them here")
      
        self.tableView.backgroundView = emptyView
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if following == nil || following?.numberOfConnections() == 0{
                return 1
            }else {
                return following!.numberOfConnectionsInSection(section)
            }
        }else {
            if followers == nil || followers?.numberOfConnections() == 0 {
                return 1
            }else {
                return (followers?.numberOfConnectionsInSection(section))!
            }
        }
    }
    
 

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if following == nil || following?.numberOfConnections() == 0{
                cell.nameLabel.text = "No connections to display"
                cell.profileImageView.image = nil
            }else {
                
                let connection = following!.connectionAtIndexPath(indexPath)
                let firstName = connection.firstName
                let lastName = connection.lastName
                
                cell.nameLabel.text = firstName! + " " + lastName!
                
                
               let profileImage = following?.imageForConnectionAt(indexPath: indexPath)
                if profileImage != nil {
                    cell.profileImageView.image = profileImage
                }else {
                    cell.profileImageView.image = ProfileImageCreator.create(connection.firstName, last: connection.lastName)
                }
               
                
            }
        }else {
            if followers == nil || followers?.numberOfConnections() == 0{
                cell.nameLabel.text = "No connections to display"
                cell.profileImageView.image = nil
            }else {
                
                let connection = followers!.connectionAtIndexPath(indexPath)
                let firstName = connection.firstName
                let lastName = connection.lastName
                
                cell.nameLabel.text = firstName! + " " + lastName!
                
                
                
                let profileImage = followers?.imageForConnectionAt(indexPath: indexPath)
                
                if profileImage != nil {
                    cell.profileImageView.image = profileImage
                }else {
                    cell.profileImageView.image = ProfileImageCreator.create(connection.firstName, last: connection.lastName)
                }
                
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if segmentControl.selectedSegmentIndex == 0 {
            return following?.titleForSection(section)
        }else {
            return followers?.titleForSection(section)
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if segmentControl.selectedSegmentIndex == 0 {
            return following?.indexTitle()
        }else {
            return followers?.indexTitle()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! ConnectionCell
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width) / 2
        cell.profileImageView.layer.borderWidth = kProfileBorderWidth
        cell.profileImageView.layer.borderColor = UIColor.qnPurple.cgColor
        
        cell.profileImageView.clipsToBounds = true
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if following?.numberOfConnections() != 0 {
                selectedConnection = following?.connectionAtIndexPath(indexPath)
                
                self.performSegue(withIdentifier: "ContactSegue", sender: self)
            }
        }else {
            if followers?.numberOfConnections() != 0 {
                selectedConnection = followers?.connectionAtIndexPath(indexPath)
                self.performSegue(withIdentifier: "ContactSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let contactVC = navVC.topViewController as? ContactViewController {
                contactVC.configureViewController(selectedConnection!)
            }
        }
    }
    

    //MARK: - Gesture Delegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        
        
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        
        if segmentControl.selectedSegmentIndex == 0 && following?.numberOfConnections() != 0{
           
            
            if following != nil || following?.numberOfConnections() != 0 {
            
                let connection = following?.connectionAtIndexPath(indexPath!)
                let name = (connection?.firstName)! + " " + (connection?.lastName)!
                let message = QnEncoder(user: connection!).encodeSocialCode()
                let qrImage = QNectCode(message: message).image
                
                let qnectAlertView = QNectAlertView()
                
                qnectAlertView.addButton("Delete Connection") {

                    
                let currentUser = FIRAuth.auth()!.currentUser!
                    
                self.databaseRef.child("following").child(currentUser.uid).child(connection!.uid).removeValue()
                    
                RKDropdownAlert.title("You have deleted \(connection!.firstName!) \(connection!.lastName!) as a connection", backgroundColor: UIColor.gray, textColor: UIColor.white)
                    
                }
                
                qnectAlertView.showTitle(name, subTitle: "\(connection!.username!)", duration: 0.0, completeText: nil, style: .contact, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF, contactImage: qrImage)
                
            }
           
        }else {
           
        }
        
        return true
     
    }
    
    //MARK: - Toolbar Delegate
    
    func positionForBar(_ bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    func imageDownloaded(image: UIImage?) {
        self.tableView.reloadData()
    }
}
