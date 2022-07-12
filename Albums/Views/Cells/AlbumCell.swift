//
//  AlbumCell.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import UIKit

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var album: Album? {
        didSet {
            DispatchQueue.main.async {
                if let myAlbum = self.album {
                    self.titleLabel.text = myAlbum.title.capitalizingFirstLetter()
                    self.artistLabel.text = myAlbum.artist?.name
                }
            }
        }
    }

}
