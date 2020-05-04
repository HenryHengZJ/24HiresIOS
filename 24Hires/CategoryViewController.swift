//
//  CategoryViewController.swift
//  JobIn24
//
//  Created by MacUser on 17/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    var categoryPressed = ""
    var categoryNum = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func categorySelected() {
        let categoryDict: [String: String] = ["category": categoryPressed, "categorynum": categoryNum]
        
        NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil, userInfo: categoryDict)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
      
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func baristaPressed(_ sender: Any) {
        categoryPressed = "Barista / Bartendar"
        categoryNum = "11"
        categorySelected()
    }
    
    @IBAction func beautyPressed(_ sender: Any) {
        categoryPressed = "Beauty / Wellness"
        categoryNum = "12"
        categorySelected()
    }
    
    @IBAction func chefPressed(_ sender: Any) {
        categoryPressed = "Chef / Kitchen Helper"
        categoryNum = "13"
        categorySelected()
    }

    @IBAction func eventPressed(_ sender: Any) {
        categoryPressed = "Event Crew"
        categoryNum = "14"
        categorySelected()
    }
    
    @IBAction func emceePressed(_ sender: Any) {
        categoryPressed = "Emcee"
        categoryNum = "15"
        categorySelected()
    }
    
    @IBAction func eduPressed(_ sender: Any) {
        categoryPressed = "Education"
        categoryNum = "16"
        categorySelected()
    }
    
    @IBAction func fitnessPressed(_ sender: Any) {
        categoryPressed = "Fitness / Gym"
        categoryNum = "17"
        categorySelected()
    }
    
    @IBAction func modelPressed(_ sender: Any) {
        categoryPressed = "Modelling / Shooting"
        categoryNum = "18"
        categorySelected()
    }
    
    @IBAction func mascotPressed(_ sender: Any) {
        categoryPressed = "Mascot"
        categoryNum = "19"
        categorySelected()
    }
    
    @IBAction func officePressed(_ sender: Any) {
        categoryPressed = "Office / Admin"
        categoryNum = "20"
        categorySelected()
    }
    
    @IBAction func promoterPressed(_ sender: Any) {
        categoryPressed = "Promoter / Sampling"
        categoryNum = "21"
        categorySelected()
    }
    
    @IBAction func roadshowPressed(_ sender: Any) {
        categoryPressed = "Roadshow"
        categoryNum = "22"
        categorySelected()
    }
    
    @IBAction func rovingPressed(_ sender: Any) {
        categoryPressed = "Roving Team"
        categoryNum = "23"
        categorySelected()
    }
    
    @IBAction func retailPressed(_ sender: Any) {
        categoryPressed = "Retail / Consumer"
        categoryNum = "24"
        categorySelected()
    }
    
    @IBAction func servingPressed(_ sender: Any) {
        categoryPressed = "Serving"
        categoryNum = "25"
        categorySelected()
    }
    
    @IBAction func usherPressed(_ sender: Any) {
        categoryPressed = "Usher / Ambassador"
        categoryNum = "26"
        categorySelected()
    }
    
    @IBAction func waiterPressed(_ sender: Any) {
        categoryPressed = "Waiter / Waitress"
        categoryNum = "27"
        categorySelected()
    }
    
    @IBAction func otherPressed(_ sender: Any) {
        categoryPressed = "Other"
        categoryNum = "28"
        categorySelected()
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
