//
//  FeedViewController.swift
//  Pugs
//

import Combine
import UIKit

class FeedViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    let feedViewModel = FeedViewModel()
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localized.key("FeedTitle")

        setupCollectionView()
        setupHandlerForFeedDataSubject()
        feedViewModel.getFeedItems()
    }

    func setupHandlerForFeedDataSubject() {
        feedViewModel.feedDataSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    debugPrint("Error: \(error)")
                case .finished: break
                }
            }, receiveValue: {
                self.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        let nibFeedItemCell = UINib(nibName: "FeedItemCell", bundle: nil)
        collectionView.register(nibFeedItemCell, forCellWithReuseIdentifier: "FeedItemCell")

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: 200)
            flowLayout.minimumInteritemSpacing = 0
        }
    }
}

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return feedViewModel.feedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCell", for: indexPath) as? FeedItemCell else {
            fatalError("Unable to dequeue FeedItemCell")
        }

        let feedItem = feedViewModel.feedItems[indexPath.item]
        cell.configure(feedItem: feedItem, index: indexPath.row)
        cell.delegate = self
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 250)
    }
}

extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        guard feedViewModel.feedItems.count > 0, !feedViewModel.isLoadingMoreData else {
            return
        }

        if offsetY > contentHeight - height {
            feedViewModel.getFeedItems()
        }
    }
}

extension FeedViewController: FeedItemProtocol {
    func didTapLike(atIndex index: Int) {
        feedViewModel.toggleLike(index: index)
        collectionView.reloadData()
    }
}
