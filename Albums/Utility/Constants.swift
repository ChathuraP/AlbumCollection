//
//  Constants.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation


public struct Constants {
    
    public struct Text {
        static let PULLTOREFRESH = "Pull to refresh"
    }
    
    public struct URLs {
        static let BASEURL = "https://jsonplaceholder.typicode.com"
    }
    
    public struct APIs {
        static let ALBUMS = "/albums"
        static let ALBUM_ID = "/albums?id="
        static let ALBUM_RANGE = "/albums?"
        
        static let USERS = "/users"
        static let USER_ID = "/users?id="
        static let USER_RANGE = "/users?"
        
        static let PHOTOS = "/photos"
        static let PHOTO_ALBUM = "/photos?albumId="
    }
    
}

enum AppError: Error, CustomStringConvertible {
    case noData
    case fetchArtistFailed
    case serializationFailed
    case invalidResponse
    case noNetworkConnection
    case unexpectedError(NSError)
    
    var description: String {
        switch self {
        case .noData:
            return "Error: No data could be found"
        case .fetchArtistFailed:
            return "Error: Failed to retrive artist data"
        case .serializationFailed:
            return "Error: read Notifications JSONSerialization error"
        case .invalidResponse:
            return "Error: Unable to read from response JSON"
        case .noNetworkConnection:
            return "Error: No network available"
        case .unexpectedError(let NSError):
            return NSError.localizedDescription
        }
    }
}
