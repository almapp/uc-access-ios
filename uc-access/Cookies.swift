//
//  Cookies.swift
//  uc-access
//
//  Created by Patricio Lopez on 09-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation

class Cookies {
    static func activate() -> Void {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
    }
    
    static func set(cookies: [NSHTTPCookie]) {
        cookies.forEach(NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie)
    }
}