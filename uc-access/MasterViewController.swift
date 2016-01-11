//
//  MasterViewController.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import DZNWebViewController

protocol ServiceSelectionDelegate: class {
    func serviceSelected(service: Service)
}

class MasterViewController: UITableViewController {

    var services = [Service]()
    weak var delegate: ServiceSelectionDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        // Create services
        self.services = [
            Siding(user: "", password: ""),
            Labmat(user: "", password: ""),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell
        cell.service = self.services[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.serviceSelected(self.services[indexPath.row])
    }
}
