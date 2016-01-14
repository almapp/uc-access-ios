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

    init(user: String, password: String) {
        self.user = user
        self.password = password

        super.init(name: "Siding", urls: URLs(
            basic:  "http://www.ing.uc.cl",
            logged: "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml",
            failed: "https://www.ing.uc.cl"
        ))
        self.domain = "intrawww.ing.puc.cl"
    }

    override func login() -> Promise<[NSHTTPCookie]> {
        let params: [String: String] = [
            "login": self.user,
            "passwd": self.password,
            "sw": "",
            "sh": "",
            "cd": "",
        ]
        return Request.POST(Siding.URL, parameters: params)
            .then { response -> [NSHTTPCookie] in
                self.addCookies(response.response!)
                return self.cookies
            }
    }

    override func validate(request: NSURLRequest) -> Bool {
        if let headers = request.allHTTPHeaderFields {
            return Service.hasCookie("PHPSESSID", header: headers)
        } else {
            return false
        }
    }
}
