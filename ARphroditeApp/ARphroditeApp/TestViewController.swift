//
//  TestViewController.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 17.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import CommunicationManager

class TestViewController: UIViewController {
    let comm = CommunicationManagerSM.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func press(_ sender: UIButton) {
        let text = "A Hello, World! program is a computer program that outputs or displays Hello, World! to a user. Being a very simple program in most programming languages, it is often used to illustrate the basic syntax of a programming language for a working program.[1] It is often the very first program people write when they are new to a language. The CBATTRequest class represents Attribute Protocol (ATT) read and write requests from remote central devices (represented by CBCentral objects). Remote centrals use these ATT requests to read and write characteristic values on local peripherals (represented by CBPeripheralManager objects). Local peripherals, on the other hand, use the properties of CBATTRequest objects to respond to the read and write requests appropriately, using the respond(to:withResult:) method of the CBPeripheralManager class."
        let data = text.data(using: .utf8)
        comm.send(data: data!)
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
