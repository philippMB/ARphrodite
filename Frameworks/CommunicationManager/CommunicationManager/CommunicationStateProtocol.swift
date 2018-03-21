//
//  CommunicationState.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc protocol CommunicationStateProtocol {
    func disconnect() -> CommunicationStateProtocol?
    
    func send(_ data: Data) -> CommunicationStateProtocol?
    
    @objc optional func connect(to peer:MCPeerID) -> CommunicationStateProtocol?
    
    @objc optional func cancel()
    
    @objc optional func accept()
}

class CommunicationState: NSObject {
    let discoverServiceType = "discovery"
    var session:MCSession
    
    override init() {
        session = ConnectionData.sharedInstance.session
    }
}
