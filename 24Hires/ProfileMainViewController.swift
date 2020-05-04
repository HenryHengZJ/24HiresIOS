//
//  ProfileMainViewController.swift
//  JobIn24
//
//  Created by Jeekson Choong on 16/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class ProfileMainViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var loadingView          : UIView!
    @IBOutlet weak var usernameLabel        : UILabel!
    @IBOutlet weak var profileProgress      : UILabel!
    @IBOutlet weak var viewAndEditLabel     : UILabel!
    @IBOutlet weak var profileImage         : UIImageView!
    @IBOutlet weak var profilePregressBar   : UIProgressView!
    @IBOutlet weak var loadingIndicator     : NVActivityIndicatorView!


    @IBAction func myProfileButtonPressed(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Profile Anonymouse User")
                showUserAnonymousDialog()
            }
            else {
                 self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToMyProfile, sender: self)
            }
        }
       
    }
    @IBAction func pointAndRewardPressed(_ sender: Any) {
        //Coming Soon
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToPointsAndRewars, sender: self)
    }
    @IBAction func postJobPressed(_ sender: Any) {
 
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToPostJob, sender: self)
    }
    @IBAction func showcaseTalentPressed(_ sender: Any) {
        //Coming Soon
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TalentViewController") as! TalentViewController
        self.navigationController?.pushViewController(vc, animated: true)
        //self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToPointsAndRewars, sender: self)
    }
    @IBAction func howItWorksPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowItWorksViewController") as! HowItWorksViewController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true, completion: nil)
        //self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToHowItWorks, sender: self)
    }
    @IBAction func settingsPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_profileMainToSettings, sender: self)

    }
    
    var UID                 : String?
    var userName            : String?
    var profileImageString  : String?

    
    override func viewWillAppear(_ animated: Bool) {
        print("""

--------------------------------
       Profile Main Page
--------------------------------

""")
        checkInternetBeforeRun()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView(visible: true)
        viewAndEditLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupLoadingView(visible: Bool){
        if visible{
            loadingView.isHidden = false
            loadingIndicator.startAnimating()
        }else{
        
            UIView.transition(with: loadingView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.loadingView.isHidden = true
            }) { (true) in
                self.loadingIndicator.stopAnimating()
            }
        }
        
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
    
    func getUID(){
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                self.setupLoadingView(visible: false)
                self.usernameLabel.text = "Anonymous User"
            }
            else {
                UID = (currentUser?.uid)!
                print("[Profile Main Page] UID: \(String(describing: UID))")
                getProfileData()
                getProfileProgress()
            }
        }
        
    }
    
    func checkInternetBeforeRun(){
        print("[CHECK INTERNET CONNECTION]\n=========================================\n")
        if ReachabilityTest.isConnectedToNetwork() {
            print("[Check Internet Connection]: Internet connection available")
            getUID()
        }
        else{
            print("[Check Internet Connection]: No internet connection")
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
                self.checkInternetBeforeRun()
            }
            noInternetAlertForceRetry(buttonAction: retryAction)
        }
    }
    
    
    func getProfileData(){
        let refUserAccount      = Database.database().reference().child("UserAccount")
        let refUserInfo         = Database.database().reference().child("UserInfo")
        
        if (UID != ""){
            
            //Get NAME From User Info
            refUserInfo.child(self.UID!).child("Name").observeSingleEvent(of: .value, with: { (snapshot) in
               
                if snapshot.exists() {
                    self.userName = snapshot.value as? String
                    self.usernameLabel.text = self.userName
                    print("[Get User Profile Data] Username: \(String(describing: self.userName))")
                }
                
                //If no, fetch UserAccount
                else {
                    refUserAccount.child(self.UID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            if snapshot.hasChild("name"){
                                self.userName = snapshot.childSnapshot(forPath: "name").value as? String
                                print("[Get User Profile Data] Username: \(String(describing: self.userName))")
                                self.usernameLabel.text = self.userName
                            }
                        }
                    })
                }
            })
        
            
            //Get USERIMAGE From User Info
            refUserInfo.child(self.UID!).child("UserImage").observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.exists() {
                    self.profileImageString = snapshot.value as? String
                    
                    print("[Get User Profile Data] Profile Image: \(String(describing: self.profileImageString))")
                    
                    if self.profileImageString != "" || self.profileImageString != nil{
                        
                        if self.profileImageString == "default"{
                            //Set Default Picture
                            print("[Get Profile Image]  : No Image, Set to default\n")
                            self.profileImage.image = UIImage(named: "userprofile_default")
                        }else{
                            //Set Obtained Profile Picture By Link
                            self.profileImage.sd_setImage(with: URL(string: self.profileImageString!), placeholderImage: UIImage(named: "userprofile_default"))
                        }
                        self.setupLoadingView(visible: false)
                        
                    }
                }
                
                //If no, fetch UserAccount
                else {
                    refUserAccount.child(self.UID!).observeSingleEvent(of: .value, with: { (snapshot2) in
                        if snapshot2.exists() && snapshot2.hasChild("image"){
                            print("[Get Profile Picture]    : Profile Picture Found In User Account.\n")
                            print(snapshot2)
                            self.profileImageString = snapshot2.childSnapshot(forPath: "image").value as? String
                            
                            if self.profileImageString != "" || self.profileImageString != nil{
                                
                                if self.profileImageString == "default"{
                                    //Set Default Picture
                                    print("[Set Default Profile Picture]")
                                    self.profileImage.image = UIImage(named: "userprofile_default")
                                }else{
                                    //Set Obtained Profile Picture By Link
                                    print("[Set Profile Picture by Link]\n")
                                    print(self.profileImageString!)
                                    self.profileImage.sd_setImage(with: URL(string: self.profileImageString!), placeholderImage: UIImage(named: "userprofile_default"))
                                }
                                self.setupLoadingView(visible: false)
                            }
                        }
                    })
                }
                
            })
            
        }
    }
    
    func getProfileProgress(){
        let userInfoRef         = Database.database().reference().child("UserInfo")
        var profileCompletionScore : Double = 0
        
        userInfoRef.child(self.UID!).observeSingleEvent(of: .value) { (snapshot) in
            print("Get Progress")
            print(snapshot)
            if snapshot.hasChild("WorkExp1"){
                profileCompletionScore += 10
                print(profileCompletionScore)
            }
            if snapshot.hasChild("Gender"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            if snapshot.hasChild("Age"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            if snapshot.hasChild("Email"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            if snapshot.hasChild("Education"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            if snapshot.hasChild("Language"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            if snapshot.hasChild("About"){
                profileCompletionScore += 10
                print(profileCompletionScore)
                
            }
            self.setProfileProgressBar(scoreObtained: profileCompletionScore)
        }
    }
    
    func setProfileProgressBar(scoreObtained: Double){
        print("========================================\nProfile Score\n========================================")
        let finalScore = Double(scoreObtained/70)
        let percentage  = finalScore * 100
        
        if percentage < 25{
            //Red Zone
            profilePregressBar.progressTintColor = UIColor.init(red: 242/255, green: 50/255, blue: 21/255, alpha: 1.0)
            profileProgress.textColor = UIColor.init(red: 242/255, green: 50/255, blue: 21/255, alpha: 1.0)
        }else if percentage >= 25 && percentage < 75 {
            //Yellow Zone
            profilePregressBar.progressTintColor = UIColor.init(red: 247/255, green: 181/255, blue: 26/255, alpha: 1.0)
            profileProgress.textColor = UIColor.init(red: 247/255, green: 181/255, blue: 26/255, alpha: 1.0)
        }else if percentage >= 75{
            //Green Zone
            profilePregressBar.progressTintColor = UIColor.init(red: 109/255, green: 218/255, blue: 97/255, alpha: 1.0)
            profileProgress.textColor = UIColor.init(red: 16/255, green: 149/255, blue: 2/255, alpha: 1.0)
        }
        
        DispatchQueue.main.async {
            self.profilePregressBar.setProgress(Float(finalScore), animated: true)
            self.profileProgress.text    = "\(Int(percentage))%"
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
