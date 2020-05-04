//
//  GradientView.swift
//  JobIn24
//
//  Created by Henry Heng on 8/28/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
//import AVFoundation


class ImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        myGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,  1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}


//var aView = ImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
