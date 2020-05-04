//
//  CategoryImage.swift
//  JobIn24
//
//  Created by MacUser on 10/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class CategoryImage: UIView {
    
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
        shape.path = UIBezierPath(arcCenter: CGPoint(x: 30, y: 30), radius: CGFloat(30), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
        
    }
}
