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
    
    private func downloadImageFormURL(url: String){
        APIService().fetchImageFromURL(requestURL: url) { [self] (getResponse:  () throws -> UIImage?) in
            do {
                if let image = try getResponse() {
                    self.imageScrollView.display(image: image)
                } else {
                    // show error
                }
            } catch let error {
                DDLogError("func:downloadImageFormURL #\(error)")
            }
        }
    }

}
