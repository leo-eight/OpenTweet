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
    let avatarImageView = InitialsImageView()
    let usernameLabel = UILabel()
    let tweetContentView = UITextView()
    let timestampLabel = UILabel()

    /// Initialize subviews and apply initial configurations
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Prepare the cell for reuse and clear old data
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        currentAvatarURL = nil
        tweetContentView.text = nil
        usernameLabel.text = nil
        timestampLabel.text = nil
    }

    /// Configure cell views layout
    private func setupViews() {
        [avatarImageView, usernameLabel, tweetContentView, timestampLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        setupConstraints()
    }

    /// Set attributes for subviews
    private func configureSubviews() {
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        tweetContentView.isEditable = false
        tweetContentView.isSelectable = true
        tweetContentView.dataDetectorTypes = [.link]
        tweetContentView.isScrollEnabled = false
        tweetContentView.font = UIFont.systemFont(ofSize: 15)
        tweetContentView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        timestampLabel.font = UIFont.systemFont(ofSize: 14)
        timestampLabel.textColor = .gray
    }

    /// Define and activate layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),

            timestampLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            timestampLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),

            tweetContentView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            tweetContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tweetContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            tweetContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    /// Handle the formatting and setting of the tweet's date asynchronously
    private func configureDate(for tweet: Tweet) {
        DispatchQueue.global(qos: .userInitiated).async {
            let formattedDate = DateUtility.formatDate(from: tweet.date)
            DispatchQueue.main.async {
                self.timestampLabel.text = formattedDate
            }
        }
    }

    /// Load or configure the avatar image based on the tweet's avatar URL
    private func configureAvatar(for tweet: Tweet) {
        if let urlString = tweet.avatar, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            avatarImageView.configure(withName: tweet.author)
        }
    }

    /// Load the image from a URL and handle potential errors
    private func loadImage(from url: URL) {
        if url != currentAvatarURL {
            // Clear image if URL has changed
            avatarImageView.image = nil
        }
        ImageCacheUtility.getImage(for: url) { [weak self, currentLoadedURL = url] image, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.currentAvatarURL == currentLoadedURL {
                    if let image = image {
                        self.avatarImageView.image = image
                    } else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                        // If no image, configure with initials
                        self.avatarImageView.configure(withName: self.usernameLabel.text ?? "")
                    }
                }
            }
        }
        currentAvatarURL = url
    }
    
    /// Configure the cell with a tweet object
    func configure(with tweet: Tweet) {
        usernameLabel.text = tweet.author
        tweetContentView.text = tweet.content
        configureDate(for: tweet)
        configureAvatar(for: tweet)
    }
}
