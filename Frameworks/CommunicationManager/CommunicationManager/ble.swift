//
//  ble.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 15.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothBase: CommunicationState {
    let BEAN_NAME = UIDevice.current.name + "AR"  
    let BEAN_SCRATCH_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID = CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    var MAX_SIZE: Int!
    var bytesSent = 0
    var dataBuffer: Data?
}
