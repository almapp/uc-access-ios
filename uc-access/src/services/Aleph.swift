//
//  Aleph.swift
//  uc-access
//
//  Created by Patricio Lopez on 21-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//


import Foundation
import Alamofire
import PromiseKit
import Kanna

public class Aleph: Service {
    public static let ID = "ALEPH"
    private static let URL = "http://aleph.uc.cl/F"
    
    private let user: String
    private let password: String
    
    init(user: String, password: String) {
        self.user = user
        self.password = password
        
        super.init(name: "SIBUC", urls: URLs(
            basic:  "http://aleph.uc.cl",
            logged: "http://aleph.uc.cl",
            failed: "http://aleph.uc.cl/F"
            ))

        self.domain = "aleph.uc.cl"
    }

    override func login() -> Promise<[NSHTTPCookie]> {
        return Request.GET(Aleph.URL)
            .then { (response, data) -> Promise<(NSHTTPURLResponse, NSData)> in
                // Add cookies
                self.addCookies(response)
                
                // Scrap HTML to find POST parameters
                if let html = String(data: data, encoding: NSUTF8StringEncoding), doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    if let form = doc.at_css("form[name='form1']"), url = form["action"] {
                        // Prepare form
                        let params: [String: String] = [
                            "func": "login-session",
                            "login_source": "",
                            "bor_id": self.user,
                            "bor_verification": self.password,
                            "x": "1",
                            "y": "1",
                        ]
                        // Perform login request
                        return Request.POST(url, parameters: params, headers: NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies))
                    }
                }
                // Reject if response could not be parsed
                throw Error.CouldNotLogin()
                
            }.then { (response, data) -> [NSHTTPCookie] in
                // Add cookies
                self.addCookies(response)
                return self.cookies
        }
    }
}
