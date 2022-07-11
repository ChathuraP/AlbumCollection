//
//  User.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import Foundation

struct User {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: Address?
    let company: Company?
}

extension User {
    init(data: Dictionary<String, Any>) {
        id = data["id"] as? Int ?? -1
        name = data["name"] as? String ?? ""
        username = data["username"] as? String ?? ""
        email = data["email"] as? String ?? ""
        phone = data["phone"] as? String ?? ""
        website = data["website"] as? String ?? ""
        address = nil
        company = nil
    }
}

struct Address {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let location: Location
}

struct Location {
    let lat: Double
    let lng: Double
}

struct Company {
    let name: String
    let catchPhrase: String
    let bs: String
}
