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
import AFNetworking

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CloudSightQueryDelegate, BarcodeDelegate {
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var infoText: UILabel!
    var query: CloudSightQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func onBarcodePressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "BarcodeDetector", bundle: nil)
        let barcodePresenter = storyBoard.instantiateViewControllerWithIdentifier(BarcodeDetectorViewController.storyBoardId) as! BarcodeDetectorViewController
        barcodePresenter.delegate = self
        presentViewController(barcodePresenter, animated: true, completion: nil)
    }
    
    func barcodeController(onBarcodeDetected: String) {
        BarcodeService.sharedInstance.getByUPC(onBarcodeDetected, onSuccess: {
            barcodeResult in
            if (barcodeResult.response.data.count > 0 ) {
                self.infoText.text = barcodeResult.response.data[0].brand! + ":" + barcodeResult.response.data[0].product_name!
                self.pictureImageView.setImageWithURL(NSURL(string: barcodeResult.response.data[0].image_urls![0])!)
            }
            }, onError: {})
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
        let desc = query.title
        let matchedFood = matchFood(desc)
        var info = "\(query.skipReason): \(query.title)"
        if (matchedFood.count > 1) {
            let photourl = matchedFood.first!.photoUrl
            let foodName = matchedFood.first!.name
            pictureImageView.setImageWithURL(NSURL(string: photourl)!)
            info += "\nFirst Match: \(foodName)"
        }
        infoText.text = info
    }
    
    func cloudSightQueryDidFail(query: CloudSightQuery!, withError error: NSError!) {
        infoText.text = "Query failed"
    }
    
}

