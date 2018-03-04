//
//  TableViewCell.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 04.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + 5, width: self.bounds.size.width - 20, height: self.bounds.size.height - 10)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            let bgColor = self.backgroundColor
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.8)
                }) { (Bool) -> Void in
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.backgroundColor = bgColor
                }
            )}
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
}
