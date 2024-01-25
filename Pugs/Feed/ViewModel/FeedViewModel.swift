//
//  FeedViewModel.swift
//  Pugs
//

import Combine
import Foundation

class FeedViewModel {
    var feedItems: [FeedItem] = []
    let feedDataSubject = PassthroughSubject<Void, PAServiceError>()
    private let feedApiManager = FeedAPIManager()
    private var isLoadingMoreFeeds = false

    func getFeedItems() {
        guard !isLoadingMoreFeeds else { return }
        isLoadingMoreFeeds = true

        feedApiManager.getFeedData { [weak self] result in
            guard let self = self else { return }
            self.isLoadingMoreFeeds = false
            switch result {
            case let .success(response):
                let feedItems = self.generateFeedItems(from: response)
                DispatchQueue.main.async {
                    self.feedItems.append(contentsOf: feedItems)
                    self.feedDataSubject.send()
                }
            case let .failure(error):
                let customError = PAServiceError.mapError(error)
                self.feedDataSubject.send(completion: .failure(customError))
            }
        }
    }

    func toggleLike(index: Int) {
        guard index >= 0, index < feedItems.count else {
            return
        }

        var feedItem = feedItems[index]
        feedItem.liked.toggle()

        if feedItem.liked {
            feedItem.likedCount += 1
        } else {
            feedItem.likedCount -= 1
        }

        feedItems[index] = feedItem
    }

    private func generateFeedItems(from pugResponse: PugResponse) -> [FeedItem] {
        return pugResponse.message.map { imageUrl in
            let randomLikedCount = Int.random(in: 10 ... 100)
            return FeedItem(imageUrl: imageUrl, liked: false, likedCount: randomLikedCount)
        }
    }
}
