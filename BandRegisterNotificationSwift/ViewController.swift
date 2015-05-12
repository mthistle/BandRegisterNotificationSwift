//
//  ViewController.swift
//  BandRegisterNotificationSwift
//
//  Created by Mark Thistle on 4/21/15.
//  Copyright (c) 2015 New Thistle LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MSBClientManagerDelegate {

    @IBOutlet weak var txtOutput: UITextView!
    weak var client: MSBClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MSBClientManager.sharedManager().delegate = self
        if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
            self.client = client
            MSBClientManager.sharedManager().connectClient(self.client)
            self.output("Please wait. Connecting to Band...")
        } else {
            self.output("Failed! No Bands attached.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runExampleCode(sender: AnyObject) {
        if let client = self.client {
            if client.isDeviceConnected == false {
                self.output("Band is not connected. Please wait....")
                return
            }
            self.output("Creating C tile...")
            let tileName = "C tile"
            let tileIcon = MSBIcon(UIImage: UIImage(named: "C.png"), error: nil)
            let smallIcon = MSBIcon(UIImage: UIImage(named: "Cc.png"), error: nil)
            let tileID = NSUUID(UUIDString: "CCCDBA9F-12FD-47A5-83A9-E7270A43BB99")
            var tile = MSBTile(id: tileID, name: tileName, tileIcon: tileIcon, smallIcon: smallIcon, error: nil)
            tile.badgingEnabled = true
            
            client.tileManager.addTile(tile, completionHandler: { (error: NSError!) in
                if error == nil || MSBErrorType(rawValue: error.code) == MSBErrorType.TileAlreadyExist {
                    self.output("Registering Notification....")
                    
                    client.notificationManager.registerNotificationWithCompletionHandler({ (error: NSError!) in
                        if error != nil {
                            self.output(error.description)
                            return
                        }
                        
                        self.output("Creating local notification....")
                        
                        var itemDate = NSDate()
                        
                        var localNotification = UILocalNotification()
                        
                        localNotification.fireDate = itemDate.dateByAddingTimeInterval(20)
                        localNotification.timeZone = NSTimeZone.defaultTimeZone()
                        
                        localNotification.alertBody = "Local notification."
                        localNotification.alertAction = "View Details"
                        
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        
                        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                        
                        self.output("Notification sent successfully!!! \nPlease open C tile and verify the notification. \nYou can remove the tile via Microsoft Health App.")
                    })
                } else {
                    self.output(error.localizedDescription)
                }
            })
        } else {
            self.output("Band is not connected. Please wait....")
        }
    }
    
    func output(message: String) {
        self.txtOutput.text = NSString(format: "%@\n%@", self.txtOutput.text, message) as String
        let p = self.txtOutput.contentOffset
        self.txtOutput.setContentOffset(p, animated: false)
        self.txtOutput.scrollRangeToVisible(NSMakeRange(self.txtOutput.text.lengthOfBytesUsingEncoding(NSASCIIStringEncoding), 0))
    }
    
    // Mark - Client Manager Delegates
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        self.output("Band connected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        self.output(")Band disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        self.output("Failed to connect to Band.")
        self.output(error.description)
    }

}

