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
    var webpage: WebPage?

    init(service: Service, configuration: WKWebViewConfiguration) {
        super.init(URL: NSURL(string: service.urls.basic), configuration: configuration)
        self.setup()
        self.service = service
    }

    init(webpage: WebPage) {
        super.init(URL: NSURL(string: webpage.URL))
        self.setup()
        self.webpage = webpage
    }

    func setup() {
        self.supportedWebNavigationTools = .All
        self.supportedWebActions = .DZNWebActionAll
        self.showLoadingProgress = true
        self.allowHistory = true
        self.hideBarsWithGestures = true
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

    func request(url: String, cookies: [NSHTTPCookie] = []) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        return request
    }

    func login() {
        if let service = self.service {
            self.webView.loadRequest(self.request(service.urls.logged, cookies: service.cookies))
        } else if let webpage = self.webpage {
            self.webView.loadRequest(self.request(webpage.URL))
        }
    }
    
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
