//
//  ConnectionAlert.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 04.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class ConnectionAlert: UIView {
    let screenSize = UIScreen.main.bounds.size
    let alertView = UIView()

    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: screenSize))
        
        self.backgroundColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 0.8)
        self.alpha = 0.0
        
        alertView.frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        alertView.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.5)
        alertView.layer.cornerRadius = 10
        alertView.layer.borderWidth = 0.5
        alertView.layer.borderColor = UIColor.darkGray.cgColor
        alertView.backgroundColor = UIColor.white
        self.addSubview(alertView)
        
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
