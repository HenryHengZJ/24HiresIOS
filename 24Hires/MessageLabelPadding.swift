//
//  MessageLabelPadding.swift
//  JobIn24
//
//  Created by MacUser on 17/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class MessageLabelPadding: UILabel {

    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize : CGSize {
        get{
            let superContentSize = super.intrinsicContentSize
            let width = superContentSize.width + padding.left + padding.right
            let heigth = superContentSize.height + padding.top + padding.bottom
            return CGSize(width: width, height: heigth)
        }
        
    }

}
