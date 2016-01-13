//
//  WebCursos.swift
//  uc-access
//
//  Created by Patricio Lopez on 11-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import PromiseKit

class WebCursos: CAS {
    init(user: String, password: String) {
        let url = "http://webcurso.uc.cl/portal"
        super.init(user: user, password: password, name: "Web Cursos UC", urls: URLs(
            basic:  url,
            logged: "https://sso.uc.cl/cas/login?service=http%3A%2F%2Fwebcurso.uc.cl%2Fsakai-login-tool%2Fcontainer",
            failed: url
            ))
    }

//    override func login() -> Promise<[NSHTTPCookie]> {
//        return super.login().then { cookies -> [NSHTTPCookie] in
//            self.cookies = self.cookies.map { cookie in
//                var props = cookie.properties
//                props!["Domain"] = "webcurso.uc.cl"
//                return NSHTTPCookie(properties: props!)!
//            }
//            print(self.cookies)
//            return self.cookies
//        }
//    }
}
