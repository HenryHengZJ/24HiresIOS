//
//  SignUpViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/26/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Toast_Swift

class SignUpViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var usernameTextField    : UITextField!
    @IBOutlet weak var emailTextField       : UITextField!
    @IBOutlet weak var passwordTextField    : UITextField!
    @IBOutlet weak var profileImage         : UIImageView!
    @IBOutlet weak var closedView           : UIView!
    @IBOutlet weak var signupBtn            : UIButton!
    @IBOutlet weak var editImageView        : UIImageView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate     = self
        usernameTextField.delegate  = self
        passwordTextField.delegate  = self
        tfSetup()
        tfImageSetup()
        
        closedView.layer.cornerRadius = closedView.frame.size.width/2
        closedView.clipsToBounds = true
    
        profileImage.layer.cornerRadius = 52
        profileImage.clipsToBounds = true
//        editImageView.layer.cornerRadius = editImageView.frame.size.height/2
//        editImageView.clipsToBounds = true
        
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        signupBtn.layer.cornerRadius    = 20
        signupBtn.backgroundColor       = .clear
        signupBtn.layer.borderWidth     = 2.0
        signupBtn.layer.borderColor     = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        
        handleTextField()
    }
    
    func tfSetup(){
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.white
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer2 = CALayer()
        bottomLayer2.frame = CGRect(x: 50, y: 35, width: usernameTextField.frame.width - 10, height: 1)
        bottomLayer2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayer2)
        
        
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 50, y: 35, width: emailTextField.frame.width - 10, height: 1)
        bottomLayer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayer)
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha:0.8)])
        
        let bottomLayer1 = CALayer()
        bottomLayer1.frame = CGRect(x: 50, y: 35, width: passwordTextField.frame.width - 10, height: 1)
        bottomLayer1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayer1)
        
//        usernameTextField.layer.cornerRadius    = 20
//        usernameTextField.layer.borderWidth     = 2.0
//        usernameTextField.layer.borderColor     = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
//        
//        emailTextField.layer.cornerRadius    = 20
//        emailTextField.layer.borderWidth     = 2.0
//        emailTextField.layer.borderColor     = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
//        
//        passwordTextField.layer.cornerRadius = 20
//        passwordTextField.layer.borderWidth  = 2.0
//        passwordTextField.layer.borderColor  = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
    }
    
    func handleTextField(){
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    func tfImageSetup(){
        usernameTextField.leftViewMode  = UITextFieldViewMode.always
        emailTextField.leftViewMode     = UITextFieldViewMode.always
        passwordTextField.leftViewMode  = UITextFieldViewMode.always
        
        let usernamePadding    = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        let usernameImageView  = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 45))
        let usernameImg        = UIImage(named: "chatuser")
        usernameImageView.image        = usernameImg
        usernameImageView.contentMode  = .scaleAspectFit
        usernamePadding.addSubview(usernameImageView)
        
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
        
        usernameTextField.leftView  = usernamePadding
        emailTextField.leftView     = emailPadding
        passwordTextField.leftView  = pswPadding
        
    }
    
    func sendVerificationEmail(){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil{
                print("[Send Verification Email Error]")
            }
            else{
                self.view.makeToast(Utilities.text(forKey: "signup_successful"), duration: 3.0, position: .bottom )
            }
        })
        
    }
    
    
    
    @objc func textFieldDidChange(){
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty,
        let password = passwordTextField.text, !password.isEmpty else{
            signupBtn.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signupBtn.isEnabled = false
            return
        }
        
        signupBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        signupBtn.isEnabled = true
        
    }
    
    @objc func handleSelectProfileImageView() {
        print("got")
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
   
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SignUpButn_TouchUpInside(_ sender: Any) {
        
        if ReachabilityTest.isConnectedToNetwork(){
            if usernameTextField.text == "" {
                //Empty Username
                showAlertBox(title: "Please Enter Your Username", msg: "", buttonString: "Ok")
            } else if passwordTextField.text == "" {
                //Empty Password
                showAlertBox(title: "Please Enter Your Password", msg: "", buttonString: "OK")
            } else if emailTextField.text == ""{
                //Empty Email
                showAlertBox(title: "Please Enter Your Email", msg: "", buttonString: "Ok")
            }else{
                //PROCEED SIGN UP
                // [START create_user]
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                    
                    if error != nil{
                         self.view.makeToast("Email has been used", duration: 3.0, position: .bottom )
                        print(error!.localizedDescription)
                        return
                    }
                    self.sendVerificationEmail()
                    let uid = user?.uid
                    let storageRef = Storage.storage().reference()
                    let profileImageRef = storageRef.child("ProfilePhotos").child(uid!)
                    if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
                        profileImageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                            print(metadata!)
                            if error != nil{
                                self.view.makeToast(Utilities.text(forKey: "signup_failed"), duration: 3.0, position: .bottom )
                                return
                            }
                            let profileImageUrl = metadata?.downloadURL()?.absoluteString
                            let ref = Database.database().reference()
                            let usersReference = ref.child("UserAccount")
                            let newUserReference = usersReference.child(uid!)
                            newUserReference.setValue(["name": self.usernameTextField.text!, "email": self.emailTextField.text!,"id": uid, "image": profileImageUrl])
                            
//                            let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
//
//                            self.present(vc, animated: true, completion: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                            print(" signupwithpic: \(newUserReference.description())")
                            
                        })
                    }
                    else{
                        let ref = Database.database().reference()
                        let usersReference = ref.child("UserAccount")
                        let newUserReference = usersReference.child(uid!)
                        //                newUserReference.setValue(["username": self.usernameTextField.text!, "email": self.emailTextField.text!, "id": uid])
                        
                        newUserReference.setValue(["name": self.usernameTextField.text!, "email": self.emailTextField.text!, "id": uid,"image":"default"], withCompletionBlock: { (error,ref) in
                            if error == nil{
                                
                                print("[Check New User]: This Is New User.\n")
                                let preference = UserDefaults.standard
                                let newUserKey  = "newUser"
                                preference.setValue(true, forKey: newUserKey)
                                
                                
                                let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
                                
                                self.present(vc, animated: true, completion: nil)
                                
                                print(" signupwithoutpic: \(newUserReference.description())")
                            }else{
                                self.view.makeToast(Utilities.text(forKey: "signup_failed"), duration: 3.0, position: .bottom )
                            }
                        })
                    }
                }
                // [END create_user]

            }
        }else{
            noInternetAlert()
        }
        

    }
    
    //TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if string.isEmpty{
            return true
        }
        if (textField != emailTextField){
            let allowedCharacter = CharacterSet.alphanumerics
            if let rangeOfCharactersAllow = string.rangeOfCharacter(from: allowedCharacter, options: .caseInsensitive){
                let validCount = string.distance(from: rangeOfCharactersAllow.lowerBound, to: rangeOfCharactersAllow.upperBound)
                return validCount == string.count
            }else{
                print("[Text Field Delegate]: Invalid Text Entered\n")
                return false
            }
        }
        
       return true
    }
    
    
    
    
    
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
        
        print("did finish picking media")
        
    }
}
