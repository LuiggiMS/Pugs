//
//  NoInternetView.swift
//  Pugs
//

import UIKit

protocol NoInternetViewDelegate: AnyObject {
    func didSelectReload()
}

class NoInternetView: UIView {
    
    weak var delegate: NoInternetViewDelegate?
    
    @IBAction func didTapReload(_ sender: Any) {
        delegate?.didSelectReload()
    }

}
