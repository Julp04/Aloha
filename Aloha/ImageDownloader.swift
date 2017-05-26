//
//  ImageDownloader.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/26/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    
    static func downloadImage(url: String, completion: @escaping (Result<UIImage?>) -> Void) {
        
        let downloadURL = URL(string: url)
        guard let imageURL = downloadURL else {
            completion(.failure(Oops.customError("Url does not exist")))
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) {
            (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            }else {
                let image = UIImage(data: data!)
                completion(.success(image))
            }
            }.resume()
    }
}
