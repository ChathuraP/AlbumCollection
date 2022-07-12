//
//  AFService.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Alamofire
import AlamofireImage
import CocoaLumberjack

typealias Parameters = [String: Any]
typealias AFResponseObjcType = ([String:Any]?, Error?) -> Void
typealias AFResponseStringType = (String?, Error?) -> ()
typealias AFResponseImageType = (UIImage?, Error?) -> ()

public class AFService {
    
    /// Make GET request via Alamofire
    /// - Parameters:
    ///   - endpoint: URL
    ///   - params: parameters
    ///   - completionHandler: return response
    func makeGetRequest(endpoint: String, params: Parameters?, completionHandler: @escaping AFResponseStringType) {
        
        AF.request(endpoint, method: HTTPMethod.get,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"],
                   requestModifier: {$0.timeoutInterval = 20})
        .validate(statusCode: 200...200)
        .responseString { response in
            switch response.result {
            case .success(let data):
                DDLogVerbose("AFService GET \(endpoint) success")
                completionHandler(data, nil)
            case .failure(let error):
                DDLogError("AFService Request \(endpoint) failed with \(error)")
                completionHandler(nil, error)
            }
        }
    }
    
    /// Download image using Alamofire
    /// - Parameters:
    ///   - imageURL: image URL
    ///   - completionHandler: return image or error
    func downloadImage(imageURL: String, completionHandler: @escaping AFResponseImageType) {
        AF.request(imageURL).responseImage { response in
            switch response.result {
            case .success(let image):
                DDLogVerbose("AFService \(imageURL) download success")
                completionHandler(image, nil)
            case .failure(let error):
                DDLogError("AFService \(imageURL) download failed with \(error)")
                completionHandler(nil, error)
            }
        }
    }
    
}



