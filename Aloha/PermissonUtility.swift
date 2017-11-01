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
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
            switch cameraAuthorizationStatus {
            case .authorized: completion(true)
            case .notDetermined, .denied, .restricted:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (success) in
                    completion(success)
                })
            }
        }else {
            completion(true)
        }
    }
    

}
