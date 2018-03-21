//
//  CommunicationManagerSM.swift
//  CommunicationManager
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol CommunicationDelegate {
    func peersUpdated()
    func connectionEstablished()
    func connectionFailed()
    func receivedInvitation(from peer: String)
}

public class CommunicationManagerSM {
    public static let sharedInstance = CommunicationManagerSM()
    var connection = ConnectionData.sharedInstance
    public var delegate:CommunicationDelegate?
    
    var state: CommunicationStateProtocol?
    
    public var peers = [MCPeerID]()
    
    func addPeer(_ peer:MCPeerID) {
        if !peers.contains(peer) {
            peers.append(peer)
            
            if let delegate = delegate {
                delegate.peersUpdated()
            }
        }
    }
    
    func deletePeer(_ peer:MCPeerID) {
        if let index = peers.index(of: peer) {
            peers.remove(at: index)
            
            if let delegate = delegate {
                delegate.peersUpdated()
            }
        }
    }
    
    private init() {
        self.state = Disconnected()
    }
    
    public func connect(to index:Int) {
        let peer = peers[index]
        if let state_new = state!.connect!(to: peer) {
            state = state_new
            print("[Communication Manager] INFO: Connection to \(peer) established")
            delegate?.connectionEstablished()
        } else {
            print("[Communication Manager] INFO: Connection to \(peer) failed")
            delegate?.connectionFailed()
        }
    }
    
    public func cancel() {
        state?.cancel!()
    }
    
    public func accept() {
        state?.accept!()
    }
    
    func disconnected() {
        state = Disconnected()
        
        if let delegate = delegate {
            delegate.connectionFailed()
        }
    }
    
    //TODO: delegate machen
    func connectedToSession() {
        //state = Connected()
        state = BluetoothPeripheral()
        delegate?.connectionEstablished()
    }
    
    func receivedInvitation(from peer:MCPeerID) {
        if let delegate = delegate {
            delegate.receivedInvitation(from: peer.displayName)
        }
    }
    
    func disconntect() -> (Bool, String) {        
        if let state_new = state!.disconnect() {
            state = state_new
            return (true, "Message")
        } else {
            return (false, "Message")
        }
    }
    
    public func send(data: Data) -> (Bool, String) {
        //TODO: check if returning self leads to preservation of the instance
        if let state_new = state!.send(data) {
            state = state_new
            return (true, "Message")
        } else {
            return (false, "Message")
        }
    }
}
