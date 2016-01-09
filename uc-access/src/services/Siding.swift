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

public class Siding: Service {
    private static let URL = "https://intrawww.ing.puc.cl/siding/index.phtml"

    private let user: String
    private let password: String

    public var name: String
    public var cookies: [NSHTTPCookie]
    public var urls: URLs

    init(user: String, password: String) {
        self.name = "Siding"
        self.user = user
        self.password = password
        self.cookies = []
        self.urls = URLs(
            basic:  "http://www.ing.uc.cl",
            logged: "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml",
            failed: "https://www.ing.uc.cl"
        )
    }

    public func login() -> Promise<[NSHTTPCookie]> {
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

    
    public func process(request: NSURLRequest) -> NSURLRequest {
        let req = NSMutableURLRequest(URL: request.URL!)
        let values = NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies)
        if let headers = request.allHTTPHeaderFields {
            req.allHTTPHeaderFields = headers + values
        } else {
            req.allHTTPHeaderFields = values
        }
        return req
    }

    public func validate(request: NSURLRequest) -> Bool {
        if let header = request.allHTTPHeaderFields {
            if let cookies = header["Cookie"] {
                for cookie in cookies.componentsSeparatedByString(";") {
                    for pair in cookie.componentsSeparatedByString(",") {
                        let values = pair.componentsSeparatedByString("=")
                        let key = values[0]
                        let _ = values[1]
                        if key == "PHPSESSID" {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}
