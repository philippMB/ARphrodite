//
//  CancelView.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 10.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class CancelView: AlertView {
    
    var originalCenter = CGPoint()
    var deltaX:CGFloat?
    var deltaY:CGFloat?
    
    init(name: String) {
        super.init()
        
        // Dialog text
        let boldTextAttribute = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let nameString = NSMutableAttributedString(string: name, attributes: boldTextAttribute)
        
        let textFragment1 = "Verbindung mit "
        let alertText = NSMutableAttributedString(string: textFragment1)
        
        let textFragment2 = " wird hergestellt.\nZum Abbrechen nach oben wischen"
        let alertTextFragment1 = NSMutableAttributedString(string: textFragment2)
        
        alertText.append(nameString)
        alertText.append(alertTextFragment1)

        dialog.attributedText = alertText
        
        // Pan recognizer init
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
                if let delegate = ctrlDelegate {
                    delegate.cancelAction()
                }
            } else {
                alertView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width*0.5 - alertView.center.x, y: UIScreen.main.bounds.size.height*0.5 - alertView.center.y)
                cancelIconView?.transform = CGAffineTransform(scaleX: (cancelImage?.size.width)!/(cancelIconView?.bounds.width)!, y: (cancelImage?.size.height)!/(cancelIconView?.bounds.height)!)
                cancelIconView?.alpha = 0.0
            }
            
        }
    }
}
