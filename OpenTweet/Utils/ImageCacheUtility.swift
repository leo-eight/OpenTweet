//
//  ImageCacheManager.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class ImageCacheUtility {

    private static let cache = NSCache<NSString, UIImage>()

    static func getImage(for url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        let key = NSString(string: url.absoluteString)

        if let cachedImage = cache.object(forKey: key) {
            DispatchQueue.main.async {
                completion(cachedImage, nil)
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    cache.setObject(image, forKey: key)
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "ImageCacheUtilityError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image data"]))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
