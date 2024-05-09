//
//  InitialsImageView.swift
//  OpenTweet
//
//  Created by on 2024-05-09.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class InitialsImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }
    
    func configure(withName name: String, backgroundColor: UIColor = .lightGray, textColor: UIColor = .white, fontSize: CGFloat = 20) {
        self.image = generateInitialsImage(for: name, backgroundColor: backgroundColor, textColor: textColor, fontSize: fontSize)
    }
    
    private func generateInitialsImage(for name: String, backgroundColor: UIColor, textColor: UIColor, fontSize: CGFloat) -> UIImage? {
        let initials = getInitials(from: name)
        let frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40)) // Adjust size as necessary
        
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        return renderer.image { context in
            // Fill background
            backgroundColor.setFill()
            context.fill(frame)
            
            // Prepare text attributes
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: textColor
            ]
            
            // Calculate text size
            let attributedText = NSAttributedString(string: initials, attributes: attributes)
            let textSize = attributedText.size()
            
            // Calculate text rect
            let textRect = CGRect(x: (frame.width - textSize.width) / 2.0,
                                  y: (frame.height - textSize.height) / 2.0,
                                  width: textSize.width,
                                  height: textSize.height)
            
            // Draw text in the center
            attributedText.draw(in: textRect)
        }
    }
    
    // Get initials from a name, skipping '@' if present as the first character
    private func getInitials(from name: String) -> String {
        let adjustedName = name.starts(with: "@") ? String(name.dropFirst()) : name
        return adjustedName.components(separatedBy: " ")
            .reduce("") { (result, word) in
                guard let firstLetter = word.first else { return result }
                return result + String(firstLetter).uppercased()
            }
    }
}
