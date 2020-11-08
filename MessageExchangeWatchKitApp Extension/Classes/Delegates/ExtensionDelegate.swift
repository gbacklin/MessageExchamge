//
//  ExtensionDelegate.swift
//  MessageExchangeWatchKitApp Extension
//
//  Created by Backlin,Gene on 5/7/18.
//  Copyright © 2018 Chamberlain. All rights reserved.
//

import WatchKit
import WatchConnectivity

let NotificationMessageSentFromWatch = "MessageSentFromWatch"

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupWatchConnectivity()
        setupNotificationCenter()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationMessageSentFromWatch), object: nil, queue: nil) { (notification:Notification) -> Void in
            self.sendMessageToiPhone(notification)
        }
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            print("setupWatchConnectivity: Watch")
            let session  = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sendMessageToiPhone(_ notification:Notification) {
        if WCSession.isSupported() {
            if let message = Message.sharedInstance.messageFromWatch {
                do {
                    let dictionary = ["message": message]
                    try WCSession.default.updateApplicationContext(dictionary)
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
}

// MARK: - WCSessionDelegate

extension ExtensionDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let responseFromiPhone = applicationContext["message"] {
            Message.sharedInstance.messageFromiPhone = responseFromiPhone
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(.success)
                WKInterfaceController.reloadRootPageControllers(withNames: ["MessagedReceivedFromPhone"],
                                                                contexts: nil,
                                                                orientation: WKPageOrientation.vertical,
                                                                pageIndex: 0)
            }
        }
    }
    
}
