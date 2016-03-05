//
//  ViewController.swift
//  APItests
//
//  Created by Andre Oriani on 3/1/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit
import CloudSight
import UIImage_Categories

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CloudSightQueryDelegate {
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var infoText: UILabel!
    var query: CloudSightQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        BarcodeService.sharedInstance.getByUPC("071921008291", onSuccess: {
            (result) in print(result)
            }, onError:  {})
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        
        CloudSightConnection.sharedInstance().consumerKey = "zyLoq-b0FIdsivIIm8MtHg"
        CloudSightConnection.sharedInstance().consumerSecret = "aH4RFQLr5gqfcOQuKxtNhA"
        
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
    }
    
    
    @IBAction func onCameraPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        pictureImageView.image = image
        sendToCloudSight(image)
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    func sendToCloudSight(image:UIImage) {
        let resizedImage = image.resizedImageWithContentMode(.ScaleAspectFill, bounds: CGSizeMake(1024, 1024), interpolationQuality: .Default)
        let data = UIImageJPEGRepresentation(resizedImage, 0.7)
        query = CloudSightQuery(image: data, atLocation: CGPointMake(0.5, 0.5), withDelegate: self, atPlacemark: nil, withDeviceId: String(UIDevice.currentDevice().identifierForVendor))
        query?.start()
        infoText.text = "querying..."
    }

    func cloudSightQueryDidFinishIdentifying(query: CloudSightQuery!) {
        infoText.text = "\(query.skipReason): \(query.title)"
    }
    func cloudSightQueryDidFinishUploading(query: CloudSightQuery!) {
        infoText.text = "Finish uploading"
    }
    
    func cloudSightQueryDidFail(query: CloudSightQuery!, withError error: NSError!) {
        infoText.text = "Query failed"
    }
}

