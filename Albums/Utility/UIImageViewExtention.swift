//
//  UIImageViewExtention.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import Alamofire
import AlamofireImage

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageFromCache(with urlString: String) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        AF.request(urlString).responseImage { response in
            if let downloadedImage = response.value {
                imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                self.image = downloadedImage
            }
        }
    }
}
