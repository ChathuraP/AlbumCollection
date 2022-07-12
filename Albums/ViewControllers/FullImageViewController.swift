//
//  FullImageViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import UIKit
import ImageScrollView
import CocoaLumberjack

class FullImageViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var photoData: Photo? = nil {
        didSet {
            if let data = photoData{
                self.imageURL = data.url
            }
        }
    }
    private var imageURL: String? = nil {
        didSet {
            if let urlStr = imageURL,
               let url = URL(string: urlStr),
               UIApplication.shared.canOpenURL(url){
                self.downloadImageFormURL(url: urlStr)
            }
        }
    }
    
    // MARK: - LifeCycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageScrollView.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = photoData {
            self.title = String(data.id)
        }
    }
    
    // MARK: - Private functions
    
    /// Shows alert message to the use, go to previous screen upon user tap OK
    private func showErrorPopup() {
        let alert = UIAlertController(title: Constants.Text.ALERT_TITLE_OPPS, message: Constants.Text.ALERT_MSG_NO_IMAGE, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.Text.ALERT_OK_BTN, style: UIAlertAction.Style.default, handler: {_ in
            DispatchQueue.main.async(execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - API Network calls
    
    /// Download full size image from API
    /// - Parameter url: URL for full size image
    private func downloadImageFormURL(url: String){
        APIService().fetchImageFromURL(requestURL: url) { [self] (getResponse:  () throws -> UIImage?) in
            do {
                if let image = try getResponse() {
                    self.imageScrollView.display(image: image)
                } else {
                    DDLogError("func:downloadImageFormURL failed")
                    self.imageScrollView.display(image: UIImage(named: "no-image")!)
                    self.showErrorPopup()
                }
            } catch let error {
                DDLogError("func:downloadImageFormURL #\(error)")
                self.imageScrollView.display(image: UIImage(named: "no-image")!)
                self.showErrorPopup()
            }
        }
    }
    
}
