//
//  UIImageViewExtention.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import Alamofire
import AlamofireImage
import CocoaLumberjack

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageFromCache(with urlString: String) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        APIService().fetchImageFromURL(requestURL: urlString) { [self] (getResponse:  () throws -> UIImage?) in
            do {
                if let downloadedImage = try getResponse() {
                    self.loadImage(downloadedImage: downloadedImage, forURL: urlString)
                } else {
                    DDLogError("func:loadImageFromCache decode image failed)")
                }
            } catch let error {
                DDLogError("func:loadImageFromCache #\(error)")
            }
        }
    }
    
    private func loadImage(downloadedImage: UIImage, forURL: String) {
        imageCache.setObject(downloadedImage, forKey: forURL as NSString)
        self.image = downloadedImage
    }
    
}
