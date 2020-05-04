//
//  ResetPasswordViewController.swift
//  JobIn24
//
//  Created by Jeekson Choong on 26/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift


class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var smallTitleLabel  : UILabel!
    @IBOutlet weak var emailTextField   : UITextField!
    @IBOutlet weak var resetButton      : UIButton!
    @IBOutlet weak var closedView       : UIView!
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        self.isEditing = false

        if (emailTextField.text?.isEmpty)! || emailTextField.text == ""{
            self.view.makeToast(Utilities.text(forKey: "resetpsw_emptyemail"), duration: 3.0, position: .bottom )
        }else{
             let resetEmail = emailTextField.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!) { error in
                DispatchQueue.main.async {
                    if error != nil{
                        let errCode = error.debugDescription
                        let errorMsg = error?.localizedDescription
                        print(errCode)
                        print(errorMsg!)
                        
                        self.view.makeToast(errorMsg, duration: 3.0, position: .bottom )
                        
                    }else{
                        self.view.makeToast("An email has been sent to your registered email to reset your password", duration: 3.0, position: .bottom )
                        self.emailTextField.text = ""
                    }
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadString()
        closedView.layer.cornerRadius   = closedView.frame.size.width/2
        closedView.clipsToBounds        = true
        // Do any additional setup after loading the view.
    }

    func loadString(){
        titleLabel.text = Utilities.text(forKey: "label_resetpsw")
        smallTitleLabel.text = Utilities.text(forKey: "label_resetpsw2")
        emailTextField.placeholder = Utilities.text(forKey: "label_email")
        resetButton.setTitle(Utilities.text(forKey: "label_reset"), for: .normal)
        textFieldSetup()
    }

    func textFieldSetup(){
        
        emailTextField.backgroundColor          = UIColor.clear
        emailTextField.tintColor                = UIColor.white
        emailTextField.textColor                = UIColor.white
        emailTextField.attributedPlaceholder    = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer             = CALayer()
        bottomLayer.frame           = CGRect(x: 50, y: 35, width: emailTextField.frame.width - 10, height: 1)
        bottomLayer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayer)
        
      /*  emailTextField.layer.cornerRadius    = 20
        emailTextField.layer.borderWidth     = 2.0
        emailTextField.layer.borderColor     = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor*/
        
        resetButton.cornerRadius      = 20
        resetButton.backgroundColor   = UIColor.clear
        resetButton.layer.borderWidth = 2.0
        resetButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        tfImageSetup()
    }
    
    func tfImageSetup(){
        emailTextField.leftViewMode = UITextFieldViewMode.always
        
        let emailPadding    = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        let emailImageView  = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 45))
        let emailImg        = UIImage(named: "emaillogin")
        emailImageView.image        = emailImg
        emailImageView.contentMode  = .scaleAspectFit
        emailPadding.addSubview(emailImageView)
        
        emailTextField.leftView = emailPadding
    }


}
