//
//  TopTabBar.swift
//  JobIn24
//
//  Created by MacUser on 21/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TopTabBar: UITabBarController, UITabBarControllerDelegate {

   
    @IBOutlet weak var activitiesTab: UITabBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var topDistance : CGFloat{
            get{
                if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                    return 0
                }else{
                    let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                    let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                    return barHeight + statusBarHeight
                }
            }
        }

        activitiesTab.frame = CGRect(x:0, y: topDistance, width: activitiesTab.frame.size.width, height:60)

    }
    
    override var selectedIndex: Int{
        get{
            return super.selectedIndex
        }
        set{
            animateToTab(toIndex: newValue)
            super.selectedIndex = newValue
        }
    }
    
    func animateToTab(toIndex: Int) {
        guard let tabViewControllers = viewControllers, tabViewControllers.count > toIndex, let fromViewController = selectedViewController, let fromIndex = tabViewControllers.index(of: fromViewController), fromIndex != toIndex else {return}
        
        view.isUserInteractionEnabled = false
        
        let toViewController = tabViewControllers[toIndex]
        let push = toIndex > fromIndex
        let bounds = UIScreen.main.bounds
        
        let offScreenCenter = CGPoint(x: fromViewController.view.center.x + bounds.width, y: toViewController.view.center.y)
        let partiallyOffCenter = CGPoint(x: fromViewController.view.center.x - bounds.width*0.25, y: fromViewController.view.center.y)
        
        if push{
            fromViewController.view.superview?.addSubview(toViewController.view)
            toViewController.view.center = offScreenCenter
        }else{
            fromViewController.view.superview?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            toViewController.view.center = partiallyOffCenter
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            toViewController.view.center   = fromViewController.view.center
            fromViewController.view.center = push ? partiallyOffCenter : offScreenCenter
        }, completion: { finished in
            fromViewController.view.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        })
    }

}

