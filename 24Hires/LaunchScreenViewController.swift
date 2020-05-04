//
//  LaunchScreenViewController.swift
//  24Hires
//
//  Created by Jeekson on 26/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("launch Screen")
        checkInternet()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkInternet(){
        if !ReachabilityTest.isConnectedToNetwork(){
            let forceRetry = UIAlertAction(title: "Retry", style: .default) { (alert) in
                self.checkInternet()
            }
            noInternetAlertForceRetry(buttonAction: forceRetry)
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
