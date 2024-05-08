//
//  InitialsAvatarImageUtility.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class InitialsImageUtility {
    static func generateInitialsImage(for name: String, size: CGSize, backgroundColor: UIColor = .lightGray, textColor: UIColor = .white) -> UIImage? {
        let frame = CGRect(origin: .zero, size: size)
        return image(from: getInitials(from: name), frame: frame, backgroundColor: backgroundColor, textColor: textColor)
    }
    
    private static func getInitials(from name: String) -> String {
        // Removing '@' from the start of the username if present
        let cleanName = name.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        let words = cleanName.split(separator: " ")
        let initials = words.reduce("") { $0 + String($1.first ?? Character("")) }
        return initials.uppercased()
    }
    
    private static func image(from initials: String, frame: CGRect, backgroundColor: UIColor, textColor: UIColor) -> UIImage? {
        let label = UILabel(frame: frame)
        label.backgroundColor = backgroundColor
        label.textColor = textColor
        label.font = UIFont.boldSystemFont(ofSize: frame.width / 2)
        label.textAlignment = .center
        label.text = initials
        
        UIGraphicsBeginImageContext(frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
