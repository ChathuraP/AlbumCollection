//
//  Photo.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation

struct Photo {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}

extension Photo {
    init(data: Dictionary<String, Any>) {
        id = data["id"] as? Int ?? -1
        albumId = data["albumId"] as? Int ?? -1
        title = data["title"] as? String ?? ""
        url = data["url"] as? String ?? ""
        thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
    }
}
