//
//  FeedViewController.swift
//  Pugs
//

import Combine
import UIKit
import SnackBar

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
        setupNoInternetView()

        Util.shared.checkInternetConnection { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                self.feedViewModel.getFeedItems()
            } else {
                self.showNoInternetConectionView(state: true)
            }
        }
    }

    func setupHandlerForFeedDataSubject() {
        feedViewModel.feedDataSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.showNoInternetConectionView(state: false)
                    self.collectionView.reloadData()
                case let .failure(error):
                    self.handleError(error: error)
                }
            }
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
        
        let loaderCellIdentifier = String(describing: LoadingCell.self)
        let nibLoaderCell = UINib(nibName: loaderCellIdentifier, bundle: nil)
        collectionView.register(nibLoaderCell, forCellWithReuseIdentifier: loaderCellIdentifier)
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
    
    func handleError(error: PAServiceError) {
        switch error {
        case .noInternetConnection:
            SnackBar.make(in: self.view, message: "The Internet connection appears to be offline.", duration: .lengthShort).show()
        default:
            let errorMessage = "An unexpected error occurred. Please try again later."
            SnackBar.make(in: self.view, message: errorMessage, duration: .lengthShort).show()
            debugPrint("Error: \(error)")
        }
    }
}

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return feedViewModel.feedItems.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let identifier = String(describing: FeedItemCell.self)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? FeedItemCell else {
                fatalError("Unable to dequeue FeedItemCell")
            }

            let feedItem = feedViewModel.feedItems[indexPath.item]
            cell.configure(feedItem: feedItem, index: indexPath.row)
            cell.delegate = self
            return cell
        } else {
            let loaderCellIdentifier = String(describing: LoadingCell.self)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loaderCellIdentifier, for: indexPath) as? LoadingCell else {
                fatalError("Unable to dequeue FeedItemCell")
            }
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == feedViewModel.feedItems.count - 1, !feedViewModel.isLoadingMoreData {
            feedViewModel.getFeedItems()
        }
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat
        switch indexPath.section {
        case 0:
            height = 250
        case 1:
            height = 50
        default:
            height = 0
        }
        return CGSize(width: collectionView.bounds.width, height: height)
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
