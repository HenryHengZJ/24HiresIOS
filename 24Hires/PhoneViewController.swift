//
//  PhoneViewController.swift
//  JobIn24
//
//  Created by MacUser on 12/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.layer.cornerRadius = 7
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = UIColor.lightGray.cgColor

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Save(_ sender: Any) {
        
        let phoneInput = phoneTextField.text
        
        let myDict = [ "phone": phoneInput ]
        
        // Post a notification
        NotificationCenter.default.post(name: Notification.Name("phonenotification"), object: nil, userInfo: myDict)
        
        dismiss(animated: true, completion: nil)    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
