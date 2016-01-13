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


public class Service {
    var name: String
    var urls: URLs
    
    init(name: String, urls: URLs) {
        self.name = name
        self.urls = urls
    }
}

public class AuthService: Service {
    var domain: String?
    var cookies: [NSHTTPCookie] = []

    var cookiesJS: String {
        get {
            if let domain = self.domain {
                return cookies.map { "document.cookie = '\($0.name)=\($0.value);path=\($0.path);domain=\(domain)';" }.joinWithSeparator(";")
            } else {
                return cookies.map { "document.cookie = '\($0.name)=\($0.value);path=\($0.path)';" }.joinWithSeparator(";")
            }
        }
    }

    func login() -> Promise<[NSHTTPCookie]> {
        return Promise.init([])
    }

    func request() -> NSURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: self.urls.logged)!)
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies)
        return request
    }

    func validate(request: NSURLRequest) -> Bool {
        return true
    }
    
    func addCookies(response: NSHTTPURLResponse) {
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields as! [String: String], forURL: NSURL(string: self.domain!)!)
        self.cookies.appendContentsOf(cookies)
    }

    static func hasCookie(key: String, header: [String: String]) -> Bool {
        if let cookies = header["Cookie"] {
            for cookie in cookies.componentsSeparatedByString(";") {
                for pair in cookie.componentsSeparatedByString(",") {
                    let values = pair.componentsSeparatedByString("=")
                    if values[0] == key && values[1].characters.count > 0 {
                        return true
                    }
                }
            }
        }
        return false
    }
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
