//
//  MainTabBarController.swift
//  JobIn24
//
//  Created by MacUser on 24/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate{
    
    var centerButton: UIButton!
    
    var ref: DatabaseReference!
    
    var uid: String!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for item in self.tabBar.items! {
            let unselectedItem = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
            let selectedItem = [NSAttributedStringKey.foregroundColor: UIColor.init(red: 96/255, green: 197/255, blue: 247/255, alpha: 1.0)]
            
            item.setTitleTextAttributes(unselectedItem, for: .normal)
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkInternet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        displayNotificationBadge()

    }
    
    func checkInternet(){
        
        if ReachabilityTest.isConnectedToNetwork() {
            print("Internet connection available")
            
        }
        else{
            print("No internet connection available")
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
                self.checkInternet()
            }
            noInternetAlertForceRetry(buttonAction: retryAction)
//            showAlertBoxWithOneAction(title: "No Internet Connection", msg: "Make sure your device is connected to the internet.", buttonAction: retryAction)
        }
    }

    
    func displayNotificationBadge(){
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            uid = currentUser?.uid
            print("[MainTabController] UID: \(uid)")
            
            ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("NewMainNotification") {
                    
                    let NewMainNotification = snapshot.childSnapshot(forPath: "NewMainNotification").value as? String
                    
                    if NewMainNotification == "true" {
                        self.addRedDotAtTabBarItemIndex(index: 1, removeindex: 0)
                    }
                    else {
                        self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 1) // index10: No Dot
                    }
                }
            })
            
            ref.child("UserActivities").child(uid!).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("NewTalentMainNotification") {
                    
                    let NewTalentMainNotification = snapshot.childSnapshot(forPath: "NewTalentMainNotification").value as? String
                    
                    if NewTalentMainNotification == "true" {
                        self.addRedDotAtTabBarItemIndex(index: 2, removeindex: 0)
                    }
                    else {
                        self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 2)
                    }
                }
            })
            
            ref.child("UserChatList").child(uid!).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("Pressed") {
                    let newchat = snapshot.childSnapshot(forPath: "Pressed").value as? String
                    
                    if newchat == "true" {
                        self.addRedDotAtTabBarItemIndex(index: 3, removeindex: 0)
                    }
                    else {
                        self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 3)
                    }
                }
            })
            
            ref.child("UserReview").child(uid!).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("Notification") {
                    let newreview = snapshot.childSnapshot(forPath: "Notification").value as? String
                    
                    if newreview == "true" {
                        self.addRedDotAtTabBarItemIndex(index: 4, removeindex: 0)
                    }
                    else {
                        self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 4)
                    }
                }
            })
        }
    }


    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        print("tabBarIndex = \(tabBarIndex)")
        
        if tabBarIndex == 1 {       //Job
            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 1)
           
            if(self.uid != nil){
                
                ref.child("UserActivities").child(uid!).observe(.value, with: { (snapshot) in
                    if snapshot.hasChild("NewMainNotification") {
                        
                        self.ref.child("UserActivities").child(self.uid!).child("NewMainNotification").setValue("false")
                        
                            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 1) // index10: No Dot
                        
                    }
                })
            }
            
        }else if tabBarIndex == 2 {  //Talent
            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 2)
            
            if(self.uid != nil){
                
                ref.child("UserActivities").child(uid!).observe(.value, with: { (snapshot) in
                    if snapshot.hasChild("NewTalentMainNotification") {
                        
                        self.ref.child("UserActivities").child(self.uid!).child("NewTalentMainNotification").setValue("false")
                        
                            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 2)
                        
                    }
                })
                
            }
            
        }else if tabBarIndex == 3 {  //Message
            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 3)
            
            if(self.uid != nil){
                
                ref.child("UserChatList").child(uid!).observe(.value, with: { (snapshot) in
                    if snapshot.hasChild("Pressed") {
                        self.ref.child("UserChatList").child(self.uid!).child("Pressed").setValue("false")
                        
                            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 3)
                        
                    }
                })
                
            }
            
        }else if tabBarIndex == 4 {  //Profile
            self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 4)
           
            if(self.uid != nil){
                
                ref.child("UserReview").child(uid!).observe(.value, with: { (snapshot) in
                    if snapshot.hasChild("Notification") {
                        self.ref.child("UserReview").child(self.uid!).child("Notification").setValue("false")
                        
                        self.addRedDotAtTabBarItemIndex(index: 10, removeindex: 4)
                    }
                })
                
            }
        }
    }
}


// MARK:- OLD CODE


//    @objc func handleTouchTabbarCenter()
//    {
//        // push view controller but animate modally
//
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
//
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
//        self.present(nextViewController, animated:true, completion:nil)
//
//    }
    
//    func addCenterButton(withImage buttonImage : UIImage, highlightImage: UIImage) {
//
//        self.centerButton = UIButton(type: .custom)
//        self.centerButton?.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin]
//        self.centerButton?.frame = CGRect(x: 0.0, y: 0.0, width: buttonImage.size.width, height: buttonImage.size.height)
//        self.centerButton?.setBackgroundImage(buttonImage, for: .normal)
//        self.centerButton?.setBackgroundImage(highlightImage, for: .highlighted)
//        self.centerButton?.isUserInteractionEnabled = true
//
//        let heightdif: CGFloat = buttonImage.size.height - (self.tabBar.frame.size.height);
//
//        if (heightdif < 0){
//            self.centerButton?.center = (self.tabBar.center)
//        }
//        else{
//            var center: CGPoint = (self.tabBar.center)
//            center.y = center.y - 24
//            self.centerButton?.center = center
//        }
//
//        self.view.addSubview(self.centerButton!)
//        view.layoutIfNeeded()
//        //self.tabBar.bringSubview(toFront: self.centerButton!)
//
//        self.centerButton?.addTarget(self, action: #selector(handleTouchTabbarCenter), for: .touchUpInside)
//
//
//    }
    
//    func hideCenterButton() {
//       // self.tabBar.isHidden = true
//        self.centerButton.isHidden = true
//    }
//
//    func showCenterButton() {
//      //  self.tabBar.isHidden = false
//        self.centerButton.isHidden = false
//
//    }

//    override func viewDidLayoutSubviews() {
//        if self.centerButton != nil {
//            self.view.bringSubview(toFront: self.centerButton)
//
//            for vw in self.view.subviews {
//                if let subView = vw as? UITabBar {
//                    if subView.isHidden == true {
//                        self.centerButton.isHidden = true
//                    } else {
//                        self.centerButton.isHidden = false
//                    }
//                }
//            }
//        }
//    }
    
  
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        print("ViewAppear")
//
//        if  let arrayOfTabBarItems = self.tabBar.items as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
//            tabBarItem.isEnabled = false
//        }
//
//        // add subview to tabBarController?.tabBar
//        //self.tabBar.addSubview(button)
//    }



