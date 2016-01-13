//
//  WebPage.swift
//  uc-access
//
//  Created by Patricio Lopez on 13-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

public struct WebPageCategory {
    let name: String
    let services: [WebPage]
}

public struct WebPageGroup {
    let name: String
    let categories: [WebPageCategory]
}

public class WebPageFetcher {
    var URL: String
    
    init(URL: String) {
        self.URL = URL
    }
    
    func fetch() -> Promise<[WebPageGroup]> {
        return Request.GET(self.URL).then { response -> [WebPageGroup] in
            return JSON(data: response.data!).arrayValue.map { group in
                WebPageGroup(name: group["name"].string!, categories: group["categories"].arrayValue.map { category in
                    WebPageCategory(name: category["name"].string!, services: category["services"].arrayValue.map { service in
                        WebPage.fromJSON(service)
                        })
                    })
            }
        }
    }
}

public struct WebPage {
    var id: String?
    var name: String
    var description: String
    var imageURL: String
    
    static func fromJSON(json: JSON) -> WebPage {
        return WebPage(
            id: nil,
            name: json["name"].string!,
            description: json["description"].string!,
            imageURL: json["image"].string!
        )
    }
}
