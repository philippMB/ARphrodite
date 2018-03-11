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
    var deltaX:CGFloat = 100.0
    var deltaY:CGFloat = 100.0
    
    init(name: String) {
        super.init()
        
        // Dialog text
        let boldTextAttribute = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let nameString = NSMutableAttributedString(string: name, attributes: boldTextAttribute)
        
        let alertBase = NSMutableAttributedString(string: "ᗋ", attributes: [.foregroundColor : UIColor.red])
        let acceptText = NSMutableAttributedString(string: " Abbrechen ")
        let redArrow = NSMutableAttributedString(string: "ᗋ", attributes: [.foregroundColor : UIColor.red])
        alertBase.append(acceptText)
        alertBase.append(redArrow)
        
        let alertText = NSMutableAttributedString(string: "\n\nVerbindung mit ")
        alertText.append(nameString)
        let alertText1 = NSMutableAttributedString(string: " wird hergestellt.")
        alertText.append(alertText1)
        
        alertBase.append(alertText)

        dialog.attributedText = alertBase
        
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
                cancelIconView?.alpha = -0.005 * (deltaX/2 + deltaY) + 1
                let scale = -0.002*(deltaX + deltaY) + 2
                cancelIconView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            }
        } else if recognizer.state == .ended {
            if deltaY < CGFloat(60.0) && deltaX < CGFloat(60.0) {
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
