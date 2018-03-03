//
//  ViewController.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import CommunicationManager

class ViewController: UIViewController {
    let commManager = CommunicationManagerSM.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            while true {
                print(self.commManager.peers)
                sleep(2)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

