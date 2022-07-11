//
//  Album.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation

struct Album {
    let userId: Int
    let id: Int
    let title: String
    var artist: User?
    
    mutating func updateArtist(With user: User) {
        artist = user
    }
}

extension Album {
    init(data: Dictionary<String, Any>) {
        userId = data["userId"] as? Int ?? -1
        id = data["id"] as? Int ?? -1
        title = data["title"] as? String ?? ""
        artist = nil
    }
}
