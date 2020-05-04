//
//  ColorFile.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

extension UIColor{
    class var defaultLightGrey: UIColor{
        let lightGrey = 0xFFD6D6D6 as Int64
        return UIColor.rgb(fromHex: Int(lightGrey))
    }
    
    class func rgb(fromHex: Int) -> UIColor{
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
