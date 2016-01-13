//
//  ServiceCell.swift
//  uc-access
//
//  Created by Patricio Lopez on 09-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import Kingfisher

class ServiceCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var information: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    var webpage: WebPage? {
        didSet {
            self.refresh()
        }
    }
    
    func refresh() {
        if let webpage = self.webpage {
            self.title.text = webpage.name
            self.information.text = webpage.description
            self.icon.kf_setImageWithURL(NSURL(string: webpage.imageURL)!)
        }
    }
}
