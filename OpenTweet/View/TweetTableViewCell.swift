//
//  TweetTableViewCell.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tweetContentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    func configure(with tweet: Tweet) {
        usernameLabel.text = tweet.author
        tweetContentLabel.text = tweet.content
        timestampLabel.text = DateUtility.formatDate(from: tweet.date)
        
        if let urlString = tweet.avatar, let url = URL(string: urlString) {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image
                    }
                }
            }
        }
    }
}
