//
//  AppDelegate.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import DZNWebViewController

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.service == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return true
    }

    func targetDisplayModeForActionInSplitViewController(svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        return UISplitViewControllerDisplayMode.Automatic
    }
}

extension AppDelegate: WebPagePresenter {

    func present(webpage: WebPage, withUser user: User?) {
        if let session = user, service = self.service(webpage, user: session) {
            service.login().then { cookies -> Void in
                self.presentDetail(DetailViewController.init(service: service, configuration: BrowserHelper.setup(service)))
            }
        } else {
            // Normal webpage
            self.presentDetail(DetailViewController.init(webpage: webpage))
        }
    }

    func presentDetail(controller: UIViewController) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.iPadPresent(controller)
        } else {
            self.iPhonePresent(controller)
        }
    }

    func iPadPresent(controller: UIViewController) {
        if let nav = self.detailController {
            controller.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            nav.viewControllers = [controller]
            UIApplication.sharedApplication().sendAction(controller.navigationItem.leftBarButtonItem!.action, to: controller.navigationItem.leftBarButtonItem!.target, from: nil, forEvent: nil)
        }
    }
    
    func iPhonePresent(controller: UIViewController) {
        if let master = self.masterController {
            let navigation = UINavigationController(rootViewController: controller)
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cerrar", style: .Plain, target: controller, action: Selector("dismiss"))
            // navigation.modalTransitionStyle = .CrossDissolve
            master.presentViewController(navigation, animated: true, completion: nil)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var splitViewController: UISplitViewController?
    var masterController: UITabBarController?
    var detailController: UINavigationController?

    var users: [User] = []
    
    // Sugar getter
    static var instance: AppDelegate {
        get {
            return UIApplication.sharedApplication().delegate as! AppDelegate
        }
    }

    func service(webpage: WebPage, user: User) -> Service? {
        if let id = webpage.id {
            switch id {
            case Siding.ID: return Siding(user: user.username, password: user.password)
            case Labmat.ID: return Labmat(user: user.username, password: user.password)
            case WebCursos.ID: return WebCursos(user: user.username, password: user.password)
            case PortalUC.ID: return PortalUC(user: user.username, password: user.password)
            default: return nil
            }
        }
        return nil
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup data
        self.users = User.loadAll()

        // Setup views
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds) // Not root controller yet

        // This is shared by both devices
        self.masterController = storyboard.instantiateViewControllerWithIdentifier("Master") as? UITabBarController

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Setup SplitView as root view
            self.splitViewController = UISplitViewController()
            self.splitViewController!.delegate = self
            
            // Create the detail view
            self.detailController = UINavigationController()
            
            // Add views to split view controller
            self.splitViewController?.viewControllers = [self.masterController!, self.detailController!]
            self.window?.rootViewController = self.splitViewController
            
            // Present default detail
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.iPadPresent(DZNWebViewController.init(URL: NSURL(string: "http://www.uc.cl")))
            }
        } else {
            // Set the main controller as root view
            self.window!.rootViewController = self.masterController
        }
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        User.save(self.users)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

