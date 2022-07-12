//
//  APIService.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import CocoaLumberjack
import Alamofire

typealias APIResponseAlbumArray = (() throws -> [Album]) -> ()
typealias APIResponsePhotosArray = (() throws ->[Photo]) -> ()
typealias APIResponseUsersDictionary = (() throws -> [Int : User]) -> ()
typealias APIResponseImage = (() throws -> UIImage?) -> ()

public class APIService {
    private let networkStat = NetworkReachabilityManager()!
    
    
    /// Check for Internet availability
    /// - Returns: Internet availability status
    private func isInternetAvailable() -> Bool {
        return networkStat.isReachable
    }
    
    // MARK: - fetch Albums
    
    /// Download Albums from network
    /// - Parameters:
    ///   - requestString: URL Query string
    ///   - completionHandler: send back [Album] array or error
    func fetchAlbums(requestString: String, completionHandler: @escaping APIResponseAlbumArray) {
        if !isInternetAvailable() {
            DDLogError("No network connection")
            completionHandler({ throw AppError.noNetworkConnection })
            return
        }
        
        let requestURL = Constants.URLs.BASEURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch albums failed: \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                guard let response = responseStr else {
                    DDLogError("Invalid fetch albums response")
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                DDLogInfo("✅ Fetch albums completed \(requestString)")
                var albumList = [Album]()
                if let albums = response.jsonStringToArray() {
                    for item in albums {
                        if let albumData = item as? Dictionary<String, Any> {
                            let album = Album(data: albumData)
                            albumList.append(album)
                        } else {
                            DDLogError("Failed to create Album objects")
                            completionHandler({ throw AppError.invalidResponse })
                            return
                        }
                    }
                    completionHandler({ return albumList })
                } else {
                    DDLogError("Failed to deserialize Albums")
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch user for given artist ids
    
    /// Download artists from network
    /// - Parameters:
    ///   - requestString: URL Query string
    ///   - completionHandler: send back [Int : User] dictionary or error
    func fetchUsers(requestString: String, completionHandler: @escaping APIResponseUsersDictionary) {
        if !isInternetAvailable() {
            DDLogError("No network connection")
            completionHandler({ throw AppError.noNetworkConnection })
            return
        }
        
        let requestURL = Constants.URLs.BASEURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch artists failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                guard let response = responseStr else {
                    DDLogError("Invalid fetch users response")
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                DDLogInfo("✅ Fetch artists completed")
                var userList: [Int : User] = [:]
                if let users = response.jsonStringToArray() {
                    for item in users {
                        if let userData = item as? Dictionary<String, Any> {
                            let user = User(data: userData)
                            userList[user.id] = user
                        } else {
                            DDLogError("Failed to create User objects")
                            completionHandler({ throw AppError.invalidResponse })
                            return
                        }
                    }
                    completionHandler({ return userList })
                } else {
                    DDLogError("Failed to deserialize Users")
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch Photo data for album from API
    
    /// Download Photo data from network
    /// - Parameters:
    ///   - requestString: URL Query string
    ///   - completionHandler: send back [Photo] array or error
    func fetchPhotosForAlbum(requestURL: String, completionHandler: @escaping APIResponsePhotosArray) {
        if !isInternetAvailable() {
            DDLogError("No network connection")
            completionHandler({ throw AppError.noNetworkConnection })
            return
        }
        
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch Photos for album Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                guard let response = responseStr else {
                    DDLogError("Invalid fetch Photo data response")
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                DDLogInfo("✅ Fetch Photos for album Completed")
                var photosData = [Photo]()
                if let photos = response.jsonStringToArray() {
                    for item in photos {
                        if let photoInfo = item as? Dictionary<String, Any> {
                            let photo = Photo(data: photoInfo)
                            photosData.append(photo)
                        } else {
                            DDLogError("Failed to create Photo objects")
                            completionHandler({ throw AppError.invalidResponse })
                            return
                        }
                    }
                    completionHandler({ return photosData })
                } else {
                    DDLogError("Failed to deserialize Photo data")
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch image for given URL
    
    /// Download image from network
    /// - Parameters:
    ///   - requestURL: image URL
    ///   - completionHandler: send back UIImage or error
    func fetchImageFromURL(requestURL: String, completionHandler: @escaping APIResponseImage) {
        if !isInternetAvailable() {
            DDLogError("No network connection")
            completionHandler({ throw AppError.noNetworkConnection })
            return
        }
        
        AFService().downloadImage(imageURL: requestURL) { responseImage, error in
            if let err = error {
                DDLogError("❌ Fetch Image Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                DDLogInfo("✅ Fetch Image Completed")
                if let image = responseImage {
                    completionHandler({ return image })
                } else {
                    DDLogError("Invalid image response")
                    completionHandler({ throw AppError.invalidResponse })
                }
            }
        }
    }
    
}
