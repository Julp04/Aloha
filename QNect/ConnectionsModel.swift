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

class ConnectionsModel
{
    fileprivate var connections = [User]()
    var dictionary = [String: [User]]()
    var allKeys = [String]()
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
        if allKeys.count == 0 {
            return nil
        }else {
            return allKeys[section]
        }
    }
    
    func connectionAtIndexPath(_ indexPath:IndexPath) -> User
    {
        let letter = allKeys[indexPath.section]
        let connections = dictionary[letter]!
        return connections[indexPath.row]
    }
    
    func indexTitle() -> [String]?
    {
        if allKeys.count == 0 {
            return nil
        }else {
            return allKeys
        }
    }
    
    func imageForConnectionAt(indexPath:IndexPath) -> UIImage? {
        
        let letter = allKeys[indexPath.section]
        let connections = dictionary[letter]
        let connection = connections?[indexPath.row]
        let profileImage = connection?.profileImage
        
        return profileImage
        
        
    }
}





extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}
