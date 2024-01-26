//
//  FeedViewController.swift
//  Pugs
//

import Combine
import UIKit

class FeedViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    var noInternetView: NoInternetView!
    let feedViewModel = FeedViewModel()
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localized.key("FeedTitle")
        
        setupCollectionView()
        setupHandlerForFeedDataSubject()
        
        Util.shared.checkInternetConnection { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                self.feedViewModel.getFeedItems()
            } else {
                self.setupNoInternetView()
                self.showNoInternetConectionView(state: true)
            }
        }
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
                self.showNoInternetConectionView(state: false)
                self.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let identifier = String(describing: FeedItemCell.self)
        let nibFeedItemCell = UINib(nibName: identifier, bundle: nil)
        collectionView.register(nibFeedItemCell, forCellWithReuseIdentifier: identifier)

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: 200)
            flowLayout.minimumInteritemSpacing = 0
        }
    }
    
    func setupNoInternetView() {
        let nibNamed = String(describing: NoInternetView.self)
        noInternetView = Bundle.main.loadNibNamed(nibNamed, owner: self, options: nil)?.first as? NoInternetView
        noInternetView.frame = view.bounds
        noInternetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(noInternetView)
        noInternetView.delegate = self
        noInternetView.isHidden = true
    }
    
    func showNoInternetConectionView(state: Bool) {
        navigationController?.navigationBar.isHidden = state
        noInternetView.isHidden = !state
        collectionView.isHidden = state
    }
}

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return feedViewModel.feedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: FeedItemCell.self)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? FeedItemCell else {
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

extension FeedViewController: NoInternetViewDelegate {
    func didSelectReload() {
        DispatchQueue.main.async {
            self.feedViewModel.getFeedItems()
        }
    }
}
