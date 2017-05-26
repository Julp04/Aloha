//
//  FollowRequestsViewController.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/24/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class FollowRequestsViewController: UITableViewController {
    
    //MARK: Constants
    
    //MARK: Properties
    
    var followRequests: [User]!
    
    //MARK: Outlets
    
    //MARK: Actions
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.allowsSelection = false
        tableView.backgroundColor = #colorLiteral(red: 0.02568417229, green: 0.4915728569, blue: 0.614921093, alpha: 1)
        
        navigationController?.navigationItem.title = "Follower Requests"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    
    func configureViewController(requests: [User]) {
        self.followRequests = requests
    }

   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestCell") as! FollowRequestCell
        
        let user = followRequests[indexPath.row]
        let name = user.fullName()
        let username = user.username
        
        cell.nameLabel.text = name
        cell.usernameLabel.text = username
        
        cell.acceptButton.tag = indexPath.row
        cell.declineButton.tag = indexPath.row
        cell.statusButton.tag = indexPath.row
        
        cell.profileImageView.image = user.profileImage
        
        cell.acceptButton.addTarget(self, action: #selector(FollowRequestsViewController.acceptRequest(sender:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(FollowRequestsViewController.declineRequest(sender:)), for: .touchUpInside)
        
        cell.statusButton.isHidden = true
     
        
        
       
        
        return cell
    }
    
    
    func updateStatusButton(sender: UIButton) {
        let index = sender.tag
        let user = followRequests[index]
        
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! FollowRequestCell
        
        //This might have to be observed only once
        QnClient.sharedInstance.getFollowStatusOnce(user: user) { (status) in
            cell.statusButton.removeTarget(nil, action: nil, for: .allEvents)
            switch status {
            case .accepted:
                cell.statusButton.isHidden = false
                cell.statusButton.setTitle("Following", for: .normal)
                cell.statusButton.backgroundColor = UIColor.qnBlue
                cell.statusButton.setTitleColor(.white, for: .normal)
                cell.statusButton.addTarget(self, action: #selector(FollowRequestsViewController.showUnfollowAlert(sender:)), for: .touchUpInside)
            case .notFollowing:
                cell.statusButton.isHidden = false
                cell.statusButton.setTitle("Follow", for: .normal)
                cell.statusButton.backgroundColor = UIColor.white
                cell.statusButton.setTitleColor(.qnBlue, for: .normal)
                cell.statusButton.addTarget(self, action: #selector(FollowRequestsViewController.followUser(sender:)), for: .touchUpInside)
            case .pending:
                cell.statusButton.isHidden = false
                cell.statusButton.setTitle("Pending", for: .normal)
                cell.statusButton.backgroundColor = UIColor.qnBlue
                cell.statusButton.setTitleColor(.white, for: .normal)
                cell.statusButton.addTarget(self, action: #selector(FollowRequestsViewController.showCancelRequestAlert(sender:)), for: .touchUpInside)
                
            default:
                cell.statusButton.isHidden = true
                cell.acceptButton.isHidden = true
                cell.declineButton.isHidden = true
            }
        }
    }
    
    func acceptRequest(sender: UIButton) {
      
        let index = sender.tag
        let user = followRequests[index]
        QnClient.sharedInstance.acceptFollowRequest(user: user) {
         self.updateStatusButton(sender: sender)
        }
    }
    
    func declineRequest(sender: UIButton) {
        let index = sender.tag
        let user = followRequests[index]
        QnClient.sharedInstance.denyFollowRequest(user: user) {
            updateStatusButton(sender: sender)
        }
    }
    
    func followUser(sender: UIButton) {
        let index = sender.tag
        
        let user = followRequests[index]
        
        QnClient.sharedInstance.getUpdatedInfoForUserOnce(user: user) { (user) in
            QnClient.sharedInstance.follow(user: user) { (error) in
                if error != nil {
                    print(error!)
                }
                
                self.updateStatusButton(sender: sender)
              
            }
        }
    }
    
    func showUnfollowAlert(sender: UIButton) {
        let index = sender.tag
        let user = followRequests[index]
        
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { (action) in
            QnClient.sharedInstance.unfollow(user: user) { error in
                self.updateStatusButton(sender: sender)
            }
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(unfollowAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showCancelRequestAlert(sender: UIButton) {
        let index = sender.tag
        let user = followRequests[index]
        
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        let cancelRequestAction = UIAlertAction(title: "Cancel follow request", style: .destructive) { (action) in
            QnClient.sharedInstance.cancelFollow(user: user) { error in
                self.updateStatusButton(sender: sender)
            }
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(cancelRequestAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
  

}
