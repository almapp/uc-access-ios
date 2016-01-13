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
    func serviceSelected(service: Service) -> Bool
}

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserButton: UIBarButtonItem!

    var services = [Service]()
    weak var delegate: ServiceSelectionDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        // Create services
        self.services = [
            Siding(user: "", password: ""),
            Labmat(user: "@uc.cl", password: ""),
            PortalUC(user: "", password: ""),
            WebCursos(user: "", password: ""),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegates
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Actions
        self.currentUserButton.target = self
        self.currentUserButton.action = Selector("setCurrentUser:")
    }
    
    // MARK: - Buttons
    
    func setCurrentUser(sender: UIBarButtonItem) {

    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell
        cell.service = self.services[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let service = self.services[indexPath.row]
        if let delegate = self.delegate where delegate.serviceSelected(service) {
            // Managed by delegate
        } else {
            // This class must take care
            if let auth = service as? AuthService {
                auth.login().then { cookies -> Void in
                    self.push(DetailViewController.init(service: auth, configuration: BrowserHelper.setup(auth)))
                }
            } else {
                self.push(DetailViewController.init(service: service))
            }
        }
    }
    
    func push(controller: UIViewController) {
        controller.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
