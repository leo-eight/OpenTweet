//
//  ImageCacheManager.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class ImageCacheManager {
    
    static let cache = NSCache<NSString, UIImage>()

    static func getImage(for url: URL, completion: @escaping (UIImage?) -> Void) {

        let key = NSString(string: url.absoluteString)

        if let cachedImage = cache.object(forKey: key) {
            completion(cachedImage)
        } else {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: key)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
