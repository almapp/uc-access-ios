//
//  User.swift
//  uc-access
//
//  Created by Patricio Lopez on 14-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import KeychainSwift

let keychain = KeychainSwift()
let database = "USERS"

class User: NSObject, NSCoding {
    let username: String
    let password: String
    var selected: Bool

    init(username: String, password: String, selected: Bool = false) {
        self.username = username
        self.password = password
        self.selected = selected
    }

    @objc required init(coder aDecoder: NSCoder) {
        self.username = aDecoder.decodeObjectForKey("username") as? String ?? "Annon"
        self.password = aDecoder.decodeObjectForKey("password") as? String ?? ""
        self.selected = aDecoder.decodeBoolForKey("selected")
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.password, forKey: "password")
        aCoder.encodeBool(self.selected, forKey: "selected")
    }

    static func save(users: [User]) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(users)
        return keychain.set(data, forKey: database)
    }
    
    static func loadAll() -> [User] {
        if let data = keychain.getData(database), users = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [User] {
            return users
        } else {
            return []
        }
    }
}
