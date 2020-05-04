//
//  UILabelPadding.swift
//  JobIn24
//
//  Created by MacUser on 09/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class UILabelPadding: UILabel {

    let padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }

}
