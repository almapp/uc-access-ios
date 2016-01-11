//
//  DetailViewController.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import DZNWebViewController

class DetailViewController: DZNWebViewController {

    var service: Service?

    init(service: Service, configuration: WKWebViewConfiguration? = nil) {
        if let config = configuration {
            super.init(URL: NSURL(string: service.urls.basic), configuration: config)
        } else {
            super.init(URL: NSURL(string: service.urls.basic))
        }
        self.service = service
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.login()
    }

    func request(url: String, cookies: [NSHTTPCookie]) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        return request
    }

    func login() {
        if let service = self.service as? AuthService {
            self.webView.loadRequest(self.request(service.urls.logged, cookies: service.cookies))
        }
    }
}
