//
//  PortalUC.swift
//  uc-access
//
//  Created by Patricio Lopez on 11-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation

class PortalUC: CAS {
    init(user: String, password: String) {
        let url = "https://portal.uc.cl"
        super.init(user: user, password: password, name: "Portal UC", urls: URLs(
            basic:  url,
            logged: "https://portal.uc.cl/web/home-community/informacion-academica",
            failed: url
            ))
    }
}
