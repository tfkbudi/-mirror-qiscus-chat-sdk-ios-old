//
//  ViewController.swift
//  Example
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        QiscusCore.setup(WithAppID: "sampleapp-65ghcsaysse")
        QiscusCore.enableDebugPrint = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickLogin(_ sender: Any) {
        QiscusCore.connect(userID: "amsibsan", userKey: "12345678") { (user, error) in
            print("result:: \(user!)")
//            QiscusCore.networkManager.getRoomList(page: 1, completion: { (room, meta, error) in
//                print("result room:: \(room) \nmeta:: \(meta)")
//            })
        }
    }
    

}

