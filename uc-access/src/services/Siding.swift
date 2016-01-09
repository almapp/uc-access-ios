//
//  Siding.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public class Siding {
    private static let URL = "https://intrawww.ing.puc.cl/siding/index.phtml"
    private let user: String
    private let password: String
    public var cookies: [NSHTTPCookie]

    init(user: String, password: String) {
        self.user = user
        self.password = password
        self.cookies = []
    }

    func Login() -> Promise<[NSHTTPCookie]> {
        let params: [String: String] = [
            "login": self.user,
            "passwd": self.password,
            "sw": "",
            "sh": "",
            "cd": "",
        ]
        return request(Alamofire.Method.POST, url: Siding.URL, parameters: params).then { response -> [NSHTTPCookie] in
            self.cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response.response?.allHeaderFields  as! [String: String], forURL: NSURL(string: Siding.URL)!)
            return self.cookies
        }
    }
}
