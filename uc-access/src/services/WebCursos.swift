//
//  WebCursos.swift
//  uc-access
//
//  Created by Patricio Lopez on 11-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Kanna

public class WebCursos: Service {
    public static let ID = "WEBCURSOS"
    private static let URL = "http://webcurso.uc.cl/direct/session"
    
    private let user: String
    private let password: String
    
    init(user: String, password: String) {
        self.user = user
        self.password = password
        
        super.init(name: "Web Cursos UC", urls: URLs(
            basic:  "http://webcurso.uc.cl/portal",
            logged: "http://webcurso.uc.cl/portal",
            failed: "http://webcurso.uc.cl/portal"
            ))
        self.domain = "webcurso.uc.cl"
    }
    
    override func login() -> Promise<[NSHTTPCookie]> {
        let params = [
            "_username": self.user,
            "_password": self.password,
        ]
        return Request.POST(WebCursos.URL, parameters: params)
            .then { (response, _) -> [NSHTTPCookie] in
                self.addCookies(response)
                return self.cookies
            }
    }
}
