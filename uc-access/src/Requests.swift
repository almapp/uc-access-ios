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

public typealias HTTPResponse = (NSHTTPURLResponse, NSData)

public class Request {
    public static func POST(url: String, parameters: [String: AnyObject]? = nil, headers: [String : String]? = nil) -> Promise<HTTPResponse> {
        return self.perform(Alamofire.Method.POST, url: url, parameters: parameters, headers: headers)
    }
    
    public static func GET(url: String, parameters: [String: AnyObject]? = nil, headers: [String : String]? = nil) -> Promise<HTTPResponse> {
        return self.perform(Alamofire.Method.GET, url: url, parameters: parameters, headers: headers)
    }
    
    public static func perform(method: Alamofire.Method, url: String, parameters: [String: AnyObject]? = nil, headers: [String : String]? = nil) -> Promise<HTTPResponse> {
        return Promise { fulfill, reject in
            Alamofire.request(method, url, parameters: parameters, encoding: .URL, headers: headers).response { (_, response, data, error) in
                if let err = error{
                    reject(err)
                } else {
                    fulfill((response!, data!))
                }
            }
        }
    }
}
