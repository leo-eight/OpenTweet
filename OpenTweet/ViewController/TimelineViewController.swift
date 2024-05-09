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
        viewModel.loadTweets { [weak self] error in
            self?.updateUI(onError: error)
        }
        configureNavigationBar()
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
    
    private func configureNavigationBar() {
        // Set the title of the navigation bar
        navigationItem.title = "OpenTweet"
        
        // Remove the UIVisualEffectBackdropView from navigation bar
        view.backgroundColor = .systemBackground
    }
    
    private func showErrorAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func updateUI(onError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                // Handle the error state, e.g., show an alert or error message
                self.showErrorAlert(withMessage: error.localizedDescription)
            } else {
                // Refresh the table view to reflect any new data or changes
                self.tableView.reloadData()
            }
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        let tweet = viewModel.tweets[indexPath.row]
        cell.configure(with: tweet)
        cell.selectionStyle = .none
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell else { return }

        UIView.animate(withDuration: 0.2, animations: {
            // Scale up the cell
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                // Scale down back to normal size
                cell.transform = CGAffineTransform.identity
            })
        }
        
        let tweet = viewModel.tweets[indexPath.row]
        navigateToTweetThread(for: tweet)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
