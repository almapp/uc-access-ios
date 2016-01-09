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

    var cookies: [NSHTTPCookie]
    
    var service: Service? {
        didSet {
            self.configureView()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.cookies = []
        super.init(coder: aDecoder)
    }

    func request(url: String, cookies: [NSHTTPCookie]) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        return request
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let service = self.service {
            service.login().then { cookies -> Void in
                Cookies.set(cookies)
                self.webView.stopLoading()
                self.webView.loadRequest(self.request(service.urls.logged, cookies: cookies))
            }
        } else {
            self.loadURL(NSURL(string: "http://google.cl"))
        }
    }

    override func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // TODO: reduce complexity
        if let service = self.service {
            if service.validate(navigationAction.request) {
                decisionHandler(WKNavigationActionPolicy.Allow)
            } else {
                webView.loadRequest(service.process(navigationAction.request))
                decisionHandler(WKNavigationActionPolicy.Cancel)
            }
        } else {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
    }
    
    func simple(url: String) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        self.webView.loadRequest(request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
}

extension DetailViewController: ServiceSelectionDelegate {
    func serviceSelected(service: Service) {
        self.service = service
    }
}
