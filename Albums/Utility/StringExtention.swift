//
//  StringExtention.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import CocoaLumberjack

extension String {
    func jsonStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                DDLogError(error.localizedDescription)
            }
        }
        return nil
    }
    
    func jsonStringToArray() -> [Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                DDLogError(error.localizedDescription)
            }
        }
        return nil
    }
    
    func capitalizingFirstLetter() -> String {
           return prefix(1).capitalized + dropFirst()
       }

       mutating func capitalizeFirstLetter() {
           self = self.capitalizingFirstLetter()
       }
}
