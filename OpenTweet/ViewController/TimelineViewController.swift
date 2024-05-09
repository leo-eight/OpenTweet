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
    // MARK: - Properties
    var tableView: UITableView!
    var viewModel = TweetsViewModel()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        loadTweets()
    }
    
    private func configureUI() {
        setupTableView()
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
    
    private func loadTweets() {
        viewModel.loadTweets { [weak self] error in
            self?.updateUI(onError: error)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "OpenTweet"
        view.backgroundColor = .systemBackground
    }
    
    private func navigateToTweetThread(for tweet: Tweet) {
        let tweetThreadVC = TweetThreadViewController()
        prepareDataForNavigation(to: tweetThreadVC, with: tweet)
        
        if let nav = navigationController {
            nav.pushViewController(tweetThreadVC, animated: true)
        }
    }
    
    private func prepareDataForNavigation(to viewController: TweetThreadViewController, with tweet: Tweet) {
        if let replyToId = tweet.inReplyTo {
            viewController.tweets = viewModel.tweets.filter { $0.id == replyToId || $0.inReplyTo == tweet.id }
        } else {
            viewController.tweets = viewModel.tweets.filter { $0.inReplyTo == tweet.id }
        }
    }
    
    private func updateUI(onError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.showErrorAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    private func showErrorAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - Table View Data Source and Delegate
extension TimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        cell.configure(with: viewModel.tweets[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell else { return }
        animateSelection(for: cell)
        let tweet = viewModel.tweets[indexPath.row]
        navigateToTweetThread(for: tweet)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func animateSelection(for cell: TweetTableViewCell) {
        UIView.animate(withDuration: 0.2, animations: {
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
}
