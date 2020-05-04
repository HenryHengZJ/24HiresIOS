//
//  SettingsViewController.swift
//  JobIn24
//
//  Created by Jeekson on 17/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseInstanceID
import MessageUI



class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var userAnonymous = false

    
    @IBOutlet weak var resetPswButton                   : UIButton!
    @IBOutlet weak var msgNotificationSwitch            : UISwitch!
    @IBOutlet weak var bookingsNotificationSwitch       : UISwitch!
    @IBOutlet weak var shortlistedNotificationSwitch    : UISwitch!
    @IBOutlet weak var hiredNotificationSwitch          : UISwitch!
    @IBOutlet weak var applicantsSwitch                 : UISwitch!
    
    
    @IBAction func msgSwitchToggled(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            self.msgNotificationSwitch.setOn(false, animated: false)
            return
        }
        switchChangeAction(tokenName: "ChatTokens", switchStatus: msgNotificationSwitch.isOn)
    }
    
    @IBAction func bookingSwitchToggled(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            self.bookingsNotificationSwitch.setOn(false, animated: false)
            return
        }
        switchChangeAction(tokenName: "BookingTokens", switchStatus: bookingsNotificationSwitch.isOn)
    }
    
    @IBAction func shortlistSwitchToggled(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            self.shortlistedNotificationSwitch.setOn(false, animated: false)
            return
        }
        switchChangeAction(tokenName: "ShortlistTokens", switchStatus: shortlistedNotificationSwitch.isOn)
    }
    
    @IBAction func hiredSwitchToggled(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            self.hiredNotificationSwitch.setOn(false, animated: false)
            return
        }
        switchChangeAction(tokenName: "HireTokens", switchStatus: hiredNotificationSwitch.isOn)
    }
    
    @IBAction func applicantsSwitchToggled(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            self.applicantsSwitch.setOn(false, animated: false)
            return
        }
        switchChangeAction(tokenName: "ApplyTokens", switchStatus: applicantsSwitch.isOn)
    }
    
    @IBAction func resetPswButtonPressed(_ sender: Any) {
        if (userAnonymous) {
            showUserAnonymousDialog()
            return
        }
        resetPsw()
    }
    @IBAction func sendFeedbackButtonPressed(_ sender: Any) {
        emailPreparation(type: "Feedback")
    }
    @IBAction func reportButtonPressed(_ sender: Any) {
        emailPreparation(type: "Report Fraud")
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            if currentUser!.isAnonymous {
                Database.database().reference().child("UserActivities").child(uid!).removeValue()
                
                Database.database().reference().child("UserReview").child(uid!).removeValue()
                
                Database.database().reference().child("UserChatList").child(uid!).removeValue()
                
                Database.database().reference().child("SortFilter").child(uid!).removeValue()
                
                do{
                    try Auth.auth().signOut()
                    currentUser?.delete(completion: { (error) in
                        if error != nil {
                            print("delete anonymous user failed")
                        }
                        else {
                            print("delete anonymous user success")
                        }
                    })
                }catch let logoutError{
                    print(logoutError)
                }
                
            }
            else {
                userConnections.removeValue()
                userLastOnline.setValue(ServerValue.timestamp())
                
                do{
                    try Auth.auth().signOut()
                }catch let logoutError{
                    print(logoutError)
                }
            }
        }
        
     
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signinVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(signinVC, animated: true, completion: nil)
    }

    
    let userActivitiesRef   = Database.database().reference().child("UserActivities")
    let userAccountRef      = Database.database().reference().child("UserAccount")
    let userConnections     = Database.database().reference().child("UserActivities").child((Auth.auth().currentUser?.uid)!).child("Connections")
    let userLastOnline      = Database.database().reference().child("UserActivities").child((Auth.auth().currentUser?.uid)!).child("Lastonline")
    
    let UID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                userAnonymous = true
                self.msgNotificationSwitch.setOn(false, animated: false)
                self.bookingsNotificationSwitch.setOn(false, animated: false)
                self.shortlistedNotificationSwitch.setOn(false, animated: false)
                self.hiredNotificationSwitch.setOn(false, animated: false)
                self.applicantsSwitch.setOn(false, animated: false)
             
            }
            else {
                checkNotificationSwitch()
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func showUserAnonymousDialog() {
        //self.showAlertBox(title: "Login via social media or email is required to perform further actions", msg: "", buttonString: "Ok, Got It!")
        
        let loginAction = UIAlertAction(title: "Log In", style: .default) { (action) in
            self.logOutAnonymous()
        }
        self.showAlertBoxWithAction(title: "Login via social media or email is required to perform further actions", msg: "", buttonString: "Cancel", buttonAction: loginAction)
    }
    
    func logOutAnonymous() {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            if currentUser!.isAnonymous {
                Database.database().reference().child("UserActivities").child(uid!).removeValue()
                
                Database.database().reference().child("UserReview").child(uid!).removeValue()
                
                Database.database().reference().child("UserChatList").child(uid!).removeValue()
                
                Database.database().reference().child("SortFilter").child(uid!).removeValue()
                
                do{
                    try Auth.auth().signOut()
                    currentUser?.delete(completion: { (error) in
                        if error != nil {
                            print("delete anonymous user failed")
                        }
                        else {
                            print("delete anonymous user success")
                        }
                    })
                }catch let logoutError{
                    print(logoutError)
                }
                
            }
        }
        
        
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signinVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(signinVC, animated: true, completion: nil)
    }
    

    func checkNotificationSwitch(){
        
        userActivitiesRef.child(UID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("ChatTokens"){
                self.msgNotificationSwitch.setOn(true, animated: false)
            }else{
                self.msgNotificationSwitch.setOn(false, animated: false)
            }
            
            if snapshot.hasChild("ApplyTokens"){
                self.applicantsSwitch.setOn(true, animated: false)
            }else{
                self.applicantsSwitch.setOn(false, animated: false)
            }
            
            if snapshot.hasChild("ShortlistTokens"){
                self.shortlistedNotificationSwitch.setOn(true, animated: false)
            }else{
                self.shortlistedNotificationSwitch.setOn(false, animated: false)
            }
            if snapshot.hasChild("HireTokens"){
                self.hiredNotificationSwitch.setOn(true, animated: false)
            }else{
                self.hiredNotificationSwitch.setOn(false, animated: false)
            }
            if snapshot.hasChild("BookingTokens"){
                self.bookingsNotificationSwitch.setOn(true, animated: false)
            }else{
                self.bookingsNotificationSwitch.setOn(false, animated: false)
            }
        }
    }
    
    func switchChangeAction(tokenName: String, switchStatus: Bool){
        
        var token : String?
        var setBool : String?
        
        if switchStatus{
            setBool = "true"
        }else{
            setBool = "false"
        }
        
        InstanceID.instanceID().getID { (identity, error) in
            if error != nil{
                print("[Get Instance ID Error]: \(String(describing: error?.localizedDescription))")
            }else{
                token = identity
                if switchStatus{
                    //Switch On
                    self.userActivitiesRef.child(self.UID!).child(tokenName).child(token!).setValue(setBool)
                }else{
                    //Switch Off
                    
                self.userActivitiesRef.child(self.UID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.hasChild(tokenName){
                            self.userActivitiesRef.child(self.UID!).child(tokenName).removeValue()
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    func emailPreparation(type: String){
        
        let userID      = UID!
        let appVersion  = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let OSVersion   = UIDevice.current.systemVersion
        let versionName = UIDevice.current.systemName
        let model       = UIDevice.current.localizedModel
        
        print("""
================================
    Device Info For Mail
================================
App Version : \(appVersion)
OS Version  : \(OSVersion)
Version Name: \(versionName)
Phone Model : \(model)
            
""")
        
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["24hiresmy@gmail.com"])
            mail.setSubject(type)
            mail.setMessageBody("<p> *Please do not delete the following information:<br />UserID: \(userID))<br />App version: \(appVersion)<br />verName: \(versionName)<br />OSVersion: \(OSVersion)<br />Device: \(model) <br /><hr>*Enter Your Message Below Here:<br /><br /></p>", isHTML: true)
            
            present(mail,animated: true)
        }else{
            showAlertBox(title: type, msg: "There were no email account found. \nKindly setup your mail in Settings>Mail.", buttonString: "Ok")
        }
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil{
            
            controller.dismiss(animated: true, completion: nil)
            if result == .sent{
                DispatchQueue.main.async {
                    self.showAlertBox(title: "", msg: "Email Sent!", buttonString: "Ok")
                }
            }
        }
    }
    
    func resetPsw(){
        let currentUser = Auth.auth().currentUser
        var thirdParty  = Bool()
        for provider in (currentUser?.providerData)! {
            if provider.providerID == "facebook.com" ||
                provider.providerID == "google.com"{
                thirdParty = true
            }else{
                thirdParty = false
            }
        }
        
        if thirdParty{
            showAlertBox(title: "Reset Password", msg: "Password Reset are not available for Facebook or Google registered account.", buttonString: "Close")
        }else{
            userAccountRef.child(UID!).observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.hasChild("email"){
                    let userEmail = snapshot.childSnapshot(forPath: "email").value as? String
                    
                    if (userEmail != "") || (userEmail != nil) {
                        
                        let okButton = UIAlertAction(title: "Ok", style: .default , handler: { (action) in
                            Auth.auth().sendPasswordReset(withEmail: userEmail!, completion: { (error) in
                                if (error == nil){
                                    self.showAlertBox(title: "", msg: "Email sent,\nKindly check your mailbox.", buttonString: "Ok")
                                }else{
                                    self.showAlertBox(title: "", msg: "System encountered error while sending email./nKindly contact our customer service.", buttonString: "Ok")
                                }
                            })
                        })
                        
                        self.showAlertBoxWithAction(title: "Reset Password", msg: "An email will be sent to your registered email address to reset your password", buttonString: "Ok", buttonAction: okButton)
                        
                    }
                }
            }
        }
        
    }
}
