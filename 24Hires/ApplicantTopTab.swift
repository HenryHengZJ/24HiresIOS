//
//  ApplicantTopTab.swift
//  JobIn24
//
//  Created by MacUser on 26/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class ApplicantTopTab: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var applicantTab: UITabBar!
 
    var postKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*var yNavBar = self.navigationController?.navigationBar.frame.size.height
         
         var yStatusBar = UIApplication.shared.statusBarFrame.size.height*/
        
        
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
        applicantTab.frame = CGRect(x:0, y: topDistance, width: applicantTab.frame.size.width, height:60)

        
//        applicantTab.frame = CGRect(x:0, y: 64, width: applicantTab.frame.size.width, height:44)
        
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
