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
            (result) in print(result)
            }, onError:  {})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

