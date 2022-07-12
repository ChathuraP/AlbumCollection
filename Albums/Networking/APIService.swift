//
//  APIService.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import CocoaLumberjack
import Alamofire

typealias Parameters = [String: Any]
typealias APIResponseAlbumArray = (() throws -> [Album]) -> ()
typealias APIResponsePhotosArray = (() throws ->[Photo]) -> ()
typealias APIResponseUsersDictionary = (() throws -> [Int : User]) -> ()
typealias APIResponseImage = (() throws -> UIImage?) -> ()

public class APIService {
    private let networkStat = NetworkReachabilityManager()!
    
    private func isInternetAvailable() -> Bool {
        return networkStat.isReachable
    }
    
    // MARK: - fetch Albums from API
    func fetchAlbums(requestString: String, completionHandler: @escaping APIResponseAlbumArray) {
        if !isInternetAvailable() {
            completionHandler({ throw AppError.noNetworkConnection })
        }
        
        let requestURL = Constants.URLs.BASEURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch Albums Failed: \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                DDLogInfo("✅ Fetch Albums Completed \(requestString)")
                guard let response = responseStr else {
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                var albumList = [Album]()
                if let albums = response.jsonStringToArray() {
                    for item in albums {
                        if let albumData = item as? Dictionary<String, Any> {
                            let album = Album(data: albumData)
                            albumList.append(album)
                        } else {
                            completionHandler({ throw AppError.invalidResponse })
                        }
                    }
                    completionHandler({ return albumList })
                } else {
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch user for given Albums from API
    func fetchUsers(requestString: String, completionHandler: @escaping APIResponseUsersDictionary) {
        if !isInternetAvailable() {
            completionHandler({ throw AppError.noNetworkConnection })
        }
        
        let requestURL = Constants.URLs.BASEURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch Artists Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                DDLogInfo("✅ Fetch Artists Completed")
                guard let response = responseStr else {
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                var userList: [Int : User] = [:]
                if let users = response.jsonStringToArray() {
                    for item in users {
                        if let userData = item as? Dictionary<String, Any> {
                            let user = User(data: userData)
                            userList[user.id] = user
                        } else {
                            completionHandler({ throw AppError.invalidResponse })
                        }
                    }
                    completionHandler({ return userList })
                } else {
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch Photo data for album from API
    func fetchPhotosForAlbum(requestURL: String, completionHandler: @escaping APIResponsePhotosArray) {
        if !isInternetAvailable() {
            completionHandler({ throw AppError.noNetworkConnection })
        }
        
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("❌ Fetch Photos for album Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
                DDLogInfo("✅ Fetch Photos for album Completed")
                guard let response = responseStr else {
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                var photosData = [Photo]()
                if let photos = response.jsonStringToArray() {
                    for item in photos {
                        if let photoInfo = item as? Dictionary<String, Any> {
                            let photo = Photo(data: photoInfo)
                            photosData.append(photo)
                        } else {
                            completionHandler({ throw AppError.invalidResponse })
                        }
                    }
                    completionHandler({ return photosData })
                } else {
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    // MARK: - fetch image for given URL
    func fetchImageFromURL(requestURL: String, completionHandler: @escaping APIResponseImage) {
        if !isInternetAvailable() {
            completionHandler({ throw AppError.noNetworkConnection })
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
                    completionHandler({ throw AppError.invalidResponse })
                }
            }
        }
    }
    
}
