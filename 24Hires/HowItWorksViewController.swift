//
//  HowItWorksViewController.swift
//  JobIn24
//
//  Created by Jeekson on 16/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class HowItWorksViewController: UIViewController, UIScrollViewDelegate {

    //MARK:- IBOutlet & IBAction
    @IBOutlet weak var segmentControll  : BetterSegmentedControl!
    @IBOutlet weak var scrollView       : UIScrollView!
    
    @IBOutlet weak var closedView: UIView!

    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- Variable Declaration
    var currentSegmentIndex = UInt()
    var oldContentOffset    = CGPoint()
    
    
    
    //MARK:- VC Delegate
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 58, green: 178, blue: 244, alpha: 1.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        closedView.layer.cornerRadius   = closedView.frame.size.width/2
        closedView.clipsToBounds        = true
        
        setupSegmentControll()
        scrollView.delegate = self
    }

    //MARK:- Segment Control
    
    func setupSegmentControll(){
        segmentControll.titles              = ["EXPLORE JOB", "DISCOVER TALENT"]
        segmentControll.titleFont           = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        segmentControll.selectedTitleFont   = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        
        let indicatorView   = UIView(frame: CGRect(x: segmentControll.frame.origin.x , y: segmentControll.frame.size.height - 5, width: segmentControll.frame.size.width/2, height: 2) )
        
        indicatorView.backgroundColor       = .white
        indicatorView.layer.cornerRadius    = indicatorView.frame.height/2
        
        segmentControll.addSubviewToIndicator(indicatorView)
        segmentControll.addTarget(self, action: #selector(scrollPageBySegmentControll(_:)), for: .valueChanged )
        
    }
    
    //MARK:- Scroll View Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x != oldContentOffset.x{
            scrollView.isPagingEnabled = true
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: oldContentOffset.y)
        }else{
            scrollView.isPagingEnabled = false
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        oldContentOffset = scrollView.contentOffset
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        do {
            try segmentControll.setIndex(UInt(pageIndex), animated: true)
        }
        catch {
            print("Error on Segment Control")
        }
        
    }
    
    @objc func scrollPageBySegmentControll(_ sender: BetterSegmentedControl){
        print("Scroll By Segment")
        
        if segmentControll.index == 0{
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y) , animated: true)
        }else{
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width , y: 0) , animated: true)
        }
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
