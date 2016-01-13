//
//  BrowserHelper.swift
//  uc-access
//
//  Created by Patricio Lopez on 13-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import WebKit

class BrowserHelper {
    static func setup(service: AuthService) -> WKWebViewConfiguration {
        let controller = WKUserContentController()
        let script = WKUserScript(source: service.cookiesJS, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: false)
        controller.addUserScript(script)
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        return config
    }
}
