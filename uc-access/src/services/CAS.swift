//
//  CAS.swift
//  uc-access
//
//  Created by Patricio Lopez on 11-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Kanna

enum Error: ErrorType {
    case CouldNotLogin()
}

public class CAS: Service {
    private static let URL = "https://sso.uc.cl/cas/login"

    private let user: String
    private let password: String

    init(user: String, password: String, name: String, urls: URLs) {
        self.user = user
        self.password = password

        super.init(name: name, urls: urls)
        self.domain = "sso.uc.cl"
    }

    override func login() -> Promise<[NSHTTPCookie]> {
        return Request.GET(CAS.URL)
                .then { (response, data) -> Promise<(NSHTTPURLResponse, NSData)> in
                    // Add cookies
                    self.addCookies(response)
                    
                    // Scrap HTML to find POST parameters
                    if let html = String(data: data, encoding: NSUTF8StringEncoding), doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        if let form = doc.at_css("#fm1") {
                            // Prepare form
                            let params: [String: String] = [
                                "username": self.user,
                                "password": self.password,
                                "lt": form.at_css("input[name='lt']")?["value"] ?? "",
                                "execution": form.at_css("input[name='execution']")?["value"] ?? "",
                                "_eventId": form.at_css("input[name='_eventId']")?["value"] ?? "",
                            ]
                            // Perform login request
                            return Request.POST(CAS.URL, parameters: params, headers: NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies))
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

    override func validate(request: NSURLRequest) -> Bool {
        if let headers = request.allHTTPHeaderFields {
            return Service.hasCookie("JSESSIONID", header: headers)
        } else {
            return false
        }
    }
}
