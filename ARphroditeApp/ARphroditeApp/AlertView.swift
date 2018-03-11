//
//  ConnectionAlert.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 04.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

protocol ControllerCallbackDelegate {
    func cancelAction()
    func acceptAction()
}

class AlertView: UIView, UIGestureRecognizerDelegate {
    
    var ctrlDelegate: ControllerCallbackDelegate?
    
    let screenSize = UIScreen.main.bounds.size
    let alertView = UIView()
    let dialog = UILabel()
    var cancelIconView:UIImageView?
    let cancelImage = UIImage(named: "cancelIcon")
    
    init() {
        super.init(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: screenSize))
        
        // Background Init
        self.backgroundColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 0.8)
        self.alpha = 0.0
        
        // Cancel Icon init
        cancelIconView = UIImageView(image: cancelImage)
        cancelIconView?.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: 130)
        cancelIconView?.alpha = 0.0
        self.addSubview(cancelIconView!)
        
        // Dialogview init
        alertView.bounds = CGRect(x: 0, y: 0, width: 250, height: 150)
        alertView.center = CGPoint(x: screenSize.width*0.5, y: screenSize.height*0.5)
        alertView.layer.cornerRadius = 10
        alertView.layer.borderWidth = 0.5
        alertView.layer.borderColor = UIColor.darkGray.cgColor
        alertView.backgroundColor = UIColor.white
        
        self.addSubview(alertView)

        // Dialogtextbox init
        dialog.bounds = CGRect(x: 0, y: 0, width: 230, height: 130)
        dialog.center = alertView.convert(alertView.center, from: alertView.superview)
        dialog.textAlignment = .center
        dialog.lineBreakMode = .byWordWrapping
        dialog.numberOfLines = 0
        dialog.backgroundColor = UIColor.clear
        dialog.font = UIFont.systemFont(ofSize: 17)
        
        alertView.addSubview(dialog)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
