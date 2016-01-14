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
import DZNEmptyDataSet

protocol WebPagePresenter: class {
    func present(webpage: WebPage, withUser: User?)
}

extension UISegmentedControl {
    func setSegments(titles: [String]) {
        self.removeAllSegments()
        titles.forEach { title in
            self.insertSegmentWithTitle(title, atIndex: self.numberOfSegments, animated: false)
        }
    }
}

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

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
    
    var user: User? {
        get {
            return AppDelegate.instance.users.filter { $0.selected }.first ?? AppDelegate.instance.users.first
        }
        set (value) {
            if let current = value {
                AppDelegate.instance.users.filter { $0.username != current.username }.forEach { $0.selected = false }
                current.selected = true
            } else {
                AppDelegate.instance.users.forEach { $0.selected = false }
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
        self.delegate = AppDelegate.instance
        
        // Empty table
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;

        // Editing
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        // self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsSelection = true

        // Actions
        self.currentUserButton.target = self
        self.currentUserButton.action = Selector("setCurrentUser:")
        self.segmentedControl.addTarget(self, action: "onSegmentChange:", forControlEvents: .ValueChanged)

        // Pull to refresh
        self.segmentedControl.alpha = 0;
        self.tableView.addPullToRefreshWithAction {
            self.fetch().then { _ -> Void in
                self.tableView.stopPullToRefresh()
                if self.segmentedControl.alpha == 0 {
                    UIView.animateWithDuration(0.3, animations: { self.segmentedControl.alpha = 1 })
                }
            }
        }
        self.tableView.startPullToRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCurrentUser()
    }
    
    func updateCurrentUser() {
        if let user = self.user {
            if user.selected {
                // Active
                self.currentUserButton.title = user.username
            } else {
                // No account selected
                self.currentUserButton.title = "Seleccionar cuenta"
            }
        } else {
            // No available accounts
            self.currentUserButton.title = "Iniciar sesión"
        }
    }

    func fetch() -> Promise<Void> {
        return self.fetcher.fetch().then { groups -> Void in
            let current = self.index
            self.groups = groups
            self.segmentedControl.setSegments(groups.map { $0.name })
            self.index = (current < 0) ? 0 : current // this eventually calls 'self.tableView.reloadData()'
        }
    }

    // MARK: - Buttons
    
    func setCurrentUser(sender: UIBarButtonItem) {
        if let user = self.user {
            self.selectUser(user, options: AppDelegate.instance.users, sender: sender)
        } else {
            self.createNewUser()
        }
    }

    func selectUser(current: User, options: [User], sender: UIBarButtonItem? = nil) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Selecciona cuenta", message: "¿Con cuál quieres iniciar sesión?", preferredStyle: .ActionSheet)
        actionSheetController.modalPresentationStyle = .Popover
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        actionSheetController.addAction(cancelAction)
        
        options.forEach { user in
            let action = UIAlertAction(title: user.username, style: .Default) { action -> Void in
                self.user = user
                self.updateCurrentUser()
            }
            actionSheetController.addAction(action)
        }

        let noneAction: UIAlertAction = UIAlertAction(title: "Ninguno", style: .Destructive) { (_) in
            self.user = nil
            self.updateCurrentUser()
        }
        actionSheetController.addAction(noneAction)

        if let presentator = actionSheetController.popoverPresentationController, view = sender {
            presentator.barButtonItem = view
            presentator.permittedArrowDirections = .Any
            presentator.sourceView = self.view
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func createNewUser() {
        self.presentViewController(UsersViewController.addUserController() { user in
            AppDelegate.instance.users.forEach { $0.selected = false }
            AppDelegate.instance.users.append(user)
            self.updateCurrentUser()
            }, animated: true, completion: nil)

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
                delegate.present(webpage, withUser: self.user)
            }
        }
    }

    // MARK: - Empty Table View
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Actualizando...")
    }
}
