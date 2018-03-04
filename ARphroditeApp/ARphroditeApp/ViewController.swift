//
//  ViewController.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 28.02.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import CommunicationManager

class ViewController: UIViewController {
    
    @IBOutlet weak var browsingView: UITableView!
    
    var connectionAlert:ConnectionAlert?
    let commManager = CommunicationManagerSM.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commManager.delegate = self
        
        browsingView.dataSource = self
        browsingView.delegate = self
        browsingView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    func peersUpdated() {
        self.browsingView.reloadData()
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
        return UIColor(red: value, green: value, blue: value, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Schön machen
        connectionAlert = ConnectionAlert(name: ((tableView.cellForRow(at: indexPath)?.textLabel)?.text!)!)
        self.view.addSubview(connectionAlert!)
        self.view.bringSubview(toFront: connectionAlert!)
        UIView.animate(withDuration: 0.15, animations: {
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
