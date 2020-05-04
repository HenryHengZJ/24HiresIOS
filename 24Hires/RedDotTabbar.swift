//
//  RedDotTabbar.swift
//  JobIn24
//
//  Created by MacUser on 07/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
   /* func setTabBarDotVisible(visible:Bool,index: Int? = nil) {
        
        let tabBarController:UITabBarController!
        
        if self is UITabBarController
        {
            tabBarController = self as! UITabBarController
        }
        else
        {
            if self.tabBarController == nil
            {
                return
            }
            tabBarController = self.tabBarController!
        }
        
        let indexFinal:Int
        
        if (index != nil)
        {
            indexFinal = index!
        }
        else
        {
            let index3 = tabBarController.viewControllers?.index(of: self)
            
            if index3 == nil
            {
                return;
            }
            else
            {
                indexFinal = index3!
            }
            
        }
        
        guard let barItems = tabBarController.tabBar.items else
        {
            return
        }
        
        //
        
        
        let tag = 8888
        
        var tabBarItemView:UIView?
        
        for subview in tabBarController.tabBar.subviews {
            
            let className = String(describing: type(of: subview))
            
            guard className == "UITabBarButton" else {
                continue
            }
            
            var label:UILabel?
            var dotView:UIView?
            
            for subview2 in subview.subviews {
                
                if subview2.tag == tag {
                    dotView = subview2;
                }
                else if (subview2 is UILabel)
                {
                    label = subview2 as? UILabel
                }
                
            }
            
            
            if label?.text == barItems[indexFinal].title
            {
                dotView?.removeFromSuperview()
                tabBarItemView = subview;
                print("removeFromSuperview")
                break;
            }
        }
        
        if (tabBarItemView == nil || !visible)
        {
            return
        }
        
        
        
        let barItemWidth = tabBarItemView!.bounds.width
        
        let x = barItemWidth * 0.5 + (barItems[indexFinal].selectedImage?.size.width ?? barItemWidth) / 2
        
        print("barItemWidth * 0.5 \(barItemWidth * 0.5)")
        print("x = \(x)")
        print("barItems[indexFinal] \(indexFinal)")
        
        let y:CGFloat = 5
        let size:CGFloat = 10;
        
        let redDot = UIView(frame: CGRect(x: x, y: y, width: size, height: size))
        
        redDot.tag = tag
        redDot.backgroundColor = UIColor.red
        redDot.layer.cornerRadius = size/2
        
        
        tabBarItemView!.addSubview(redDot)
        
    }*/
    
    func addRedDotAtTabBarItemIndex(index: Int, removeindex: Int) {
        
        var tabBarController    : UITabBarController!
        
        if self is UITabBarController{
            
            tabBarController = self as! UITabBarController
        }else{
            if self.tabBarController == nil{
                return
            }
            
            print("else tab bar")
            tabBarController = self.tabBarController!
        }
        
       
        for subview in tabBarController!.tabBar.subviews {
        
            
//          if let subview = subview as? UIView{
            if (removeindex == 1) {
                    if subview.tag == 1 {
                        subview.removeFromSuperview()
                        print("remove 1")
                        break
                    }
            }else if (removeindex == 2) {
                
                if subview.tag == 2 {
                    subview.removeFromSuperview()
                    break
                }
            }else if (removeindex == 3) {

                if subview.tag == 3 {
                    subview.removeFromSuperview()
                    break
                }
            }else if (removeindex == 4) {
                
                if subview.tag == 4 {
                    subview.removeFromSuperview()
                    break
                }
            }
        }
        
        if index == 10 {
            return
        }
        
        let RedDotRadius    : CGFloat   = 5
        let TopMargin       : CGFloat   = 5
        let RedDotDiameter          = RedDotRadius * 2
        let TabBarItemCount         = CGFloat(tabBarController.tabBar.items!.count)
        let HalfItemWidth           = (view.bounds.width) / (TabBarItemCount * 2)
        let  xOffset                = HalfItemWidth * CGFloat(index * 2 + 1)
        
        if ((tabBarController.tabBar.items![index]).selectedImage != nil) {
            let imageHalfWidth: CGFloat = (tabBarController.tabBar.items![index]).selectedImage!.size.width / 2
            
            let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 0.2, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
            
            if (index == 1) {
                 redDot.tag = 1
                
            }else if (index == 2) {
                redDot.tag = 2
                
            }else if (index == 3) {
                redDot.tag = 3
                
            }else if (index == 4) {
                redDot.tag = 4
            }

            redDot.backgroundColor      = UIColor.red
            redDot.layer.cornerRadius   = RedDotRadius
            tabBarController.tabBar.addSubview(redDot)
            
        }else {
            
            let imageHalfWidth: CGFloat = 12.5
            let redDot      = UIView(frame: CGRect(x: xOffset + imageHalfWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
            
            if (index == 1) {
                redDot.tag = 1
                
            }else if (index == 2) {
                redDot.tag = 2
                
            }else if (index == 3) {
                redDot.tag = 3
                
            }else if (index == 4) {
                redDot.tag = 4
                
            }
            
            redDot.backgroundColor      = UIColor.red
            redDot.layer.cornerRadius   = RedDotRadius
            tabBarController.tabBar.addSubview(redDot)
            
        }

        
    }
    
}
