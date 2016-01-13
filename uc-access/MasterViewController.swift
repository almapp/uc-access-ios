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

extension UISegmentedControl {
    func setSegments(titles: [String]) {
        self.removeAllSegments()
        titles.forEach { title in
            self.insertSegmentWithTitle(title, atIndex: self.numberOfSegments, animated: false)
        }
    }
}

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var groups: [WebPageGroup]
    var fetcher: WebPageFetcher
    weak var delegate: ServiceSelectionDelegate?
    
    var index: Int {
        get {
            return self.segmentedControl.selectedSegmentIndex
        }
        set(newIndex) {
            self.segmentedControl.selectedSegmentIndex = newIndex
            self.segmentedControl.sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    var group: WebPageGroup? {
        get {
            if 0 <= self.index && self.index < self.groups.count {
                return self.groups[self.index]
            } else {
                return nil
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        self.fetcher = WebPageFetcher(URL: "https://almapp.github.io/uc-access-assets/services.json")
        self.groups = []
        super.init(coder: aDecoder)!
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
        self.segmentedControl.addTarget(self, action: "onSegmentChange:", forControlEvents: .ValueChanged)
        
        // Fetch data
        self.fetcher.fetch().then { groups -> Void in
            self.groups = groups
            self.segmentedControl.setSegments(groups.map { $0.name })
            self.index = 0
        }
    }

    // MARK: - Buttons
    
    func setCurrentUser(sender: UIBarButtonItem) {

    }

    func onSegmentChange(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.group?.categories.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.group?.categories[section].services.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell
        let webpage = self.group!.categories[indexPath.section].services[indexPath.row]
        cell.webpage = webpage
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let service = self.services[indexPath.row]
//        if let delegate = self.delegate where delegate.serviceSelected(service) {
//            // Managed by delegate
//        } else {
//            // This class must take care
//            if let auth = service as? AuthService {
//                auth.login().then { cookies -> Void in
//                    self.push(DetailViewController.init(service: auth, configuration: BrowserHelper.setup(auth)))
//                }
//            } else {
//                self.push(DetailViewController.init(service: service))
//            }
//        }
    }
    
    func push(controller: UIViewController) {
        controller.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
