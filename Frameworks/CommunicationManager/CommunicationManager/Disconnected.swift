//
//  Disconnected.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Disconnected: CommunicationState, CommunicationStateProtocol {    
    var invitedPeer:MCPeerID?
    var invitingPeer:MCPeerID?
    var serviceAdvertiser:MCNearbyServiceAdvertiser?
    var serviceBrowser:MCNearbyServiceBrowser?
    var acceptInvitation = false
    
    let connectionWait = DispatchGroup()
    
    override init() {
        super.init()

        if let advertiser = ConnectionData.sharedInstance.serviceAdvertiser {
            self.serviceAdvertiser = advertiser
        } else {
            ConnectionData.sharedInstance.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: ConnectionData.sharedInstance.myID, discoveryInfo: nil, serviceType: discoverServiceType)
            self.serviceAdvertiser = ConnectionData.sharedInstance.serviceAdvertiser
        }
        
        if let browser = ConnectionData.sharedInstance.serviceBrowser {
            self.serviceBrowser = browser
        } else {
            ConnectionData.sharedInstance.serviceBrowser = MCNearbyServiceBrowser(peer: ConnectionData.sharedInstance.myID, serviceType: discoverServiceType)
            self.serviceBrowser = ConnectionData.sharedInstance.serviceBrowser
        }
                
        self.serviceAdvertiser?.delegate = self
        print("[Communication Manager] INFO: Starting advertising...")
        self.serviceAdvertiser?.startAdvertisingPeer()
        
        self.serviceBrowser?.delegate = self
        print("[Communication Manager] INFO: Starting browsing...")
        self.serviceBrowser?.startBrowsingForPeers()
        
        self.session.delegate = self
    }
    
    deinit {
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
    }

    func connect(to peer:MCPeerID) -> CommunicationStateProtocol? {
        invitedPeer = peer
        serviceBrowser?.invitePeer(peer, to: self.session, withContext: nil, timeout: 30)
        connectionWait.enter()
        connectionWait.wait()
        if self.session.connectedPeers.contains(invitedPeer!) {
            return Connected()
        } else  {
            invitedPeer = nil
            return nil
        }
    }
    
    func cancel() {
        acceptInvitation = false
        connectionWait.leave()
    }
    
    func accept() {
        acceptInvitation = true
        connectionWait.leave()
    }
    
    func disconnect() -> CommunicationStateProtocol? {
        return Disconnected()
    }
    
    func send(_ data: Data) -> CommunicationStateProtocol? {
        return Disconnected()
    }
}

extension Disconnected: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("[Communication Manager] ERROR: Did not start advertising: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        CommunicationManagerSM.sharedInstance.receivedInvitation(from: peerID)
        DispatchQueue.global().async {
            self.connectionWait.enter()
            self.connectionWait.wait()
            invitationHandler(self.acceptInvitation, self.session)
            if self.acceptInvitation {
                self.invitingPeer = peerID
            }
        }
        
    }
}

extension Disconnected: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("[Communication Manager] ERROR: Did not start browsing: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        CommunicationManagerSM.sharedInstance.addPeer(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        CommunicationManagerSM.sharedInstance.deletePeer(peerID)
    }
}

extension Disconnected: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if let invited = invitedPeer {
            if state == .connected && peerID == invited {
                print("[Communication Manager] INFO: \(peerID) accepted connection")
                connectionWait.leave()
            } else if state == .notConnected && peerID == invited {
                print("[Communication Manager] INFO: \(peerID) declined connection")
                connectionWait.leave()
            } else {
                print("[Communication Manager] INFO: Received unexpected message from \(peerID)")
            }
        } else if let inviting = invitingPeer {
            if state == .connected && peerID == inviting {
                print("[Communication Manager] INFO: \(peerID) accepted connection")
                CommunicationManagerSM.sharedInstance.connectedToSession()
            } else if state == .notConnected && peerID == inviting {
                print("[Communication Manager] INFO: \(peerID) declined connection")
                //TODO: invited, but not connected (any more)
            } else {
                print("[Communication Manager] INFO: Received unexpected message from \(peerID)")
            }
        } else if state == .connected{
            print("[Communication Manager] INFO: Received unexpected message from \(peerID)")
            session.disconnect()
        } else {
            print("[Communication Manager] INFO: Received unexpected message \(state) from \(peerID)")
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
