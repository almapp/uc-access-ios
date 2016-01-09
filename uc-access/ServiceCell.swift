//
//  ServiceCell.swift
//  uc-access
//
//  Created by Patricio Lopez on 09-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit

class ServiceCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    var service: Service? {
        didSet {
            self.refresh()
        }
    }
    
    func refresh() {
        if let service = self.service {
            self.title.text = service.name
        }
    }
}
