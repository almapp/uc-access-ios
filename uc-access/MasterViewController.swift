//
//  MasterViewController.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import PromiseKit
import DZNWebViewController
import Refresher

protocol WebPagePresenter: class {
    func shouldPresent(webpage: WebPage) -> Bool
    func present(webpage: WebPage)
    func provideServiceFor(webpage: WebPage) -> Service?
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
    weak var delegate: WebPagePresenter?
    
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
        self.fetcher = WebPageFetcher(URL: "https://almapp.github.io/uc-access/services.json")
        self.groups = []
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegates
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Editing
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsSelection = true

        // Actions
        self.currentUserButton.target = self
        self.currentUserButton.action = Selector("setCurrentUser:")
        self.segmentedControl.addTarget(self, action: "onSegmentChange:", forControlEvents: .ValueChanged)
        
        // Pull to refresh
        self.tableView.addPullToRefreshWithAction {
            self.fetch().then {
                self.tableView.stopPullToRefresh()
            }
        }
        self.tableView.startPullToRefresh()
    }

    func fetch() -> Promise<Void> {
        return self.fetcher.fetch().then { groups -> Void in
            let current = self.index
            self.groups = groups
            self.segmentedControl.setSegments(groups.map { $0.name })
            self.index = (current < 0) ? 0 : current // this eventually calls 'self.tableView.reloadData()'
        }
    }
    
    func push(controller: UIViewController) {
        // let nav = UINavigationController(rootViewController: controller)
        controller.hidesBottomBarWhenPushed = true;
        // self.presentViewController(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Buttons
    
    func setCurrentUser(sender: UIBarButtonItem) {

    }

    func onSegmentChange(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            // Enter
        } else {
            // Exit
        }
        self.tableView.setEditing(editing, animated: true)
        self.tableView.reloadData()
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView.editing {
            return self.group?.categories.count ?? 0
        } else {
            return self.group?.activeCategories.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.editing {
            return self.group?.categories[section].name
        } else {
            return self.group?.activeCategories[section].name
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tableView.editing {
            return self.group?.categories[section].detail
        } else {
            return self.group?.activeCategories[section].detail
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.editing {
            return self.group?.categories[section].services.count ?? 0
        } else {
            return self.group?.activeCategories[section].activeServices.count ?? 0
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell

        // Load webpage
        if tableView.editing {
            cell.webpage = self.group!.categories[indexPath.section].services[indexPath.row]
        } else {
            cell.webpage = self.group!.activeCategories[indexPath.section].activeServices[indexPath.row]
        }
        cell.editingAccessoryType = (cell.webpage!.selected) ? .Checkmark : .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ServiceCell, webpage = cell.webpage {
            if tableView.editing {
                webpage.selected = !webpage.selected
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } else if let delegate = self.delegate {
                if delegate.shouldPresent(webpage) {
                    // Managed by delegate
                    delegate.present(webpage)
                } else if let service = delegate.provideServiceFor(webpage) {
                    // This class must take care
                    service.login().then { cookies -> Void in
                        self.push(DetailViewController(service: service, configuration: BrowserHelper.setup(service)))
                    }
                } else {
                    // It's a normal webpage
                    self.push(DetailViewController(webpage: webpage))
                }
            }
        }
    }
}
