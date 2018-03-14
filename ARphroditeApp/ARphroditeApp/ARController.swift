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
    var camera: CameraOperator? = CameraOperator() 
    
    let queue = DispatchSemaphore(value: 0)
    
    var imageBuffer = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera!.delegate = self
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.popQueue()
        }
        // Do any additional setup after loading the view.
    }
    
    func popQueue() {
        queue.wait()
        if let imageData = UIImagePNGRepresentation(imageBuffer.popLast()!) {
            //TODO: use result?
            commManager.send(data: imageData)
        }
    }
}

extension ARController: CameraOperatorDelegate {
    func receivedImage(_ image: UIImage) {
        imageBuffer.insert(image, at: 0)
        queue.signal()
    }
}

extension ARController: CommunicationDelegate {
    func peersUpdated() {}
    
    func connectionEstablished() {}
    
    func connectionFailed() {
        camera = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Lobby")
        self.present(controller, animated: true, completion: nil)
    }
    
    func receivedInvitation(from peer: String) {}
}
