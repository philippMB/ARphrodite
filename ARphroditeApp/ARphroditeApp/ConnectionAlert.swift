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
    let label = UILabel()
    var peerName:String?

    init(name: String) {
        super.init(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: screenSize))
        
        self.backgroundColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 0.8)
        self.alpha = 0.0
        
        alertView.bounds = CGRect(x: 0, y: 0, width: 250, height: 150)
        alertView.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.5)
        alertView.layer.cornerRadius = 10
        alertView.layer.borderWidth = 0.5
        alertView.layer.borderColor = UIColor.darkGray.cgColor
        alertView.backgroundColor = UIColor.white
        
        
        self.addSubview(alertView)
        
        let boldText = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let nameString = NSMutableAttributedString(string: name, attributes: boldText)
        
        let text1 = "Verbindung mit "
        let alert = NSMutableAttributedString(string: text1)
        
        let text2 = " wird hergestellt.\n Zum Abbrechen nach oben wischen"
        let string2 = NSMutableAttributedString(string: text2)
        
        alert.append(nameString)
        alert.append(string2)
        
        label.bounds = CGRect(x: 0, y: 0, width: 230, height: 130)
        label.center = alertView.convert(alertView.center, from: alertView.superview)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 17)
        label.attributedText = alert
        
        alertView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
