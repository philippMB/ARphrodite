//
//  PairingView.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 15.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class PairingView: UIView {

    init() {
        let screen = UIScreen.main.bounds
        super.init(frame: CGRect(x: screen.width/2, y: screen.height/2, width: screen.width - 50, height: screen.width + 50))
        
        let image = UIImage(named: "pairingGraphic")
        let pairingImageView = UIImageView(image: image)
        pairingImageView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.width)
        pairingImageView.alpha = 0.85
        
        let pairingLabel = UILabel()
        pairingLabel.frame = CGRect(x: 0.0, y: self.bounds.width, width: self.bounds.width, height: 100)
        pairingLabel.text = "iPhones wie dargestellt auf gewünschtes Spielfeld richten"
        pairingLabel.textColor = UIColor.white
        pairingLabel.textAlignment = .center
        pairingLabel.lineBreakMode = .byWordWrapping
        pairingLabel.numberOfLines = 0
        pairingLabel.backgroundColor = UIColor.clear
        pairingLabel.font = UIFont.boldSystemFont(ofSize: 20)

        self.addSubview(pairingLabel)
        self.addSubview(pairingImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
