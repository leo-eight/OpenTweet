//
//  OpenTweetTests.swift
//  OpenTweetTests
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import XCTest
@testable import OpenTweet

class OpenTweetTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test JSON parsing with valid data
    func testGivenValidJSON_WhenParsing_ThenTweetsAreCorrectlyPopulated() {
        let viewModel = TweetsViewModel()
        let jsonData = """
        {
            "timeline": [
                                {
                                "id": "00004",
                                "author": "@ot_competitor",
                                "content": "@olarivain Meh.",
                                "inReplyTo": "00042",
                                "date": "2020-09-30T09:45:00-08:00"
                                },
            ]
        }
        """.data(using: .utf8)!

        viewModel.parseTweets(from: jsonData)

        XCTAssertEqual(viewModel.tweets.count, 1)
        XCTAssertEqual(viewModel.tweets[0].author, "@ot_competitor")
    }

    // Test JSON parsing with invalid data
    func testGivenInvalidJSON_WhenParsing_ThenTweetsArrayIsEmpty() {
        let viewModel = TweetsViewModel()
        let jsonData = "Invalid JSON".data(using: .utf8)!

        viewModel.parseTweets(from: jsonData)

        XCTAssertTrue(viewModel.tweets.isEmpty)
    }

    // Test date formatting with valid ISO date
    func testGivenValidISODate_WhenFormatting_ThenCorrectDisplayDateIsReturned() {
        let isoDate = "2021-06-09T12:34:56Z"

        let formattedDate = DateUtility.formatDate(from: isoDate)

        XCTAssertEqual(formattedDate, "June 09, 2021 at 12:34 PM")
    }

    // Test date formatting with invalid date string
    func testGivenInvalidDateString_WhenFormatting_ThenInvalidDateIsReturned() {
        let isoDate = "Invalid date"

        let formattedDate = DateUtility.formatDate(from: isoDate)

        XCTAssertEqual(formattedDate, "Invalid date")
    }

    // Test image caching
    func testGivenURL_WhenRequestedImage_ThenImageIsFetchedAndCached() {
        let url = URL(string: "https://avatars1.githubusercontent.com/u/536608?v=3&s=460")!
        let expect = expectation(description: "Image should be fetched and cached")

        ImageCacheUtility.getImage(for: url) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)

            ImageCacheUtility.getImage(for: url) { cachedImage, cachedError in
                XCTAssertNotNil(cachedImage)
                XCTAssertNil(cachedError)
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }
    
    func testGivenNameAndSize_WhenGeneratingInitialsImage_ThenImageIsNotNilAndCorrectSize() {
        let name = "Tester"
        let size = CGSize(width: 100, height: 100)
        let backgroundColor = UIColor.lightGray
        let textColor = UIColor.white

        let image = InitialsImageUtility.generateInitialsImage(for: name, size: size, backgroundColor: backgroundColor, textColor: textColor)

        XCTAssertNotNil(image, "The image should not be nil")
        XCTAssertEqual(image?.size, size, "The image should be of the correct size")
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
