//
//  UsersViewController.swift
//  uc-access
//
//  Created by Patricio Lopez on 14-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import DZNEmptyDataSet

class UsersViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var users: [User] {
        get {
            return AppDelegate.instance.users
        }
        set(values) {
            AppDelegate.instance.users = values
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Empty table
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        // Actions
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.addButton.target = self
        self.addButton.action = Selector("addUserButtonPress:")
        
        // Setup table
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        self.tableView.reloadData()
    }

    func addUserButtonPress(sender: UIBarButtonItem) {
        self.addUser()
    }
    
    func addUser() {
        self.presentViewController(UsersViewController.addUserController() { user in
            self.users.forEach { $0.selected = false }
            self.users.append(user)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.users.count - 1, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            }, animated: true, completion: {})
    }

    static func addUserController(hanlder: ((User) -> Void)?) -> UIAlertController {
        let alertController = UIAlertController(title: "Ingresa las credenciales 🔑", message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (_) in
            if let callback = hanlder {
                let username = alertController.textFields![0].text ?? ""
                let password = alertController.textFields![1].text ?? ""
                let user = User(username: username, password: password, selected: true)
                callback(user)
            }
        }
        loginAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Usuario sin @uc.cl"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Contraseña"
            textField.secureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Table View
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.users.count > 0 ? "Cuentas" : nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.users.count > 0 ? "🔐 Las contraseñas están bien guardadas" : nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.users.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            if self.users.count == 0 {
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
            tableView.endUpdates()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.users[indexPath.row].username
        cell.selectionStyle = .None
        return cell
    }
    
    // MARK: - Empty Table View
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "¿Todavía no pones tu cuenta?")
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        self.addUser()
    }
}
