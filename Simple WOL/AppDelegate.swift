//
//  AppDelegate.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 31.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ViewControllerProtocol {

    var window: UIWindow?
    let awakeHandler = AwakeHandler()
    var tableViewController: TableViewController?
    var editViewController: EditViewController?
    var configuration = Configuration()
    
    //helper function to set tableViewController reference
    func getTableViewControler() -> TableViewController? {
        if let viewControllers = window?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if viewController is TableViewController {
                    return viewController as? TableViewController
                }
            }
        }
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //collect view controllers together
        tableViewController = getTableViewControler()
        editViewController = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "Edit") as? EditViewController

        //connect protocols
        tableViewController?.setProtocols(configuration: configuration, buttonDelegate: awakeHandler, switchViews: self)
        editViewController?.setProtocols(switchViews: self)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {

    func switchTo(viewController: ViewController, element: Element?, newElement:  Bool) {
        if viewController == .EditView {
            if let vc = editViewController {
                vc.setElementToEdit(element: element, newElement: newElement)
                window?.rootViewController?.present(vc, animated:true, completion:nil)
            }
        } else if viewController == .TableView {
            if let vc = tableViewController {
                if let element = element {
                    vc.editOrNewElement(newElement: element)
                }
                window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }

}

