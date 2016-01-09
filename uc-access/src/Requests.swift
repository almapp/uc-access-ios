//
//  Requests.swift
//  uc-access
//
//  Created by Patricio Lopez on 09-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public func request(method: Alamofire.Method, url: String, parameters: [String: AnyObject]? = nil) -> Promise<Response<String, NSError>>{
    return Promise { fulfill, reject in
        Alamofire.request(method, url, parameters: parameters).responseString() { response in
            fulfill(response)
        }
    }
}

