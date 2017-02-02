//
//  ContactManager.swift
//  QNect
//
//  Created by Julian on 11/11/2016
//  Copyright (c) 2016 QNect. All rights reserved.
//

import UIKit
import Foundation
import AddressBook


class ContactManager
{
    var addressBookRef: ABAddressBook?
    
    init()
    {
        if addressBookStatus() == .denied {
            promptForAddressBookRequestAccess()
        } else {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
    }
    
    func promptForAddressBookRequestAccess() {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, { (success, error) -> Void in
        })
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    func addContact(_ contact: User, image:UIImage?) {
        
        let contactRecord: ABRecord = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, contact.firstName as CFTypeRef!, nil)
        ABRecordSetValue(contactRecord, kABPersonLastNameProperty, contact.lastName as CFTypeRef!, nil)
        
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 0.5)!
            let data = CFDataCreate(nil, (imageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: imageData.count), imageData.count)
            ABPersonSetImageData(contactRecord, data, nil)
            
        }
        
        ABRecordSetValue(contactRecord, kABPersonNoteProperty, "Added from QNect" as CFTypeRef!, nil)
        
        
        let phoneNumbers: ABMutableMultiValue =
        ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(phoneNumbers, contact.socialPhone as CFTypeRef!, kABPersonPhoneMobileLabel, nil)
        ABRecordSetValue(contactRecord, kABPersonPhoneProperty, phoneNumbers, nil)
        
        
        let email: ABMutableMultiValue =
            ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
         ABMultiValueAddValueAndLabel(email, contact.socialEmail! as CFTypeRef!, kABOtherLabel, nil)
        ABRecordSetValue(contactRecord, kABPersonEmailProperty, email, nil)
        
        ABAddressBookAddRecord(addressBookRef, contactRecord, nil)
        saveAddressBookChanges()
        
    }
    
    
    fileprivate func saveAddressBookChanges() {
        if ABAddressBookHasUnsavedChanges(addressBookRef){
            var err: Unmanaged<CFError>? = nil
            let savedToAddressBook = ABAddressBookSave(addressBookRef, &err)
            if savedToAddressBook {
                print("Successully saved changes.")
            } else {
                print("Couldn't save changes.")
            }
        } else {
            print("No changes occurred.")
        }
    }
    
    func addressBookStatus() -> ABAuthorizationStatus
    {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        }
    }
    
}
