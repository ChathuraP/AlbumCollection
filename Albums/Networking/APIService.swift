//
//  APIService.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import CocoaLumberjack

typealias Parameters = [String: Any]
typealias APIResponseAlbumArray = (() throws -> [Album]) -> ()
typealias APIResponseUserObject = (() throws -> User?) -> ()
typealias APIResponseUsersArray = (() throws -> [User]) -> ()
typealias APIResponsePhotosArray = (() throws ->[Photo]) -> ()
typealias APIResponseUsersDictionary = (() throws -> [Int : User]) -> ()

public class APIService {
    public static let shared = APIService()
    
    func fetchAlbums(requestString: String, completionHandler: @escaping APIResponseAlbumArray) {
        let requestURL = Constants.URLs.baseURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("Fetch Albums Failed: \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
//                DDLogInfo("Fetch Albums Completed \(requestString)")
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
    
    func fetchUsers(requestString: String, completionHandler: @escaping APIResponseUsersDictionary) {
        let requestURL = Constants.URLs.baseURL + requestString
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("Fetch Users Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
//                DDLogInfo("Fetch Users Completed")
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
    
    func fetchUserForId(_ userId: String, completionHandler: @escaping APIResponseUserObject) {
        let requestURL = Constants.URLs.baseURL + Constants.APIs.userId + userId
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("Fetch User \(userId) Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
//                DDLogInfo("Fetch User \(userId) Completed")
                guard let response = responseStr else {
                    completionHandler({ throw AppError.invalidResponse })
                    return
                }
                if let userData = response.jsonStringToArray(),
                   let user = userData.first as? Dictionary<String, Any> {
                    let user = User(data: user)
                    completionHandler({ return user })
                } else {
                    completionHandler({ throw AppError.serializationFailed })
                    return
                }
            }
        })
    }
    
    func fetchPhotosForAlbum(requestURL: String, completionHandler: @escaping APIResponsePhotosArray) {
        AFService().makeGetRequest(endpoint: requestURL, params: nil, completionHandler: { responseStr, error in
            if let err = error {
                DDLogError("Fetch Photos for album Failed \(err.localizedDescription)")
                completionHandler({ throw err })
            } else {
//                DDLogInfo("Fetch Photos for album \(userId) Completed")
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
    
    
//    private func requestParamsforFetch(onComplete: @escaping ((Parameters?) -> Void)) {
//
//
//        onComplete("postData")
//    }
    
}
