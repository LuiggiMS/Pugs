//
//  PugsTests.swift
//  PugsTests
//

@testable import Pugs
import XCTest
import Combine

class FeedViewModelTests: XCTestCase {
    var sut: FeedViewModel!
    var mockFeedApiManager: MockFeedAPIManager!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        mockFeedApiManager = MockFeedAPIManager()
        sut = FeedViewModel()
        sut.feedApiManager = mockFeedApiManager
    }

    func testGetFeedItemsSuccess() {
        // Given
        let mockPugResponse = PugResponse(message: ["https://images.dog.ceo/breeds/pug/IMG_8459.jpg", "https://images.dog.ceo/breeds/pug/bobby.jpg"], status: "success")
        mockFeedApiManager.mockResult = .success(mockPugResponse)

        let expectation = XCTestExpectation(description: "FeedDataSubject should emit")

        // When
        sut.feedDataSubject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Error received: \(error)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)
        sut.getFeedItems()
        
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertEqual(sut.feedItems.count, 2)
    }

    func testGetFeedItemsFailure() {
        // Given
        let mockError = NSError(domain: "TestErrorDomain", code: 123, userInfo: nil)
        mockFeedApiManager.mockResult = .failure(mockError)

        let expectation = XCTestExpectation(description: "FeedDataSubject should emit")

        // When
        sut.feedDataSubject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTAssertEqual(error, .other(mockError))
                    expectation.fulfill()
                }
            }, receiveValue: {
                XCTFail("Should not receive a value in case of failure")
            })
            .store(in: &cancellables)
        sut.getFeedItems()

        wait(for: [expectation], timeout: 1)
        
        // Then
        XCTAssertTrue(sut.feedItems.isEmpty)
    }
    
    func testGetPugResponseFromJson() {
        do {
            // Given
            if let fileUrl = Bundle(for: type(of: self)).url(forResource: "PugResponse", withExtension: "json"),
               let data = try? Data(contentsOf: fileUrl) {
                
                // When
                let apiResponse = try JSONDecoder().decode(PugResponse.self, from: data)

                // Then
                XCTAssertEqual(apiResponse.status, "success")
                XCTAssertEqual(apiResponse.message.count, 2)
                XCTAssertEqual(apiResponse.message[0], "https://images.dog.ceo/breeds/pug/IMG_8459.jpg")
                XCTAssertEqual(apiResponse.message[1], "https://images.dog.ceo/breeds/pug/bobby.jpg")
            } else {
                XCTFail("Failed to load the JSON file.")
            }
        } catch {
            XCTFail("Error decoding DogApiResponse: \(error)")
        }
    }

    override func tearDownWithError() throws {
        sut = nil
        mockFeedApiManager = nil
        cancellables.removeAll()
    }
}
