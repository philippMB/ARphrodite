//
//  ViewController.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import CommunicationManager
import XCorrelation

class ViewController: UIViewController {
        
    @IBOutlet weak var browsingView: UITableView!
    
    var connectionAlert:AlertView?
    let commManager = CommunicationManagerSM.sharedInstance
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "Background")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        commManager.delegate = self
        
        browsingView.dataSource = self
        browsingView.delegate = self
        browsingView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        browsingView.backgroundColor = UIColor.clear
        browsingView.alwaysBounceVertical = false
        browsingView.separatorStyle = .none
        browsingView.rowHeight = 60.0
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: CommunicationDelegate {
    func receivedInvitation(from peer: String) {
        connectionAlert = InvitationView(name: peer)
        connectionAlert?.delegate = self
        self.view.addSubview(connectionAlert!)
        self.view.bringSubview(toFront: connectionAlert!)
        UIView.animate(withDuration: 0.1, animations: {
            self.connectionAlert!.alpha = 1.0
        })
    }
    
    func connectionEstablished() {
        DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            self.connectionAlert?.removeFromSuperview()
            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func connectionFailed() {
        DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            
            self.connectionAlert?.removeFromSuperview()
        }
    }
    
    func peersUpdated() {
        self.browsingView.reloadData()
    }
}

extension ViewController: ControllerCallbackDelegate {
    func acceptAction() {
        self.commManager.accept()
    }
    
    func cancelAction() {
        self.commManager.cancel()
        DispatchQueue.main.async {
            self.connectionAlert?.removeFromSuperview()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commManager.peers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let peer = commManager.peers[indexPath.row]
        cell.textLabel?.text = peer.displayName
        cell.textLabel?.backgroundColor = UIColor.clear
        return cell
    }
    
    func colorForIndex(_ index: Int) -> UIColor {
        let itemCount = commManager.peers.count
        let value = 0.95 - (CGFloat(index) / CGFloat(itemCount)) * 0.1
        return UIColor(red: value, green: value, blue: value, alpha: 0.7)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let peerName = tableView.cellForRow(at: indexPath)?.textLabel?.text! {
            connectionAlert = CancelView(name: peerName)
        } else {
            connectionAlert = CancelView(name: "Partner")
        }
        DispatchQueue.global().async {
            self.commManager.connect(to: indexPath[1])
        }
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        connectionAlert?.delegate = self
        self.view.addSubview(connectionAlert!)
        self.view.bringSubview(toFront: connectionAlert!)
        UIView.animate(withDuration: 0.1, animations: {
            self.connectionAlert!.alpha = 1.0
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = UIColor.clear
        headerView.font = UIFont.boldSystemFont(ofSize: 20)
        headerView.text = "Spielersuche"
        headerView.textAlignment = .center
        
        return headerView
    }
}
