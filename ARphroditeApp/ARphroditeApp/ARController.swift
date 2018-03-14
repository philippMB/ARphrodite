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

    //let commManager = CommunicationManagerSM.sharedInstance
    
    @IBOutlet weak var previewView: UIImageView!
    
    var camera: CameraOperator? = CameraOperator() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera!.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pic(_ sender: UIButton) {
        camera = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Lobby")
        self.present(controller, animated: true, completion: nil)
    }
}

extension ARController: CameraOperatorDelegate {
    func receivedImage(_ image: UIImage) {
        previewView.image = image
    }
    
    
}
