//
//  ConnectionAlert.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 04.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class ConnectionAlert: UIView, UIGestureRecognizerDelegate {
    let screenSize = UIScreen.main.bounds.size
    let alertView = UIView()
    let label = UILabel()
    var peerName:String?
    let cancelImage = UIImage(named: "cancelIcon")
    var cancelIconView:UIImageView?
    
    var originalCenter = CGPoint()
    var deltaX:CGFloat?
    var deltaY:CGFloat?

    init(name: String) {
        super.init(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: screenSize))
        
        self.backgroundColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 0.8)
        self.alpha = 0.0
        
        cancelIconView = UIImageView(image: cancelImage)
        cancelIconView?.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: 130)
        cancelIconView?.alpha = 0.0
        self.addSubview(cancelIconView!)
        
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
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        recognizer.delegate = self
        self.alertView.addGestureRecognizer(recognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            originalCenter = center
        } else if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            if translation.y < 0 {
                alertView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                deltaX = abs(originalCenter.x + translation.x - (cancelIconView?.center.x)!) 
                deltaY = abs(originalCenter.y + translation.y - (cancelIconView?.center.y)!)
                cancelIconView?.alpha = -0.005 * (deltaX!/2 + deltaY!) + 1
                let scale = -0.002*(deltaX! + deltaY!) + 2
                cancelIconView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            }
        } else if recognizer.state == .ended {
            if deltaY! < CGFloat(60.0) && deltaX! < CGFloat(60.0) {
                print("Cancel")
            } else {
                alertView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width*0.5 - alertView.center.x, y: UIScreen.main.bounds.size.height*0.5 - alertView.center.y)
                cancelIconView?.transform = CGAffineTransform(scaleX: (cancelImage?.size.width)!/(cancelIconView?.bounds.width)!, y: (cancelImage?.size.height)!/(cancelIconView?.bounds.height)!)
                cancelIconView?.alpha = 0.0
            }
            
        }
    }
}
