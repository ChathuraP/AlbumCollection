//
//  StringExtension.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation
import CocoaLumberjack

extension String {
    
    /// Convert JSON data to a dictionary
    /// - Returns: dictionary or nil
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
    
    /// Convert JSON data to a array
    /// - Returns: array or nil
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
    
    
    /// Capitalize first latter of the sentence
    /// - Returns: Sentence case text
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
