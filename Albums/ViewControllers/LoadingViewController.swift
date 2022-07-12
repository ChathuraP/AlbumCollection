//
//  LoadingViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 12/7/22.
//

import UIKit

@objc
public protocol LoadingViewDelegate {
    func retryButtonTapped()
}

class LoadingViewController: UIViewController {
    
    @IBOutlet weak private var errorView: UIView!
    @objc weak var delegate: LoadingViewDelegate?
    
    var errorOccurred: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.errorView.isHidden = !self.errorOccurred
            }
        }
    }
    
    @IBAction func reTryButtonTapped(_ sender: UIButton) {
        self.delegate?.retryButtonTapped()
    }
}
