//
//  Activities2ViewController.swift
//  24Hires
//
//  Created by MacUser on 15/05/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class Activities2ViewController: UIViewController {

    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    enum TabIndex : Int {
        case firstChildTab = 0
        case secondChildTab = 1
        case thirdChildTab = 2
    }
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "Saved2ViewController")
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "Applied2ViewController")
        
        return secondChildTabVC
    }()
    
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedViewController")
        
        return thirdChildTabVC
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Control 1: Created and designed in IB that announces its value on interaction
        segmentedControl.titles = ["SAVED", "APPLIED", "POSTED"]
        segmentedControl.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        segmentedControl.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        displayCurrentTab(0)
        
        let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.containerView.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.containerView.addGestureRecognizer(swipedright)
        
        let actionUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "post_job_white_25.png"), style: .plain, target: self, action: #selector(Activities2ViewController.clickButton))
        self.navigationItem.rightBarButtonItem  = actionUIBarButtonItem
        
       
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func clickButton() {
      
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if self.segmentedControl.index < 3 { // set your total tabs here
                var selectedIndex = self.segmentedControl.index
                selectedIndex = selectedIndex + 1
                displayCurrentTab(Int(selectedIndex))
                try! segmentedControl.setIndex(selectedIndex, animated: true)
            }
        } else if sender.direction == .right {
            if self.segmentedControl.index > 0 {
                var selectedIndex = self.segmentedControl.index
                selectedIndex = selectedIndex - 1
                displayCurrentTab(Int(selectedIndex))
                try! segmentedControl.setIndex(selectedIndex, animated: true)
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postClicked(_ sender: Any) {

        // show postVC
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func segmentChanged(_ sender: BetterSegmentedControl) {
        
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(Int(sender.index))
    }
    
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.containerView.bounds
            self.containerView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.firstChildTab.rawValue :
            vc = firstChildTabVC
        case TabIndex.secondChildTab.rawValue :
            vc = secondChildTabVC
        case TabIndex.thirdChildTab.rawValue :
            vc = thirdChildTabVC
        default:
            return nil
        }
        
        return vc
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}