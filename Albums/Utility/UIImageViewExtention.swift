//
//  UIImageViewExtention.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import Alamofire
import AlamofireImage
import CocoaLumberjack
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageFromCache(with urlString: String) {
        self.image = nil
//        self.setNewImage(UIImage(named: "imageInprogress")!)
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        APIService().fetchImageFromURL(requestURL: urlString) { [self] (getResponse:  () throws -> UIImage?) in
            do {
                if let downloadedImage = try getResponse() {
                    self.loadImage(downloadedImage: downloadedImage, forURL: urlString)
                } else {
                    self.setNewImage(UIImage(named: "no-image")!)
                    DDLogError("func:loadImageFromCache decode image failed)")
                }
            } catch let error {
                self.setNewImage(UIImage(named: "no-image")!)
                DDLogError("func:loadImageFromCache #\(error)")
            }
        }
    }
    
    private func loadImage(downloadedImage: UIImage, forURL: String) {
        imageCache.setObject(downloadedImage, forKey: forURL as NSString)
        self.setNewImage(downloadedImage)
    }
    private func setNewImage(_ newImage: UIImage) {
        DispatchQueue.main.async {
            self.image = newImage
        }
    }
    
}
