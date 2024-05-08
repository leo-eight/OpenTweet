//
//  Tweet.swift
//  OpenTweet
//
//  Created by on 2024-05-07.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

struct Tweet: Decodable {
    let id: String
    let author: String
    let content: String
    let date: String
    let inReplyTo: String?
    let avatar: String?
}
