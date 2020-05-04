//
//  LoginViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/30/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn
import RevealingSplashView
import Crashlytics

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tncLabel         : UILabel!
    @IBOutlet weak var fbloginBtn       : UIButton!
    @IBOutlet weak var googleloginBtn   : UIButton!
    @IBOutlet weak var emailoginBtn     : UIButton!
    @IBOutlet weak var createAccBtn     : UIButton!
    @IBOutlet weak var titleText        : UITextView!
    @IBOutlet weak var descripText      : UITextView!
    @IBOutlet weak var loginScrollView  : UIScrollView!
    @IBOutlet weak var loginPageControl : UIPageControl!

    
    var url = String()
    var fromLogout = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Text Setup
        emailoginBtn.setTitle(Utilities.text(forKey: "label_login"), for: .normal)
        fbloginBtn.setTitle(Utilities.text(forKey: "label_fb"), for: .normal)
        googleloginBtn.setTitle(Utilities.text(forKey: "label_google"), for: .normal)
        createAccBtn.setTitle(Utilities.text(forKey: "label_anonymous"), for: .normal)
        
        let normalAttString    = NSMutableAttributedString(string:Utilities.text(forKey: "msg_tnc"))
        let tncAttString       = NSMutableAttributedString(string:Utilities.text(forKey: "label_tnc"))
        let policyAttString    = NSMutableAttributedString(string:Utilities.text(forKey: "label_privatepolicy"))
        
        
        if let tncRange = normalAttString.string.range(of: "@"){
            
            let range1 = NSRange(tncRange, in: normalAttString.string)
            
            tncAttString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, tncAttString.length))
            tncAttString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue , range: NSMakeRange(0, tncAttString.length))
            tncAttString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.white, range: NSMakeRange(0, tncAttString.length))
            
            normalAttString.replaceCharacters(in: range1, with: tncAttString)
            
            let newAttStr   = normalAttString
            if let ppRange  = newAttStr.string.range(of: "#"){
                let range2  = NSRange(ppRange, in: normalAttString.string)
                
                policyAttString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, policyAttString.length))
                policyAttString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue , range: NSMakeRange(0, policyAttString.length))
                policyAttString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.white, range: NSMakeRange(0, policyAttString.length))
                newAttStr.replaceCharacters(in: range2, with: policyAttString)
                
                let newText = NSMutableAttributedString(attributedString: newAttStr)
                tncLabel.attributedText = newText
            }
        }
        
        //Tnc & Policy Tapped
        let TnCTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsTapped(_:)))
        tncLabel.addGestureRecognizer(TnCTapGestureRecognizer)
        tncLabel.isUserInteractionEnabled = true
        
        //Splash View
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Apps_transparent_logo")!,iconInitialSize: CGSize(width: 130, height: 130), backgroundColor: UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1.00))
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.duration = 1.5
        revealingSplashView.useCustomIconColor = false
        revealingSplashView.startAnimation()
        
        //Nav Bar
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
        
        //Scroll View Setup
//        loginScrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
//        let scrollViewWidth:CGFloat     = self.loginScrollView.frame.width
//        let scrollViewHeight:CGFloat    = self.loginScrollView.frame.height
        
        let viewHeight  = self.view.frame.height
        let viewWidth   = self.view.frame.width
        
        //JS
        let xposition = view.frame.width
        
        let imgOne = ImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        imgOne.image = UIImage(named: "loginHome")
        imgOne.contentMode = .scaleToFill
        
        let imgTwo = ImageViewWithGradient(frame: CGRect(x: xposition, y: 0, width: viewWidth, height: viewHeight))
        imgTwo.image = UIImage(named: "loginApply")
        imgTwo.contentMode = .scaleToFill
        
        let imgThree = ImageViewWithGradient(frame: CGRect(x: xposition * 2, y: 0, width: viewWidth, height: viewHeight))
        imgThree.image = UIImage(named: "loginChat")
        imgThree.contentMode = .scaleToFill
        
        let imgFour = ImageViewWithGradient(frame: CGRect(x: xposition * 3, y: 0, width: viewWidth, height: viewHeight))
        imgFour.image = UIImage(named: "loginNearby")
        imgFour.contentMode = .scaleToFill
        
        loginScrollView.addSubview(imgOne)
        loginScrollView.addSubview(imgTwo)
        loginScrollView.addSubview(imgThree)
        loginScrollView.addSubview(imgFour)
        
//        loginScrollView.contentSize = CGSize(width: self.loginScrollView.frame.width * 4, height: 1.0)
        loginScrollView.contentSize.width   = viewWidth * CGFloat(4)
        loginScrollView.delegate            = self
        loginPageControl.currentPage        = 0
        
        //Button UI Setup
        fbloginBtn.layer.cornerRadius       = 20
        googleloginBtn.layer.cornerRadius   = 20
        createAccBtn.layer.cornerRadius     = 20
        
        emailoginBtn.backgroundColor    = UIColor.clear
        createAccBtn.layer.borderWidth  = 2.0
        createAccBtn.layer.borderColor  = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        
        GIDSignIn.sharedInstance().uiDelegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.hideToastActivity()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == AppConstant.segueIdentifier_ShowWebView){
            let vc = segue.destination as! WebViewViewController
            vc.url = url
        }
    }
    
    
    @IBAction func loginAnonymousPressed(_ sender: Any) {
        Auth.auth().signInAnonymously { (user, error) in
            AppDelegate.instance().showActivityIndicator()
            if let error = error {
                print("anonymouse error = \(error)")
                AppDelegate.instance().dismissActivityIndicator()
                self.showAlertBox(title: "An error occured. Please try again later", msg: "", buttonString: "Ok, Got It!")
            }
            else {
                print("Signed in Anonymously")
                AppDelegate.instance().dismissActivityIndicator()
                
                let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func googlelogin_Pressed(_ sender: Any) {
        if ReachabilityTest.isConnectedToNetwork(){
            //Have Internet
            GIDSignIn.sharedInstance().signIn()
        }else{
            //No Internet
            noInternetAlert()

        }
    }
    
    
    @IBAction func fblogin_Pressed(_ sender: Any) {
        
        if ReachabilityTest.isConnectedToNetwork(){
            //Have Internet

            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
                
                
                if err != nil{
                    print("Custon login fb failed")
                    self.view.makeToast(err?.localizedDescription)
                    return
                }else if (result?.isCancelled)!  {
                    //Decline or Permission denied
                    self.view.makeToast("Facebook Login Access Denied")
                    
                }else{
                    //Permission Granted
                    let accessToken = FBSDKAccessToken.current()
                    
                    guard let accessTokenString = accessToken?.tokenString! else{
                        return
                    }
                    
                    let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                    
                    Auth.auth().signIn(with: credentials, completion: { (user, error) in
                        
                        AppDelegate.instance().showActivityIndicator()
                        
                        if error != nil{
                            print(error!.localizedDescription)
                            AppDelegate.instance().dismissActivityIndicator()
                            self.showAlertBox(title: "Login", msg: "System encountered error while connecting with Facebook.\nPlease try again.", buttonString: "Dismiss")
                            return
                        }
                        
                        guard let uid = user?.uid else{
                            print("uid stop here")
                            AppDelegate.instance().dismissActivityIndicator()
                            self.showAlertBox(title: "Login", msg: "System encountered error while connecting with Facebook.\nPlease try again.", buttonString: "Dismiss")
                            return
                        }
                        
                        if user?.uid != ""{
                            
                            let myRootRef   = Database.database().reference()
                            let userRef     = myRootRef.child("UserAccount").child(uid)
                            
                            let fbID        = FBSDKAccessToken.current().userID
                            let userName    = user?.displayName
                            let userEmail   = user?.email
                            let userID      = user?.uid
                            let userProvider = user?.providerID
                            let userImage   = "http://graph.facebook.com/"+fbID!+"/picture?type=large&width=1080"
                            
                            var newUserAccountInfo = [:] as [String : Any]
                            
                            newUserAccountInfo["name"] = userName!
                            newUserAccountInfo["id"] = userID!
                            newUserAccountInfo["image"] = userImage
                            newUserAccountInfo["provider"] = "facebook"
                            
                            if userEmail != nil{
                                newUserAccountInfo["email"] = userEmail!
                            }
                            Database.database().reference().child("UserAccount").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                                if !snapshot.exists(){
                                    print("[Check New User]: This Is New User.\n")
                                    let preference = UserDefaults.standard
                                    let newUserKey  = "newUser"
                                    preference.setValue(true, forKey: newUserKey)
                                    userRef.updateChildValues(newUserAccountInfo, withCompletionBlock: { (error, ref) in

                                        AppDelegate.instance().dismissActivityIndicator()
                                        
                                        let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
                                        
                                        self.present(vc, animated: true, completion: nil)
                                    })
                                    
                                }else{
                                    userRef.updateChildValues(["provider": "facebook"])
                                    print("[Check New User]: UID Exist in DB , Old User!\n")
                                    AppDelegate.instance().dismissActivityIndicator()
                                    
                                    let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
                                    
                                    self.present(vc, animated: true, completion: nil)
                                }
                            })
                            
                        }
                    })
                }
            }
        }else{
            print(["[Facebook Login]: No Internet Connection"])
            AppDelegate.instance().dismissActivityIndicator()
            noInternetAlert()
        }
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        loginPageControl.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0{
            titleText.text = Utilities.text(forKey: "login_title1")
            descripText.text = Utilities.text(forKey: "login_msg1")
            
        }else if Int(currentPage) == 1{
            titleText.text = Utilities.text(forKey: "login_title2")
            descripText.text = Utilities.text(forKey: "login_msg2")
            
        }else if Int(currentPage) == 2{
            titleText.text = Utilities.text(forKey: "login_title3")
            descripText.text = Utilities.text(forKey: "login_msg3")
            
        }else {
            titleText.text = Utilities.text(forKey: "login_title4")
            descripText.text = Utilities.text(forKey: "login_msg4")
        }
        
    }
    
    func completeMySignIn(id: String, userinfo: Dictionary<String, String>){
        
        print("completesignind")
        
        let myRootRef = Database.database().reference()
        
        let userRef = myRootRef.child("UserAccount").child(id)
        
        userRef.updateChildValues(userinfo)
        
        let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
        
        self.present(vc, animated: true, completion: nil)
    
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logout d")
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        
        let vc = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "TabBarId")
        
        self.view.makeToast("Login Successful")
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    

    
    @objc func termsAndConditionsTapped(_ gestureRecognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
        let labelTxt = tncLabel.text! as NSString
        let tnc = labelTxt.range(of: Utilities.text(forKey: "label_tnc"))
        let pp  = labelTxt.range(of: Utilities.text(forKey: "label_privatepolicy"))

        
        if gestureRecognizer.didTapAttributedTextInLabel(label: tncLabel, inRange: tnc){
            url = AppConstant.URL_termsAndConditions
            self.performSegue(withIdentifier: AppConstant.segueIdentifier_ShowWebView, sender: self)

        }else if gestureRecognizer.didTapAttributedTextInLabel(label: tncLabel, inRange: pp){
            url = AppConstant.URL_privacyPolicy
            self.performSegue(withIdentifier: AppConstant.segueIdentifier_ShowWebView, sender: self)
        }
    }
    
}
extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        // Adjust for multiple lines of text
//        let lineModifier = Int(ceil(locationOfTouchInLabel.y / label.font.lineHeight)) - 1
//        let rightMostFirstLinePoint = CGPoint(x:labelSize.width, y: 0)
//        let charsPerLine = layoutManager.characterIndex(for: rightMostFirstLinePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        let adjustedRange = indexOfCharacter + (lineModifier * charsPerLine)

        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
