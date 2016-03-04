//
//  ViewController.swift
//  APItests
//
//  Created by Andre Oriani on 3/1/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        BarcodeService.sharedInstance.getByUPC("071921008291", onSuccess: {
            (result) in /*print(result)*/
            }, onError:  {})
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)
        
        super.viewDidAppear(animated)
        
        let localNotif = UILocalNotification()
        localNotif.alertTitle = "Food about to expire"
        localNotif.alertBody = "Your bacon will rotten"
        localNotif.alertAction = "Report comsuption"
        localNotif.hasAction = true
        localNotif.fireDate = NSDate(timeIntervalSinceNow: 5*60)
        localNotif.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timeout", userInfo: nil, repeats: false)
    }
    
    
    func timeout() {
        exit(0)
    }


}

