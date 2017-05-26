//
//  PermissonUtility.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/25/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PermissonUtility {
    
    
    
    
    static func isCameraAuthorized(completion: @escaping (Bool) -> Void) {
        
        if !Platform.isSimulator {
            let cameraMediaType = AVMediaTypeVideo
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
            
            switch cameraAuthorizationStatus {
            case .authorized: completion(true)
            case .notDetermined, .denied, .restricted:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (success) in
                    completion(success)
                })
            }
        }else {
            completion(true)
        }
    }
    

}
