//
//  Service.swift
//  uc-access
//
//  Created by Patricio Lopez on 09-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import PromiseKit

public struct URLs {
    let basic: String
    let logged: String
    let failed: String
}

public protocol Service {
    var name: String {get}
    var cookies: [NSHTTPCookie] {get}
    var urls: URLs {get}
    func login() -> Promise<[NSHTTPCookie]>
    func process(request: NSURLRequest) -> NSURLRequest
    func validate(request: NSURLRequest) -> Bool
}

public func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}
