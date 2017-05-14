//
//  SavedConnectionsModel.swift
//  QNect
//
//  Created by Julian Panucci on 11/13/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

class ConnectionsModel
{
    fileprivate var connections = [User]()
    fileprivate var filteredConnections = [User]()
    
    var dictionary = [String: [User]]()
    var filteredDictionary = [String: [User]]()
    
    var allKeys = [String]()
    var filteredKeys = [String]()
    
    var profileImages = [UIImage]()
   
    
    init(connections:[User])
    {
        self.connections = connections
        for connection in connections {
            
            let firstLetter = connection.lastName.firstLetter()
            if dictionary[firstLetter!]?.append(connection)  == nil {
                dictionary[firstLetter!] = [connection]
            }
        }
        allKeys = Array(dictionary.keys).sorted()
       
    }
    
    func numberOfConnections() ->Int
    {
        return self.connections.count
    }
    
    
    func numberOfConnectionSections() -> Int
    {
        return allKeys.count
    }
    
    func numberOfConnectionsInSection(_ section:Int) -> Int
    {
        let letter = allKeys[section]
        let connectionsWithLastNameOfLetter = dictionary[letter]!
        return connectionsWithLastNameOfLetter.count
    }
    
    func titleForSection(_ section:Int) -> String?
    {
        return allKeys.count == 0 ? nil : allKeys[section]
    }
    
    func connectionAtIndexPath(_ indexPath:IndexPath) -> User?
    {
        let letter = allKeys[indexPath.section]
        if let connections = dictionary[letter] {
            return connections[indexPath.row]
        }else {
            return nil
        }
        
    }
    
    func indexTitle() -> [String]?
    {
        return allKeys.count == 0 ? nil : allKeys
    }
    
    func imageForConnectionAt(indexPath:IndexPath) -> UIImage? {
        
        let letter = allKeys[indexPath.section]
        let connections = dictionary[letter]
        let connection = connections?[indexPath.row]
        let profileImage = connection?.profileImage
        
        return profileImage
    }
    
    //MARK: - Filtered Connections
    
    func filterContentsForSearch(text: String) {
        
        filteredKeys.removeAll()
        filteredDictionary.removeAll()
        filteredConnections.removeAll()

        filteredConnections = connections.filter({ (user) -> Bool in
            let name = user.firstName + " " + user.lastName
            return  name.lowercased().contains(text.lowercased())
        })
        
        for connection in filteredConnections {
            
            let firstLetter = connection.lastName.firstLetter()
            if filteredDictionary[firstLetter!]?.append(connection)  == nil {
                filteredDictionary[firstLetter!] = [connection]
            }
        }
        filteredKeys = Array(filteredDictionary.keys).sorted()
        
       
    }
    
    func numberOfFilteredConnections() -> Int {
        return filteredConnections.count
    }
    
    func numberOfFilteredConnectionSections() -> Int {
        return filteredKeys.count
    }
    
    func numberOfFilteredConnectionsInSection(_ section: Int) -> Int {
        let letter = filteredKeys[section]
        let connectionsWithLastNameOfLetter = filteredDictionary[letter]!
        return connectionsWithLastNameOfLetter.count
    }
    
    func filtedIndexTitle() -> [String]? {
        return filteredKeys.count == 0 ? nil : filteredKeys
    }
    
    func filteredTitleForSection(_ section: Int) -> String? {
        return filteredKeys.count == 0 ? nil : filteredKeys[section]
    }
    
    func filteredConnectionAt(_ indexPath: IndexPath) -> User? {
        let letter = filteredKeys[indexPath.section]
        if let user = filteredDictionary[letter] {
            return user[indexPath.row]
        }else {
            return nil
        }
    }
}





extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}
