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
        static let baseURL = "https://jsonplaceholder.typicode.com"
    }
    
    public struct APIs {
        static let albums = "/albums"
        static let albumId = "/albums?id="
        static let albumRange = "/albums?"
        
        static let users = "/users"
        static let userId = "/users?id="
        static let userRange = "/users?"
        
        static let photos = "/photos"
        static let photoAlbum = "/photos?albumId="
    }
    
}

enum AppError: Error, CustomStringConvertible {
    case noData
    case fetchArtistFailed
    case serializationFailed
    case invalidResponse
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
        case .unexpectedError(let NSError):
            return NSError.localizedDescription
        }
    }
}
