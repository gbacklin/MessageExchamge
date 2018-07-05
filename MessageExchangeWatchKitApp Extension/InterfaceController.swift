//
//  InterfaceController.swift
//  MessageExchangeWatchKitApp Extension
//
//  Created by Backlin,Gene on 5/7/18.
//  Copyright © 2018 Chamberlain. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var textLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateDisplay()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateDisplay() {
        if let response = Message.sharedInstance.messageFromiPhone {
            textLabel.setText(response as? String)
            WKInterfaceDevice.current().play(.click)
        } else {
            textLabel.setText("")
        }
    }
    
    func sendResponseToiPhone(response: Any) {
        Message.sharedInstance.messageFromWatch = response
        DispatchQueue.main.async { () -> Void in
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: Notification.Name(rawValue: NotificationMessageSentFromWatch), object: nil)
        }
    }

    @IBAction func createResponse() {
        let initialPhrases = ["Hello", "How are you ?", "Are you busy ?"]
        presentTextInputController(withSuggestions: initialPhrases, allowedInputMode: .allowAnimatedEmoji) { (results) in
            if let resultArray = results {
                if resultArray.count > 0 {
                    let response = resultArray[0]
                    self.sendResponseToiPhone(response: response)
                }
            }
        }
    }
    
}
