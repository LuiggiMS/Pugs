//
//  FeedItemCell.swift
//  Pugs
//

import UIKit
import NukeExtensions

protocol FeedItemProtocol: AnyObject {
    func didTapLike(atIndex index: Int)
}

class FeedItemCell: UICollectionViewCell {

    @IBOutlet weak var pubImg: UIImageView!
    @IBOutlet weak var likesCountLbl: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: FeedItemProtocol!
    var itemIndex: Int = 0
    var feedItem: FeedItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(feedItem: FeedItem, index: Int) {
        self.itemIndex = index
        self.feedItem = feedItem
        likesCountLbl.text = "\(feedItem.likedCount) Likes"
        NukeExtensions.loadImage(with: URL(string: feedItem.imageUrl), into: pubImg)
        updateLikeButtonAppearance()
    }

    @IBAction func didTapLikeButton(_ sender: UIButton) {
        updateLikeButtonAppearance()
        delegate?.didTapLike(atIndex: itemIndex)
    }

    private func configureDefaultButtonAppearance() {
        likeButton.configuration?.baseForegroundColor = .black
    }

    private func updateLikeButtonAppearance() {
        if feedItem.liked {
            likeButton.configuration?.baseForegroundColor = .red
        } else {
            configureDefaultButtonAppearance()
        }
    }
}
