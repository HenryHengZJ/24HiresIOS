//
//  PhoneNumberView.swift
//  24Hires
//
//  Created by MacUser on 15/05/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class PhoneNumberView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width/2
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = [UIColor(red:103.0/255, green:184.0/255, blue: 237.0/255, alpha:0.71).cgColor,UIColor(red:120.0/255, green:27.0/255, blue:202.0/255, alpha:1.0).cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
        
    }
    
}

