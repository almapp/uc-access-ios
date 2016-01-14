//
//  Labmat.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit


public class Labmat: Service {
    public static let ID = "LABMAT"
    private static let URL = "http://www.labmat.puc.cl/index.php"
    
    private let user: String
    private let password: String
    
    init(user: String, password: String) {
        self.user = user
        self.password = password
        
        super.init(name: "Labmat", urls: URLs(
            basic:  "http://www.labmat.puc.cl/",
            logged: "http://www.labmat.puc.cl/?app=labmat",
            failed: "http://www.labmat.puc.cl/"
        ))
        self.domain = "www.labmat.puc.cl"
    }
    
    override func login() -> Promise<[NSHTTPCookie]> {
        let params: [String: String] = [
            "accion": "ingreso",
            "usuario": self.user,
            "clave": self.password,
        ]
        return Request.GET(self.urls.basic)
            .then { response -> Promise<Response<String, NSError>> in
                self.addCookies(response.response!)
                return Request.POST(Labmat.URL, parameters: params, headers: NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies))
            }
            .then { response -> [NSHTTPCookie] in
                return self.cookies
            }
    }
    
    override func validate(request: NSURLRequest) -> Bool {
        if let headers = request.allHTTPHeaderFields {
            return Service.hasCookie("LABMAT_USUARIO", header: headers)
        } else {
            return false
        }
    }
}
