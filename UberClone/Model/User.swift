//
//  User.swift
//  UberClone
//
//  Created by Juan Souza on 25/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import CoreLocation

enum AccountType: Int{
    case passenger
    case driver
}

struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    var uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)!
        }
    }
}
