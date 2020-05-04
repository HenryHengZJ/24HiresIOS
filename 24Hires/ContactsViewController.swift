//
//  ContactsViewController.swift
//  JobIn24
//
//  Created by MacUser on 12/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController {

  

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.layer.cornerRadius = 7
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
