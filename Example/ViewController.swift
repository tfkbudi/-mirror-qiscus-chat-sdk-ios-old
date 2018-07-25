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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                QiscusCore.networkManager.updateProfile(displayName: "amsibsan2018", avatarUrl: "") { user, error in
                    print("user result:: \(user!)")
                }
            })
            
        }
        
//        QiscusCore.getNonce { (qNonce, error) in
//            print("result:: \(qNonce)")
//        }
    }
    

}

