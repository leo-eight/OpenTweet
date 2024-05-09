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
    
    /// Label that displays the content of the tweet.
    let tweetContentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubview(tweetContentLabel)
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
            
            tweetContentLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            tweetContentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tweetContentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tweetContentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with data from a tweet.
    ///
    /// - Parameter tweet: The `Tweet` object containing the data to display.
    func configure(with tweet: Tweet) {
        usernameLabel.text = tweet.author
        tweetContentLabel.text = tweet.content
        timestampLabel.text = DateUtility.formatDate(from: tweet.date)
        // Handle image loading
        if let urlString = tweet.avatar, let url = URL(string: urlString) {
            currentAvatarURL = url // Store the current URL for comparison
            ImageCacheManager.getImage(for: url) { [weak self, currentLoadedURL = url] image in
                DispatchQueue.main.async {
                    // Check if the loaded URL matches the current URL to avoid displaying wrong images
                    if self?.currentAvatarURL == currentLoadedURL {
                        self?.avatarImageView.image = image ?? InitialsImageUtility.generateInitialsImage(for: tweet.author, size: CGSize(width: 40, height: 40))
                    }
                }
            }
        } else {
            // Use initials if no image URL is available
            avatarImageView.image = InitialsImageUtility.generateInitialsImage(for: tweet.author, size: CGSize(width: 40, height: 40))
        }
    }
}
