//
//  SelectableBackgroundButton.swift
//  JobIn24
//
//  Created by MacUser on 23/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class SelectableBackgroundButton: UIButton {

    private struct Constants {
        static let animationDuration: TimeInterval = 0.1
    }
    
    @IBInspectable
    var animatedColorChange: Bool = true
    
    @IBInspectable
    var selectedBgColor: UIColor = UIColor.black.withAlphaComponent(0.1)
    
    @IBInspectable
    var normalBgColor: UIColor = UIColor.clear
    
    override var isSelected: Bool {
        didSet {
            if animatedColorChange {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.backgroundColor = self.isSelected ? self.selectedBgColor : self.normalBgColor
                }
            } else {
                self.backgroundColor = isSelected ? selectedBgColor : normalBgColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if animatedColorChange {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.backgroundColor = self.isHighlighted ? self.selectedBgColor : self.normalBgColor
                }
            } else {
                self.backgroundColor = isHighlighted ? selectedBgColor : normalBgColor
            }
        }
    }

}
