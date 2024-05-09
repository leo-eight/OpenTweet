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

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tweetContentView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = [.link]
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        currentAvatarURL = nil
    }

    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(tweetContentView)
        contentView.addSubview(timestampLabel)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
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

    func configure(with tweet: Tweet) {
        usernameLabel.text = tweet.author
        timestampLabel.text = DateUtility.formatDate(from: tweet.date)
        tweetContentView.text = tweet.content

        if let urlString = tweet.avatar, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            avatarImageView.configure(withName: tweet.author)
        }
    }

    private func loadImage(from url: URL) {
        ImageCacheUtility.getImage(for: url) { [weak self, currentLoadedURL = url] image, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.currentAvatarURL == currentLoadedURL {
                    if let image = image {
                        self.avatarImageView.image = image
                    } else {
                        // Handle the error case
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                        self.avatarImageView.configure(withName: self.usernameLabel.text ?? "")
                    }
                }
            }
        }
        currentAvatarURL = url
    }
}
