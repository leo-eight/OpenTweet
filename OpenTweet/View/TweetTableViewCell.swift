//
//  TweetTableViewCell.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    // MARK: - Properties
    var currentAvatarURL: URL?

    /// Image view that displays the avatar of the tweet's author.
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Label that displays the username of the tweet's author.
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Textview that displays the content of the tweet.
    let tweetContentView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        // Automatically detect links
        textView.dataDetectorTypes = [.link]
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    /// Label that displays the timestamp of when the tweet was posted.
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    
    /// Initializes the cell with the required style and reuse identifier.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil // Reset image to clear old data
        currentAvatarURL = nil  // Clear the current URL
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the views and constraints within the cell.
    private func setupViews() {
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(tweetContentView)
        addSubview(timestampLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            
            timestampLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            timestampLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
            
            tweetContentView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            tweetContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tweetContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tweetContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    private func handleImageLoadError(for author: String) {
        // Set a default placeholder image or generate initials
        self.avatarImageView.image = UIImage(named: "default_avatar") ?? InitialsImageUtility.generateInitialsImage(for: author, size: CGSize(width: 40, height: 40))

        // Optionally, log the error or inform the user with a toast, alert, etc.
        // This can be an alert or a simple label display saying "Image load failed"
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with data from a tweet.
    /// - Parameter tweet: The `Tweet` object containing the data to display.
    func configure(with tweet: Tweet) {
        usernameLabel.text = tweet.author
        timestampLabel.text = DateUtility.formatDate(from: tweet.date)

        // Base font and style for the entire text
        let contentFont = UIFont.systemFont(ofSize: 15)
        let attributedString = NSMutableAttributedString(string: tweet.content, attributes: [
            .font: contentFont
        ])

        // Regex for mentions
        do {
            let mentionRegex = try NSRegularExpression(pattern: "@[\\w]+", options: [])
            let mentions = mentionRegex.matches(in: tweet.content, options: [], range: NSRange(tweet.content.startIndex..., in: tweet.content))
            // Define attributes for mentions and links
            let specialAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.font: contentFont
            ]
            
            for match in mentions {
                attributedString.addAttributes(specialAttributes, range: match.range)
            }
        } catch {
            print("Error creating regular expression: \(error.localizedDescription)")
        }

        // NSDataDetector for URLs if not using UITextView's automatic detection
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let urls = detector.matches(in: tweet.content, options: [], range: NSRange(tweet.content.startIndex..., in: tweet.content))
            let linkAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.font: contentFont
            ]
            
            for match in urls {
                attributedString.addAttributes(linkAttributes, range: match.range)
            }
        } catch {
            print("Error initializing data detector: \(error.localizedDescription)")
        }

        tweetContentView.attributedText = attributedString
        
        // Handle image loading
        if let urlString = tweet.avatar, let url = URL(string: urlString) {
            currentAvatarURL = url // Store the current URL for comparison
            ImageCacheUtility.getImage(for: url) { [weak self, currentLoadedURL = url] image, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    // Check if the loaded URL matches the current URL to avoid displaying wrong images
                    if self.currentAvatarURL == currentLoadedURL {
                        if let image = image {
                            self.avatarImageView.image = image
                        } else if let error = error {
                            print("Failed to load image: \(error.localizedDescription)")
                            // Optionally, you can handle different types of errors differently
                            self.handleImageLoadError(for: tweet.author)
                        } else {
                            // No image and no error (unlikely case)
                            self.avatarImageView.image = InitialsImageUtility.generateInitialsImage(for: tweet.author, size: CGSize(width: 40, height: 40))
                        }
                    }
                }
            }
        } else {
            // Use initials if no image URL is available
            avatarImageView.image = InitialsImageUtility.generateInitialsImage(for: tweet.author, size: CGSize(width: 40, height: 40))
        }
    }
}
