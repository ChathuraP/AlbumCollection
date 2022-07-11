//
//  AFService.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import Alamofire
import CocoaLumberjack

typealias AFResponseObjcType = ([String:Any]?, Error?) -> Void
typealias AFResponseStringType = (String?, Error?) -> ()

public class AFService {
    
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
//                DDLogInfo("AFService response \(data)")
                completionHandler(data, nil)
            case .failure(let error):
                DDLogError("AFService Request failed\(error)")
                completionHandler(nil, error)
            }
        }
    }
    
//    func makePostRequest(endpoint: String, params: Parameters, completionHandler: @escaping ([String:Any]?, Error?) -> Void) {
//
//    }
    
}



