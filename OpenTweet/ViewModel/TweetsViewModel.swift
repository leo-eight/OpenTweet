//
//  TweetsViewModel.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

class TweetsViewModel {
    @Published var tweets: [Tweet] = []

    func loadTweets(completion: @escaping (Error?) -> Void) {
        guard let url = Bundle.main.url(forResource: "timeline", withExtension: "json") else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"]))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            parseTweets(from: data)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    internal func parseTweets(from data: Data) {
        let decoder = JSONDecoder()
        do {
            let timeline = try decoder.decode(Timeline.self, from: data)
            self.tweets = timeline.timeline
        } catch {
            print("Error: Unable to decode JSON - \(error.localizedDescription)")
            // Clear data if necessary
            self.tweets = []
        }
    }
}
