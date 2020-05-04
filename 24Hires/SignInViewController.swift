//
//  SignInViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/26/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class MaskView : UIView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let mask = self.layer.mask{
            mask.frame = self.bounds
        }
    }
}

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField       : UITextField!
    @IBOutlet weak var passwordTextField    : UITextField!
    @IBOutlet weak var loginImage           : UIImageView!
    @IBOutlet weak var signinBtn            : UIButton!
    @IBOutlet weak var closedView           : UIView!
    @IBOutlet weak var createAccLabel: UILabel!
    
    var verificationTimer : Timer = Timer()  // Timer's  For Email Varification Check
    
    var fromLogout  = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addObserver()
//         self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
        
        textFieldSetup()
        tfImageSetup()

        closedView.layer.cornerRadius   = closedView.frame.size.width/2
        closedView.clipsToBounds        = true
        
        let normalAttString    = NSMutableAttributedString(string:Utilities.text(forKey: "createacc"))
        let createAttString       = NSMutableAttributedString(string:Utilities.text(forKey: "label_createaccount"))
       
        
        if let createRange = normalAttString.string.range(of: "@"){
            
            let range1 = NSRange(createRange, in: normalAttString.string)
            
            createAttString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, createAttString.length))
            createAttString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue , range: NSMakeRange(0, createAttString.length))
            createAttString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.white, range: NSMakeRange(0, createAttString.length))
            
            normalAttString.replaceCharacters(in: range1, with: createAttString)
            
            let newAttStr   = normalAttString
            
            let newText = NSMutableAttributedString(attributedString: newAttStr)
            createAccLabel.attributedText = newText
        }
        
        //Tnc & Policy Tapped
        let CreateTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(createAccountTapped(_:)))
        createAccLabel.addGestureRecognizer(CreateTapGestureRecognizer)
        createAccLabel.isUserInteractionEnabled = true

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //removeObserver()
    }
    
    //Jeekson Keyboard Handling
    /*func addObserver(){
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil){
            notification in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide , object: nil, queue: nil){
            notification in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    */
    
    
    func textFieldSetup(){
        emailTextField.backgroundColor          = UIColor.clear
        emailTextField.tintColor                = UIColor.white
        emailTextField.textColor                = UIColor.white
        emailTextField.attributedPlaceholder    = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer             = CALayer()
        bottomLayer.frame           = CGRect(x: 50, y: 35, width: emailTextField.frame.width - 10, height: 1)
        bottomLayer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayer)
        
        passwordTextField.backgroundColor   = UIColor.clear
        passwordTextField.tintColor         = UIColor.white
        passwordTextField.textColor         = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer1                = CALayer()
        bottomLayer1.frame              = CGRect(x: 50, y: 35, width: passwordTextField.frame.width - 10, height: 1)
        bottomLayer1.backgroundColor    = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayer1)
        
        signinBtn.cornerRadius      = 20
        signinBtn.backgroundColor   = UIColor.clear
        signinBtn.layer.borderWidth = 2.0
        signinBtn.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        
//        emailTextField.layer.cornerRadius    = 20
//        emailTextField.layer.borderWidth     = 2.0
//        emailTextField.layer.borderColor     = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
//        
//        passwordTextField.layer.cornerRadius = 20
//        passwordTextField.layer.borderWidth  = 2.0
//        passwordTextField.layer.borderColor  = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
    }
    
//    func handleTextField(){
//        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
//        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
//
//    }
    
    func tfImageSetup(){
        emailTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
        let emailPadding    = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        let emailImageView  = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 45))
        let emailImg        = UIImage(named: "emaillogin")
        emailImageView.image        = emailImg
        emailImageView.contentMode  = .scaleAspectFit
        emailPadding.addSubview(emailImageView)
        
        let pswPadding      = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        let pswImageView    = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 45))
        let pswImg          = UIImage(named: "password2")
        pswImageView.image  = pswImg
        pswImageView.contentMode = .scaleAspectFit
        pswPadding.addSubview(pswImageView)


        emailTextField.leftView = emailPadding
        passwordTextField.leftView = pswPadding
        
        
        
    }
    
    @objc func createAccountTapped(_ gestureRecognizer: UITapGestureRecognizer){
        
        let labelTxt = createAccLabel.text! as NSString
        let create = labelTxt.range(of: Utilities.text(forKey: "label_createaccount"))
        
        if gestureRecognizer.didTapAttributedTextInLabel(label: createAccLabel, inRange: create){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            self.present(vc, animated: true, completion: nil)
            
            /*self.showAlertBox(title: "Login via social media or email is required to perform further actions", msg: "", buttonString: "Ok, Got It!")*/
            
            
        }
        
        
    }
    
    @objc func checkIfTheEmailIsVerified(){
        
        Auth.auth().currentUser?.reload(completion: { (err) in
            if err == nil{
                
                if Auth.auth().currentUser!.isEmailVerified{
                    print("""
                            =========
                            Signed In
                            =========
                    """)
                    let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
                    self.present(vc, animated: true, completion: nil)
                    self.verificationTimer.invalidate()     //Kill the timer
                    
                } else {
                    self.view.hideToastActivity()
                    print("It aint verified yet")
                    self.view.makeToast(Utilities.text(forKey: "signin_emailnotverified"), duration: 3.0, position: .bottom )
                    self.verificationTimer.invalidate()
                }
            } else {
                
                print(err?.localizedDescription ?? "")
                
            }
        })
        
    }
    
    
//    @objc func textFieldDidChange(){
//        guard let email = emailTextField.text, !email.isEmpty,
//            let password = passwordTextField.text, !password.isEmpty else{
//                signinBtn.setTitleColor(UIColor.lightText, for: UIControlState.normal)
//                signinBtn.isEnabled = false
//                return
//        }
//
//        signinBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
//        signinBtn.isEnabled = true
//
//    }
    
  
    @IBAction func forgetPswButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SignInToResetPsw, sender: self)
        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        self.isEditing = false
        self.view.makeToastActivity(.center)

        if ReachabilityTest.isConnectedToNetwork(){
            //Have Internet
            if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
                print("Prompt Empty Email")
                self.view.hideToastActivity()
                self.view.makeToast(Utilities.text(forKey: "signin_emptyfield"), duration: 3.0, position: .bottom )
                
            }else{
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                    if error != nil{
                        self.view.hideToastActivity()
                        self.view.makeToast(Utilities.text(forKey: "signin_invalidsignin"), duration: 3.0, position: .bottom )
                        print(error!.localizedDescription)
                        return
                    }else{
                        
                        self.checkIfTheEmailIsVerified()
                
                    }
                }
            }
        }else{
            print("[Login Button Pressed]: No Internet")
            noInternetAlert()
            DispatchQueue.main.async {
                self.view.hideToastActivity()
            }
        }
        
    }
    
    
    
}

