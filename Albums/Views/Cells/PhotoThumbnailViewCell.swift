//
//  PhotoThumbnailViewCell.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import UIKit

class PhotoThumbnailViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    
    var photoData: Photo? {
        didSet {
            DispatchQueue.main.async {
                if let myPhoto = self.photoData {
                    self.thumbnailView.loadImageFromCache(with: myPhoto.thumbnailUrl)
                }
            }
        }
    }
}
