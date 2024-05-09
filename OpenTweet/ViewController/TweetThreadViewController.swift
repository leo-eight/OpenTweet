//
//  TweetThreadViewController.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

class TweetThreadViewController: UIViewController {
    // MARK: - Properties
    var tableView: UITableView!
    var tweets: [Tweet] = []  // This will hold the main tweet and its replies
    var animator: UIDynamicAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupUI()
        animator = UIDynamicAnimator(referenceView: tableView)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: "TweetTableViewCell")
        view.addSubview(tableView)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Tweet Thread"
    }
}

// MARK: - Table View Data Source and Delegate
extension TweetThreadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        cell.configure(with: tweets[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

extension TweetThreadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell else { return }
        
        // Store the original center
        let originalCenter = cell.center
        
        // Offset the anchor to below the center
        let offset = CGPoint(x: cell.center.x, y: cell.center.y + 10)
        let attachmentBehavior = UIAttachmentBehavior(item: cell, attachedToAnchor: offset)
        attachmentBehavior.length = 0
        attachmentBehavior.damping = 0.3
        attachmentBehavior.frequency = 1.5
        animator?.addBehavior(attachmentBehavior)
        
        // Schedule the removal of the behavior and reset the cell's position
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.animator?.removeBehavior(attachmentBehavior)
            
            // Reset the cell's center after the animation completes
            UIView.animate(withDuration: 0.2) {
                cell.center = originalCenter
                tableView.layoutIfNeeded()  // This ensures the tableView properly updates the layout if needed
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
