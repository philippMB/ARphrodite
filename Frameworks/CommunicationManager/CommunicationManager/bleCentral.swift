//
//  bleHost.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 15.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothCentral: BluetoothBase {
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    var bytesBuffer = 0
    
    override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothCentral: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("[Communication Manager] ERROR: Bluetooth not turned on.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        let peerID = session.connectedPeers[0].displayName
        
        if let partner = device, partner.contains(peerID) {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            MAX_SIZE = peripheral.maximumWriteValueLength(for: .withResponse)
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([BEAN_SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //TODO: return to disconnected
        print("Peripheral disconnected \(String(describing: error))")
        CommunicationManagerSM.sharedInstance.disconnected()
    }
    
}

extension BluetoothCentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            
            if service.uuid == self.BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        } 
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == self.BEAN_SCRATCH_UUID {
                self.characteristic = characteristic
                self.peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    //receive data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BEAN_SCRATCH_UUID {
            if let data = characteristic.value {
                //TODO: handle data
                let string = String(data: data, encoding: .utf8)
                print(string!)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            let newError = error as? CBATTError
            if let myerror = newError, myerror.code == CBATTError.unlikelyError {
                dataBuffer = nil
                bytesSent = 0
            } else {
                sendData(dataBuffer!)
            }
        } else {
            bytesSent += bytesBuffer
            sendData(dataBuffer!)
        }
    }
}

extension BluetoothCentral: CommunicationStateProtocol {
    func disconnect() -> CommunicationStateProtocol? {
        manager.cancelPeripheralConnection(peripheral)
        return Disconnected()
    }
    
    func send(_ data: Data) -> CommunicationStateProtocol? {
        if dataBuffer == nil {
            dataBuffer = data
            sendData(dataBuffer!)
        }
        
        return self
    }
    
    func sendData(_ data: Data) {
        let data = data as NSData
        var bytesLeft: Int
        
        bytesLeft = data.length - bytesSent
        
        if bytesLeft > MAX_SIZE {
            
            let chunk = NSData(bytes: data.bytes + bytesSent, length: MAX_SIZE)
            
            bytesBuffer = MAX_SIZE
            peripheral.writeValue(chunk as Data, for: self.characteristic, type: .withResponse)
        } else if bytesLeft > 0 {
            let chunk = NSData(bytes: data.bytes + bytesSent, length: bytesLeft)
            
            bytesBuffer = bytesLeft
            
            peripheral.writeValue(chunk as Data, for: self.characteristic, type: .withResponse)
        } else {
            let eom = "EOM".data(using: .utf8)
            peripheral.writeValue(eom!, for: self.characteristic, type: .withResponse)
        }
    }
}
