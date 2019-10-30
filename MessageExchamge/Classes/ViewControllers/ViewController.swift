//
//  ViewController.swift
//  MessageExchamge
//
//  Created by Backlin,Gene on 5/7/18.
//  Copyright © 2018 Chamberlain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var entryTextField: UITextField!
    @IBOutlet var statusLabel: UILabel!
    
    var notificationObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textLabel.text = "viewDidLoad"
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationMessageSentFromWatch), object: nil, queue: nil) { (notification:Notification) -> Void in
            self.updateDisplay()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func updateDisplay() {
        DispatchQueue.main.async {[weak self] () -> Void in
            if let messageFromWatch = Message.sharedInstance.messageFromWatch {
                self!.textLabel.text = messageFromWatch as? String
                self!.statusLabel.text = "Message received from watch"
            } else {
                self!.statusLabel.text = ""
            }
        }
    }

    @IBAction func sendMessageToWatch(_ sender: UIBarButtonItem) {
        let message = entryTextField.text
        Message.sharedInstance.messageFromiPhone = message
        DispatchQueue.main.async {[weak self] () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationMessageSentFromiPhone), object: message)
            self!.statusLabel.text = "Message sent to watch"
        }
    }
    
}

