//
//  LoadingViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 12/7/22.
//

import UIKit

@objc
public protocol LoadingViewDelegate {
    
    /// This method will delegate the user retry action to the main view controller
    func retryButtonTapped()
}

class LoadingViewController: UIViewController {
    
    @IBOutlet weak private var errorView: UIView!
    @objc weak var delegate: LoadingViewDelegate?
    
    /// Used for toggle between download InProgress and Error occurred screens
    var errorOccurred: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.errorView.isHidden = !self.errorOccurred
            }
        }
    }
    
    /// Triggers when user tap on RETRY button on the error screen
    /// - Parameter sender: UIButton
    @IBAction func reTryButtonTapped(_ sender: UIButton) {
        self.delegate?.retryButtonTapped()
    }
}
