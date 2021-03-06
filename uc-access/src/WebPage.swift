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

public class WebPageCategory {
    let name: String
    let detail: String
    var webpages: [WebPage]
    
    init(name: String, detail: String, webpages: [WebPage]) {
        self.name = name
        self.detail = detail
        self.webpages = webpages
    }

    var activeWebpages: [WebPage] {
        get {
            return self.webpages.filter { $0.selected }
        }
    }
}

public class WebPageGroup {
    let name: String
    let detail: String
    var categories: [WebPageCategory]
    
    init(name: String, detail: String, categories: [WebPageCategory]) {
        self.name = name
        self.detail = detail
        self.categories = categories
    }

    var activeCategories: [WebPageCategory] {
        get {
            return self.categories.filter { $0.activeWebpages.count > 0 }
        }
    }
}

public class WebPageFetcher {
    var URL: String
    
    init(URL: String) {
        self.URL = URL
    }
    
    func fetch() -> Promise<[WebPageGroup]> {
        return Request.GET(self.URL).then { (response, data) -> [WebPageGroup] in
            return JSON(data: data).arrayValue.map { group in
                WebPageGroup(name: group["name"].stringValue, detail: group["detail"].stringValue, categories: group["categories"].arrayValue.map { category in
                    WebPageCategory(name: category["name"].stringValue, detail: category["detail"].stringValue, webpages: category["services"].arrayValue.map { service in
                        WebPage.fromJSON(service)
                        })
                    })
            }
        }
    }
}

public class WebPage {
    let id: String?
    let name: String
    let description: String
    let URL: String
    let imageURL: String
    var selected: Bool
    
    init(id: String?, name: String, description: String, URL: String, imageURL: String, selected: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.URL = URL
        self.imageURL = imageURL
        self.selected = true
    }
    
    static func fromJSON(json: JSON) -> WebPage {
        return WebPage(
            id: json["id"].stringValue,
            name: json["name"].stringValue,
            description: json["description"].stringValue,
            URL: json["url"].stringValue,
            imageURL: json["image"].stringValue
        )
    }
}
