//
//  AppDelegate.swift
//  MessageExchamge
//
//  Created by Backlin,Gene on 5/7/18.
//  Copyright © 2018 Chamberlain. All rights reserved.
//

import UIKit
import WatchConnectivity

let NotificationMessageSentFromiPhone = "MessageSentFromiPhone"
let NotificationMessageSentFromWatch = "MessageSentFromWatch"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupWatchConnectivity()
        setupNotificationCenter()

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

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            print("setupWatchConnectivity: iPhone")
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationMessageSentFromiPhone), object: nil, queue: nil) { (notification:Notification) -> Void in
            self.sendMessageToToWatch(notification)
        }
    }

    func sendMessageToToWatch(_ notification: Notification) {
        if WCSession.isSupported() {
            if let message = Message.sharedInstance.messageFromiPhone {
                let session = WCSession.default
                if session.isWatchAppInstalled {
                    do {
                        let dictionary = ["message": message]
                        try session.updateApplicationContext(dictionary)
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }
        }
    }

}

extension AppDelegate: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC Session did deactivate")
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let responseFromWatch = applicationContext["message"] {
            Message.sharedInstance.messageFromWatch = responseFromWatch
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: NotificationMessageSentFromWatch), object: nil)
            }
        }
    }

}

