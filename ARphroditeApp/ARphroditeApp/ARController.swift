//
//  AR Controller.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 12.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import CommunicationManager

class ARController: UIViewController {

    let commManager = CommunicationManagerSM.sharedInstance
    
    
    @IBOutlet weak var previewView: UIImageView!
    let cam = CameraOperator() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pic(_ sender: UIButton) {
        cam.pic(previewView)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
