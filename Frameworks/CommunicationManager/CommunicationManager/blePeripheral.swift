//
//  blePeripheral.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 15.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral: BluetoothBase {
    var central: CBCentral?
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    
    override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension BluetoothPeripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let dataToBeAdvertised:[String: Any] = [
                CBAdvertisementDataLocalNameKey : BEAN_NAME,
                CBAdvertisementDataServiceUUIDsKey : [BEAN_SERVICE_UUID],
                ]
            
            characteristic = CBMutableCharacteristic(type: BEAN_SCRATCH_UUID, properties: [.notify, .write], value: nil, permissions: .writeable)
            let service = CBMutableService(type: BEAN_SERVICE_UUID, primary: true)
            service.characteristics = [characteristic]
            peripheral.add(service)
            peripheral.startAdvertising(dataToBeAdvertised)
        } else {
            print("Bluetooth off")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Service not added \(error)")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Advertising")
    }
    
    // receive data?
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        //TODO: check
        
        let data = String(data: requests[0].value!, encoding: .utf8)
        if let eom = data, eom.contains("EOM") {
            peripheralManager.respond(to: requests[0], withResult: .unlikelyError)
        } else {
            peripheralManager.respond(to: requests[0], withResult: .success)
        }
        
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        if let data = dataBuffer {
            sendData(data)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        peripheralManager.stopAdvertising()
        self.central = central
        MAX_SIZE = central.maximumUpdateValueLength
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.central = nil
        let dataToBeAdvertised:[String: Any] = [
            CBAdvertisementDataLocalNameKey : BEAN_NAME,
            CBAdvertisementDataServiceUUIDsKey : [BEAN_SERVICE_UUID],
            ]
        peripheralManager.startAdvertising(dataToBeAdvertised)
    }
}

extension BluetoothPeripheral: CommunicationStateProtocol {
    func disconnect() -> CommunicationStateProtocol? {
        self.central = nil
        
        return Disconnected()
    }
    
    func send(_ data: Data) -> CommunicationStateProtocol? {
        if dataBuffer == nil {
            dataBuffer = data
            sendData(dataBuffer!)
            
            return self
        }
        return nil
    }
    
    func sendData(_ data: Data) {
        let data = data as NSData
        var bytesLeft: Int
        var result = true
        
        while result {
            bytesLeft = data.length - bytesSent
            
            if bytesLeft > MAX_SIZE {
                
                let chunk = NSData(bytes: data.bytes + bytesSent, length: MAX_SIZE)
                
                result = peripheralManager.updateValue(chunk as Data, for: characteristic, onSubscribedCentrals: nil)
                
                if result {
                    bytesSent += MAX_SIZE
                }
            } else if bytesLeft > 0 {
                let chunk = NSData(bytes: data.bytes + bytesSent, length: bytesLeft)
                
                
                result = peripheralManager.updateValue(chunk as Data, for: characteristic, onSubscribedCentrals: nil)
                
                if result {
                    bytesSent += bytesLeft
                }
            } else {
                let eom = "EOM".data(using: .utf8)
                result = peripheralManager.updateValue(eom!, for: characteristic, onSubscribedCentrals: nil)
                
                if result {
                    dataBuffer = nil
                    bytesSent = 0
                }
            }
        }
    }

}
