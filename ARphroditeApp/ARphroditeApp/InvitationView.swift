//
//  InvitationView.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 10.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class InvitationView: AlertView {

    var originalCenter = CGPoint()
    // delta init to 100.0 to avoid nil exception and still enter the right if-statement
    var deltaXCancel:CGFloat = 100.0
    var deltaYCancel:CGFloat = 100.0
    var deltaXAccept:CGFloat = 100.0
    var deltaYAccept:CGFloat = 100.0
    
    var acceptIconView: UIImageView?
    let acceptImage = UIImage(named: "acceptIcon")
    
    init(name: String) {
        super.init()
        
        // Accept Icon init
        acceptIconView = UIImageView(image: acceptImage)
        acceptIconView?.center = CGPoint(x: screenSize.width*0.5, y: screenSize.height - 130)
        acceptIconView?.alpha = 0.0
        self.addSubview(acceptIconView!)
        self.sendSubview(toBack: acceptIconView!)
        
        // Dialog text
        let boldTextAttribute = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let nameString = NSMutableAttributedString(string: name, attributes: boldTextAttribute)
        
        let alertBase = NSMutableAttributedString(string: "ᗋ", attributes: [.foregroundColor : UIColor.red])
        let declineText = NSMutableAttributedString(string: " Abbrechen ")
        let redArrow = NSMutableAttributedString(string: "ᗋ", attributes: [.foregroundColor : UIColor.red])
        alertBase.append(declineText)
        alertBase.append(redArrow)
        
        let alertText = NSMutableAttributedString(string: "\n\nEinladung von ")
        alertText.append(nameString)
        
        let acceptBase = NSMutableAttributedString(string: "\n\nᗊ", attributes: [.foregroundColor : UIColor.green])
        let acceptText = NSMutableAttributedString(string: " Annehmen ")
        let greenArrow = NSMutableAttributedString(string: "ᗊ", attributes: [.foregroundColor : UIColor.green])
        acceptBase.append(acceptText)
        acceptBase.append(greenArrow)
        
        alertBase.append(alertText)
        alertBase.append(acceptBase)
        
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
                deltaXCancel = abs(originalCenter.x + translation.x - (cancelIconView?.center.x)!) 
                deltaYCancel = abs(originalCenter.y + translation.y - (cancelIconView?.center.y)!)
                cancelIconView?.alpha = -0.005 * (deltaXCancel/2 + deltaYCancel) + 1
                let scale = -0.002*(deltaXCancel + deltaYCancel) + 2
                cancelIconView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            } else {
                alertView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                deltaXAccept = abs(originalCenter.x + translation.x - (acceptIconView?.center.x)!) 
                deltaYAccept = abs(originalCenter.y + translation.y - (acceptIconView?.center.y)!)
                acceptIconView?.alpha = -0.005 * (deltaXAccept/2 + deltaYAccept) + 1
                let scale = -0.002*(deltaXAccept + deltaYAccept) + 2
                acceptIconView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            }
        } else if recognizer.state == .ended {
            if deltaYCancel < CGFloat(60.0) && deltaXCancel < CGFloat(60.0) {
                if let delegate = ctrlDelegate {
                    delegate.cancelAction()
                }
            } else if deltaYAccept < CGFloat(60.0) && deltaXAccept < CGFloat(60.0) {
                if let delegate = ctrlDelegate {
                    delegate.acceptAction()
                }
            } else {
                alertView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width*0.5 - alertView.center.x, y: UIScreen.main.bounds.size.height*0.5 - alertView.center.y)
                cancelIconView?.transform = CGAffineTransform(scaleX: (cancelImage?.size.width)!/(cancelIconView?.bounds.width)!, y: (cancelImage?.size.height)!/(cancelIconView?.bounds.height)!)
                cancelIconView?.alpha = 0.0
            }
            
        }
    }
}
