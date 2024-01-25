//
//  MockFeedAPIManager.swift
//  PugsTests
//

import Foundation
@testable import Pugs

public class MockFeedAPIManager: FeedAPIManager {
    public var mockResult: Result<PugResponse, Error> = .success(PugResponse(message: [], status: "success"))

    public override func getFeedData(completion: @escaping (Result<PugResponse, Error>) -> Void) {
        completion(mockResult)
    }
}
