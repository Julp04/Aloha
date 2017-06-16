//
//  ContactManager.swift
//  QNect
//
//  Created by Julian on 11/11/2016
//  Copyright (c) 2016 Aloha. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import Contacts


class ContactManager
{
    var store = CNContactStore()
    
    func requestAccessToContacts(completion:@escaping ((_ accessGranted: Bool) -> Void))
    {
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            completion(true)
        default:
            store.requestAccess(for: .contacts){succeeded, error in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            }
        }
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    func addContact(_ connection: User, image: UIImage?, completion:(Bool) -> Void)
    {
        let contact = CNMutableContact()
        contact.givenName = connection.firstName
        contact.familyName = connection.lastName
        
        
        //Phone numbers
        if let phoneNumber = connection.phone {
            let homePhone = CNLabeledValue(label: CNLabelHome,value: CNPhoneNumber(stringValue: phoneNumber))
            contact.phoneNumbers = [homePhone]
        }
        
        
        //Email
        if let email = connection.personalEmail {
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: email as NSString)
            contact.emailAddresses = [homeEmail]
        }
        
        //Social Accounts
        if let twitterScreenName = connection.twitterAccount?.screenName {
            let twitterProfile = CNLabeledValue(label: "Twitter", value:
                CNSocialProfile(urlString: nil, username: twitterScreenName,
                                userIdentifier: nil, service: CNSocialProfileServiceTwitter))
            contact.socialProfiles = [twitterProfile]
        }
        
        //Image
        if let image = image {
            let data = UIImagePNGRepresentation(image)
            contact.imageData = data
        }
        
        //Set Birthday
        if let connectionBirthDay = connection.birthdate?.asDate() {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: connectionBirthDay)
            let month = calendar.component(.month, from: connectionBirthDay)
            let day = calendar.component(.day, from: connectionBirthDay)
            
            var birthday = DateComponents()
            birthday.year = year
            birthday.month = month
            birthday.day = day
            
            contact.birthday = birthday
        }
        
        //Set QNect username
        contact.note = "Added through Aloha"
        
        //Save Contact
        let request = CNSaveRequest()
        request.add(contact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            completion(true)
        } catch {
            completion(false)
        }

    }
    
    func contactExists(user: User) -> Bool {
        var contactExists = false
        let lastName = user.lastName
        let predicate = CNContact.predicateForContacts(matchingName: lastName!)
        
        let fetchResults = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactNoteKey]
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: fetchResults as [CNKeyDescriptor])
            for contact in contacts {
                if contact.note == "Added through Aloha" {
                    contactExists = true
                }
            }
        }catch let error {
            print(error)
        }
        
        return contactExists
    }
    
    
    static func contactsAutorized() -> Bool {
        switch contactStoreStatus() {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    
 
    
    static func contactStoreStatus() -> CNAuthorizationStatus
    {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        }
    }
    
}
