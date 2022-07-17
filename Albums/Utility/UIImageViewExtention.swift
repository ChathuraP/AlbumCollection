//
//  UIImageViewExtention.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import CocoaLumberjack
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    
    /// Try to load image form cache if not available download it
    /// - Parameter urlString: image URL
    func loadImageFromCache(with urlString: String) {
        self.image = nil
        let placeholderImage = UIImage(named: "no-image")!
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        APIService().fetchImageFromURL(requestURL: urlString) { [self] (getResponse:  () throws -> UIImage?) in
            do {
                if let downloadedImage = try getResponse() {
                    self.cacheAndSetNewImage(downloadedImage: downloadedImage, forURL: urlString)
                } else {
                    self.setNewImage(placeholderImage)
                    DDLogError("func:loadImageFromCache decode image failed)")
                }
            } catch let error {
                self.setNewImage(placeholderImage)
                DDLogError("func:loadImageFromCache #\(error)")
            }
        }
    }
    
    private func cacheAndSetNewImage(downloadedImage: UIImage, forURL: String) {
        imageCache.setObject(downloadedImage, forKey: forURL as NSString)
        self.setNewImage(downloadedImage)
    }
    
    private func setNewImage(_ newImage: UIImage) {
        DispatchQueue.main.async {
            self.image = newImage
        }
    }
    
}
