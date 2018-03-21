//
//  ConnectionData.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 11.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectionData {
    public static let sharedInstance = ConnectionData()
    var serviceAdvertiser:MCNearbyServiceAdvertiser?
    var serviceBrowser:MCNearbyServiceBrowser?
    
    var myID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    lazy var session: MCSession = {
        // in the case of connection problems, encryption down
        let session = MCSession(peer: self.myID, securityIdentity: nil, encryptionPreference: .required)
        return session
    }()
    
    private init() {}
}
