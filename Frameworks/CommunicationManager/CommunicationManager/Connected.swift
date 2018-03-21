//
//  Connected.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Connected: CommunicationState, CommunicationStateProtocol {
    
    
    override init() {
        super.init()
        
        
        self.session.delegate = self
    }
    
    func disconnect() -> CommunicationStateProtocol? {
        return Disconnected()
    }
    
    func send(_ data: Data) -> CommunicationStateProtocol? {
        do {
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            return self
        } catch let error {
            print("[Communication Manager] ERROR: Failed to send data. \(error)")
            return nil
        }
    }
    
}

extension Connected: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .notConnected {
            session.disconnect()
            CommunicationManagerSM.sharedInstance.disconnected()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //TODO: Daten
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //TODO: Daten
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //TODO: Daten
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //TODO: Daten
    }
}
