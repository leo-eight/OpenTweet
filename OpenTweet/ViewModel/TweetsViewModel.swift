//
//  TweetsViewModel.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import Combine

class TweetsViewModel {
    @Published var tweets: [Tweet] = []

    func loadTweets() {
        guard let url = Bundle.main.url(forResource: "timeline", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load JSON")
        }

        let decoder = JSONDecoder()
        if let timeline = try? decoder.decode(Timeline.self, from: data) {
            self.tweets = timeline.timeline
        } else {
            self.tweets = []
        }
    }
}
