//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit
import Combine

class TimelineViewController: UIViewController {
    
    var tableView: UITableView!
    var viewModel = TweetsViewModel()
    var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
        
        setupTableView()
        bindViewModel()
        viewModel.loadTweets()
	}

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: "TweetTableViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func bindViewModel() {
        viewModel.$tweets.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    private func navigateToTweetThread(for tweet: Tweet) {
        let tweetThreadVC = TweetThreadViewController()
        
        if let replyToId = tweet.inReplyTo {
            // It's a reply to another tweet, find the original tweet
            if let originalTweet = viewModel.tweets.first(where: { $0.id == replyToId }) {
                tweetThreadVC.tweets = [originalTweet, tweet]  // Show original and reply
            }
        } else {
            // It's an original tweet, find all replies
            let replies = viewModel.tweets.filter { $0.inReplyTo == tweet.id }
            tweetThreadVC.tweets = [tweet] + replies.sorted { $0.date < $1.date }
        }

        if let nav = navigationController {
            nav.pushViewController(tweetThreadVC, animated: true)
        } else {
            print("NavigationController is nil")
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.count
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        
        let tweet = viewModel.tweets[indexPath.row]
        cell.configure(with: tweet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweet = viewModel.tweets[indexPath.row]
        navigateToTweetThread(for: tweet)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
