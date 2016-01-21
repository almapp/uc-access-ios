//
//  AppDelegate.swift
//  uc-access
//
//  Created by Patricio Lopez on 08-01-16.
//  Copyright © 2016 Almapp. All rights reserved.
//

import UIKit
import DZNWebViewController
import ChameleonFramework

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        if splitViewController.collapsed {
            let navigation = UINavigationController(rootViewController: vc)
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cerrar", style: .Plain, target: vc, action: Selector("dismiss"))
            self.masterController!.presentViewController(navigation, animated: true, completion: nil)
        } else {
            let navigation = splitViewController.viewControllers[1] as! UINavigationController
            navigation.viewControllers = [vc]
        }
        // We handled it
        return true
    }
    
    func targetDisplayModeForActionInSplitViewController(svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if svc.displayMode == .PrimaryOverlay || svc.displayMode == .PrimaryHidden {
            return UISplitViewControllerDisplayMode.AllVisible
        } else {
            return UISplitViewControllerDisplayMode.PrimaryHidden
        }
    }
}

extension AppDelegate: WebPagePresenter {

    func present(webpage: WebPage, withUser user: User? = nil) {
        if let session = user, service = self.service(webpage, user: session) {
            if let cached = self.getCachedView(service, user: session) {
                self.presentDetail(cached)
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                service.login()
                    .then { cookies -> Void in
                        let view = DetailViewController.init(service: service, configuration: BrowserHelper.setup(service))
                        self.setCachedView(service, user: session, view: view)
                        self.presentDetail(view)
                    }.error { error in
                        // This is not working
                        print(error)
                    }
            }
        } else {
            // Normal webpage
            self.presentDetail(DetailViewController.init(webpage: webpage))
        }
    }

    func presentDetail(controller: UIViewController) {
        controller.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem()
        self.splitViewController!.showDetailViewController(controller, sender: self)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var splitViewController: UISplitViewController?
    var masterController: UITabBarController?
    var detailController: UINavigationController?

    var users: [User] = []
    var viewCache: [String: DetailViewController] = [:]
    
    func setCachedView(service: Service, user: User?, view: DetailViewController) {
        let key = self.hash(service, user: user)
        self.viewCache[key] = view
    }
    
    func getCachedView(service: Service, user: User?) -> DetailViewController? {
        let key = self.hash(service, user: user)
        return self.viewCache[key]
    }

    func hash(service: Service, user: User?) -> String {
        return "\(service.name)-\(user?.username)"
    }

    // Sugar getters
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

        // Setup SplitView as root view
        self.splitViewController = UISplitViewController()
        self.splitViewController!.preferredDisplayMode = .AllVisible
        
        // Create the detail view
        self.detailController = UINavigationController()
        
        // Add views to split view controller
        self.splitViewController?.viewControllers = [self.masterController!, self.detailController!]
        
        // Delegate
        self.splitViewController!.delegate = self
        
        self.window?.rootViewController = self.splitViewController
        
        // Present default detail
        if self.splitViewController!.collapsed {
            let initial = WebPage(id: nil, name: "", description: "", URL: "http://www.uc.cl", imageURL: "")
            self.present(initial)
        }

        // Style
        // let colors = ColorSchemeOf(ColorScheme.Analogous, color: FlatBrown(), isFlatScheme: true)
        self.window!.tintColor = FlatBrown()
        // UINavigationBar.appearance().backgroundColor = FlatSand()
        // UIBarButtonItem.appearance().tintColor = FlatBrownDark()
        // UITabBar.appearance().tintColor = FlatBrownDark()
        // UISegmentedControl.appearance().tintColor = FlatBrown()
        
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        self.viewCache.removeAll()
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

