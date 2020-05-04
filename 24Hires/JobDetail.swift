//
//  JobDetail.swift
//  JobIn24
//
//  Created by MacUser on 20/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks
import FirebaseDatabase
import NVActivityIndicatorView
import Toast_Swift
import SKPhotoBrowser

class JobDetail: UIViewController {
    
    @IBOutlet weak var saveapplyStackView: UIStackView!
    
    @IBOutlet weak var appliedStackView: UIStackView!
    
    @IBOutlet weak var shortlistedStackView: UIStackView!
    
    @IBOutlet weak var hiredStackView: UIStackView!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBOutlet weak var postImage: ImageViewWithGradient!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDate: UILabel!
    
    @IBOutlet weak var postWages: UILabel!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var postCategory: UILabelPadding!
    
    @IBOutlet weak var postCompany: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var postLocation: UILabel!
    
    @IBOutlet weak var messageBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var timeagoLbl: UILabel!
    
    @IBOutlet weak var mapViewImg: UIImageView!
    
    @IBOutlet weak var streetViewImg: UIImageView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var closedStackView: UIStackView!
    
    @IBOutlet weak var rejectedStackView: UIStackView!
    
    @IBOutlet weak var rejectedBtn: UIButton!
    
    @IBOutlet weak var rejectedNoReApply: UIStackView!
    
    @IBOutlet weak var calendarImgtoTop: NSLayoutConstraint!
    
    @IBOutlet weak var calendarLbltoTop: NSLayoutConstraint!
    
    
    
    var stringstartdate: String!
    
    var city: String!
    
    var posttitle: String!
    
    var postdesc: String!
    
    var postcompany: String!
    
    var postid: String!
    
    var closedpost: String!
    
    var jobpostImage: String!
    
    var jobowneruid: String!
    
    var jobownerimage: String!
    
    var jobownername: String!
    
    var ownuserid: String!
    
    var ownuserName: String!
    
    var ownuserImage: String!
    
    var latitude: Double!
    var longitude: Double!
    
    
    var shortlink: URL?
    
    let userReportRef = Database.database().reference().child("UserReport")

    
    @IBAction func backPressed(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        
        //self.dismissDetail()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func chatPressed(_ sender: UIButton) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get JobDetail Anonymouse User")
                showUserAnonymousDialog()
            }
            else {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Start", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "InsideChatViewController") as! InsideChatViewController2
                nextViewController.hidesBottomBarWhenPushed = true
                
                nextViewController.receiverID = jobowneruid
                nextViewController.receiverImage = jobownerimage
                nextViewController.receiverName = jobownername
                nextViewController.ownerID = ownuserid
                nextViewController.ownerName = ownuserName
                nextViewController.ownerImage = ownuserImage
                
                if (self.ownuserid != nil && self.ownuserName != nil && self.ownuserImage != nil
                    && self.jobowneruid != nil && self.jobownername != nil && self.jobownerimage != nil) {
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        }
 
    }
    
    
    @objc func userImageClicked() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OtherUserProfileViewController") as! OtherUserProfileViewController
        
        nextViewController.userID = self.jobowneruid
        nextViewController.userName =  self.jobownername
        
        if (self.jobowneruid != nil) {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
    
    @objc func postImageClicked() {
        
        if (self.jobpostImage != nil) {
            
            if(self.jobpostImage != "0" && self.jobpostImage != "1" && self.jobpostImage != "2"){
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImageURL(jobpostImage!)
                photo.shouldCachePhotoURLImage = true
                images.append(photo)
                
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: {})
            }
        }
    }
    
    @objc func mapImageClicked() {
        
        if(self.latitude != nil && self.longitude != nil){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
            let locationViewController = storyBoard.instantiateViewController(withIdentifier: "JobLocationViewController") as! JobLocationViewController
            locationViewController.latitude = self.latitude
            locationViewController.longitude = self.longitude
            locationViewController.jobtitle = self.posttitle
            self.present(locationViewController, animated:true, completion:nil)
        }
    }
    
    @objc func streetviewImageClicked() {
        
        if(self.latitude != nil && self.longitude != nil){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
            let locationViewController = storyBoard.instantiateViewController(withIdentifier: "StrtViewViewController") as! StrtViewViewController
            locationViewController.latitude = self.latitude
            locationViewController.longitude = self.longitude
            self.present(locationViewController, animated:true, completion:nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLoadingScreen()
        
        self.postTitle.sizeToFit()
        self.postCategory.sizeToFit()
        self.postDescrip.sizeToFit()
        self.postDate.sizeToFit()
        self.postWages.sizeToFit()
        self.postCompany.sizeToFit()
        self.postLocation.sizeToFit()
        
        self.rejectedBtn.layer.masksToBounds = false
        self.rejectedBtn.layer.shadowRadius = 3.0
        self.rejectedBtn.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.rejectedBtn.layer.shadowOffset = CGSize(width: 0, height:3)
        self.rejectedBtn.layer.shadowOpacity = 1.0
        
        self.applyBtn.layer.masksToBounds = false
        self.applyBtn.layer.shadowRadius = 3.0
        self.applyBtn.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.applyBtn.layer.shadowOffset = CGSize(width: 0, height:3)
        self.applyBtn.layer.shadowOpacity = 1.0
        
        self.postCategory.layer.cornerRadius = 10
        self.postCategory.layer.masksToBounds = true
        self.postCategory.backgroundColor = UIColor.clear
        self.postCategory.layer.borderWidth = 2.0
        self.postCategory.layer.borderColor = UIColor(red: 0.00, green: 0.66, blue: 1.00, alpha: 1.0).cgColor
        
        self.messageBtn.layer.cornerRadius = 15
        self.messageBtn.layer.masksToBounds = false
        self.messageBtn.layer.shadowRadius = 3.0
        self.messageBtn.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.messageBtn.layer.shadowOffset = CGSize(width: 0, height:3)
        self.messageBtn.layer.shadowOpacity = 1.0
        
        self.saveBtn.layer.borderWidth = 2.0
        self.saveBtn.layer.borderColor = UIColor(red: 0.00, green: 0.66, blue: 1.00, alpha: 1.0).cgColor
        
        self.userImage.layer.cornerRadius = userImage.bounds.size.width/2
        self.userImage.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JobDetail.userImageClicked))
        self.userImage.addGestureRecognizer(tapGestureRecognizer)
        self.userImage.isUserInteractionEnabled = true
        
        let PostImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JobDetail.postImageClicked))
        self.postImage.addGestureRecognizer(PostImageGestureRecognizer)
        self.postImage.isUserInteractionEnabled = true
        
        let mapImgGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JobDetail.mapImageClicked))
        self.mapViewImg.addGestureRecognizer(mapImgGestureRecognizer)
        self.mapViewImg.isUserInteractionEnabled = true
        
        let streetviewImgGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JobDetail.streetviewImageClicked))
        self.streetViewImg.addGestureRecognizer(streetviewImgGestureRecognizer)
        self.streetViewImg.isUserInteractionEnabled = true
        
        
        let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width: self.streetViewImg.bounds.size.width, height: self.streetViewImg.bounds.size.height))
        overlay.backgroundColor = UIColor(red:0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        self.streetViewImg.addSubview(overlay)
        
        overlay.topAnchor.constraint(equalTo: streetViewImg.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: streetViewImg.bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: streetViewImg.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: streetViewImg.trailingAnchor).isActive = true
        
        let sysActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action , target: self, action: #selector(JobDetail.clickButton))
        self.navigationItem.rightBarButtonItem  = sysActionBarButtonItem

//        let actionUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "job_action.png"), style: .plain, target: self, action: #selector(JobDetail.clickButton))

        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if !currentUser!.isAnonymous {
                print("[Get JobDetail Anonymouse User")
                getMyNameandImage()
            }
            
            ownuserid = currentUser?.uid
            
            getMyNameandImage()
            
            let ref = Database.database().reference()
            
            ref.child("Job").child(self.city).child(postid).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                if let getData = snapshot.value as? [String:Any]{
                    
                    self.jobpostImage = getData["postimage"] as? String
                    
                    self.posttitle = getData["title"] as? String
                    
                    let postCategory = getData["category"] as? String
                    
                    self.postdesc = getData["desc"] as? String
                    
                    let postDate = getData["date"] as? String
                    
                    let postWages = getData["wages"] as? String
                    
                    self.postcompany = getData["company"] as? String
                    
                    let postLocation = getData["fulladdress"] as? String
                    
                    let ownerimage = getData["userimage"] as? String
                    
                    let ownername = getData["username"] as? String
                    
                    self.jobowneruid = getData["uid"] as? String
                    
                    self.getJobOwnerNameandImage(uid: self.jobowneruid, name: ownername!, image: ownerimage!)
                    
                    let lat = getData["latitude"] as! Double
                    self.latitude = lat
                    let long = getData["longitude"] as! Double
                    self.longitude = long
                    
                    let t = getData["time"] as? TimeInterval
                    
                    self.closedpost = getData["closed"] as? String
                    
                    let poststartdate = NSDate(timeIntervalSince1970: t!/1000)
                    
                    self.stringstartdate = TimeAgoHelper.timeAgoSinceDate(poststartdate as Date, currentDate: Date(), numericDates: true)
                    
                    
                    self.postImage.sd_setImage(with: URL(string: self.jobpostImage!), placeholderImage: UIImage(named: "addphoto_darker_bg"))
                    
                    
                    self.postTitle.text = self.posttitle
                    self.postCategory.text = postCategory
                    self.postDescrip.setLineHeight(lineHeight: 5, textstring: self.postdesc)
                    
                    if(postDate != "none"){
                        self.postDate.setLineHeight(lineHeight: 5, textstring: postDate!)
                        //self.postDate.text = postDate
                    }
                    else{
                        self.postDate.text = "No Specified Date"
                    }
                    
                    if(postWages != "none"){
                        self.postWages.setLineHeight(lineHeight: 5, textstring: postWages!)
                        //self.postWages.text = postWages
                    }
                    else{
                        self.postWages.text = "Wages are not disclosed"
                    }
                    
                    self.postCompany.text = self.postcompany
                    self.postLocation.text = postLocation
                    self.timeagoLbl.text = "Created \(self.stringstartdate!) by"
                    
                    
                    if(lat != nil && long != nil){
                        
                        let streetURL:String! = "https://maps.googleapis.com/maps/api/streetview?size=400x200&location=\(lat),\(long)&fov=90&heading=235&pitch=10"
                        
                        let mapURL:String! = "http://maps.google.com/maps/api/staticmap?center=\(lat),\(long)&markers=color:0xff0000%7Clabel:%7C\(lat),\(long)&zoom=14&size=400x200"
                        
                        self.streetViewImg.downloadprofileImage(from: streetURL!)
                        self.mapViewImg.downloadprofileImage(from: mapURL!)
                        
                    }
                    
                    if (self.jobowneruid == self.ownuserid) {
                        
                        self.saveapplyStackView.isHidden = true
                        self.saveBtn.isEnabled = false
                        self.applyBtn.isEnabled = false
                        self.messageBtn.isHidden = true
                        
                        self.calendarImgtoTop.constant = 20
                        self.calendarLbltoTop.constant = 20
                        
                        if(self.closedpost != nil && self.closedpost == "true"){
                            self.closedView.isHidden = false
                            self.closedStackView.isHidden = false
                        }
                        else {
                            self.closedView.isHidden = true
                            self.closedStackView.isHidden = true
                        }
                        
                    }
                    else {
                        if(self.closedpost != nil && self.closedpost == "true"){
                            
                            self.closedView.isHidden = false
                            self.closedStackView.isHidden = false
                            
                            self.saveapplyStackView.isHidden = true
                            self.saveBtn.isEnabled = false
                            self.applyBtn.isEnabled = false
                            self.messageBtn.isHidden = true
                            
                        }
                        else {
                            
                            self.closedView.isHidden = true
                            self.closedStackView.isHidden = true
                            self.checkJobStatus()
                            
                        }
                    }
                }
                
                self.removeLoadingScreen()
                
            })
            
            ref.removeAllObservers()

            
        }

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShareJob() {
        
        AppDelegate.instance().showActivityIndicator()
        
        // general link params
        let linkString = "https://24hires.com/?jobpost="+self.postid+","+self.city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let link = URL(string: linkString) else {
            
            return
            
        }
        print("share link3 = \(link)")
        let components = DynamicLinkComponents(link: link, domain: "vh87a.app.goo.gl")
        
        let bundleID = "com.jobin24.JobIn24"
        // iOS params
        let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
        iOSParams.minimumAppVersion = "1.0"
        iOSParams.appStoreID = "1375741647"
        iOSParams.fallbackURL = URL(string: "https://24hires.com")
        components.iOSParameters = iOSParams
        
        //Android params
        let androidParams = DynamicLinkAndroidParameters(packageName: "com.zjheng.jobseed.jobseed")
        androidParams.fallbackURL = URL(string: "https://24hires.com")
        components.androidParameters = androidParams
        
        
        // social tag params
        let socialParams = DynamicLinkSocialMetaTagParameters()
        socialParams.title = self.posttitle
        socialParams.descriptionText = self.postdesc
        socialParams.imageURL = URL(string: self.jobpostImage)
        components.socialMetaTagParameters = socialParams
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        
        components.shorten { (shortURL, warnings, error) in
            if error != nil {
                print("error link2")
                return
            }
            self.shortlink = shortURL
            print("short link = \(self.shortlink?.absoluteString)")
            
            let subject = "Let's check out this job!"
            let body = "Hey, Check out this job on 24Hires"
            let coded = self.shortlink?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if let dataURL: NSURL = NSURL(string: (self.shortlink?.absoluteString)!) {
                /*if UIApplication.shared.canOpenURL(emailURL as URL) {
                 UIApplication.shared.openURL(emailURL as URL)
                 }*/
                
                let objectsToShare = [body,dataURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                AppDelegate.instance().dismissActivityIndicator()
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func clickButton() {
        // create the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { action in
            
            self.ShareJob()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
 
        }))
        
        if (self.jobowneruid != nil && self.ownuserid != nil) {
            if (self.jobowneruid != self.ownuserid) {
                alert.addAction(UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: { action in
                    
                    self.ReportJob()
                    
                }))
            }
        }
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Set the activity indicator into the main view
    func setLoadingScreen() {
        loadingBall.type = .ballPulseSync
        loadingBall.startAnimating()
        loadingBallView.isHidden = false
        loadingBallView.alpha = 1.0
        
        loadingView.isHidden = false
        
    }
    
    // Remove the activity indicator from the main view
    func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func getJobOwnerNameandImage(uid: String, name:String, image:String) {
        
        if(name != nil && image != nil){
            
            let ref = Database.database().reference()
            
            ref.child("UserAccount").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.jobownername = name
                    self.userName.text = self.jobownername
                    self.jobownerimage = image
                    self.userImage.sd_setImage(with: URL(string: self.jobownerimage), placeholderImage: UIImage(named: "userprofile_default"))
                    return
                    
                }
                
                if (snapshot.hasChild("name")){
                    if let jobownername = snapshot.childSnapshot(forPath: "name").value as? String
                    {
                        self.jobownername = jobownername
                        self.userName.text = self.jobownername
                    }
                }
                else{
                    self.jobownername = name
                    self.userName.text = self.jobownername
                }
                
                if (snapshot.hasChild("image")){
                    if let jobownerimage = snapshot.childSnapshot(forPath: "image").value as? String
                    {
                        self.jobownerimage = jobownerimage
                        self.userImage.sd_setImage(with: URL(string: self.jobownerimage), placeholderImage: UIImage(named: "userprofile_default"))
                        
                    }
                }
                else{
                    self.jobownerimage = image
                    self.userImage.sd_setImage(with: URL(string: self.jobownerimage), placeholderImage: UIImage(named: "userprofile_default"))
                }
                
            })
            
            ref.removeAllObservers()
            
        }
        
    }
    
    func getMyNameandImage() {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserAccount").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                if (snapshot.hasChild("name")){
                    if let myownname = snapshot.childSnapshot(forPath: "name").value as? String
                    {
                        self.ownuserName = myownname
                    }
                }
                if (snapshot.hasChild("image")){
                    if let myownimage = snapshot.childSnapshot(forPath: "image").value as? String
                    {
                        self.ownuserImage = myownimage
                    }
                }
                
            })
            
            ref.removeAllObservers()
            
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
    
    func ReportJob() {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get JobDetail Anonymouse User")
                showUserAnonymousDialog()
                return
            }
        }
                
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Spam", style: UIAlertActionStyle.destructive, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                self.userReportRef.child(uid!).child("Post").child("Spam").child(self.city).setValue(self.postid)
                
                self.showThankYouAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Irrelavant", style: UIAlertActionStyle.destructive, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                self.userReportRef.child(uid!).child("Post").child("Irrelavant").child(self.city).setValue(self.postid)
                
                self.showThankYouAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Inappropriate", style: UIAlertActionStyle.destructive, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                self.userReportRef.child(uid!).child("Post").child("Inappropriate").child(self.city).setValue(self.postid)
                
                self.showThankYouAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showThankYouAlert(){
        
        
        // create the alert
        let alert = UIAlertController(title: "Report Submitted", message: "Thanks for making our community better with this feedback. We will take appropriate action against abuse", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkDeletedStatus(){
        
        print("checkDeletedStatus")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("Shortlisted").child(postid).observeSingleEvent(of: .value, with: { snapshot in
                
                
                if !snapshot.exists() {
                    self.checkHired()
                    return
                    
                }
                    
                else {
                    self.saveapplyStackView.isHidden = true
                    self.shortlistedStackView.isHidden = false
                    
                }
                
            })
            
            ref.removeAllObservers()
        }
    }
    
    func checkHired(){
        
        print("checkHired")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("Hired").child(postid).observeSingleEvent(of: .value, with: { snapshot in
                
                
                if !snapshot.exists() {
                    self.checkRejectedOffer()
                    return
                    
                }
                    
                else {
                    self.saveapplyStackView.isHidden = true
                    self.hiredStackView.isHidden = false
                    
                }
                
            })
            
            ref.removeAllObservers()
        }
    }
    
    func checkRejectedOffer(){
        
        print("checkRejectedOffer")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("RejectedOffer").child(postid).observeSingleEvent(of: .value, with: { snapshot in
                
                
                if !snapshot.exists() {
                    self.checkRejected()
                    return
                    
                }
                    
                else {
                    self.saveapplyStackView.isHidden = true
                    self.rejectedNoReApply.isHidden = false
                    
                }
                
            })
            
            ref.removeAllObservers()
        }
    }
    
    func checkRejected(){
        
        print("checkRejected")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("RejectedApplied").child(self.postid).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.checkSaved()
                    return
                }
                    
                else {
                    self.saveapplyStackView.isHidden = true
                    let rejectedcount = snapshot.childrenCount
                    if (rejectedcount >= 2){
                        self.rejectedStackView.isHidden = true
                        self.rejectedNoReApply.isHidden = false
                    }
                    else if (rejectedcount < 2) {
                        self.rejectedStackView.isHidden = false
                        self.rejectedNoReApply.isHidden = true
                    }
                }
            })
            
            ref.removeAllObservers()
        }
    }
    
    func checkSaved(){
        
        print("checkSaved")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("Saved").child(self.postid).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.saveBtn.setTitle("SAVE", for: .normal)
                    return
                }
                    
                else {
                    self.saveBtn.setTitle("SAVED", for: .normal)
                }
                
            })
            
            ref.removeAllObservers()
        }
    }
    
    func checkJobStatus(){
        print("checkJobStatus")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("Applied").child(self.postid).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.checkDeletedStatus()
                    return
                    
                }
                    
                else {
                    
                    self.saveapplyStackView.isHidden = true
                    
                    if snapshot.hasChild("status") {
                        
                        let statusval = snapshot.childSnapshot(forPath: "status").value as? String
                        
                        if statusval == "applied" {
                            self.appliedStackView.isHidden = false
                        }
                        else if statusval == "appliedrejected" {
                            self.checkRejected()
                        }
                        else if statusval == "shortlisted" {
                            self.shortlistedStackView.isHidden = false
                        }
                        else if statusval == "acceptedoffer" {
                            self.hiredStackView.isHidden = false
                        }
                        else if statusval == "rejectedoffer" {
                            self.rejectedStackView.isHidden = false
                        }
                        else if statusval == "pendingoffer" {
                            self.shortlistedStackView.isHidden = false
                        }
                        else if statusval == "changedoffer" {
                            self.shortlistedStackView.isHidden = false
                        }
                        else  {
                            self.shortlistedStackView.isHidden = false
                        }
                    }
                    
                }
                
            })
            
            ref.removeAllObservers()
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let saveStatus = saveBtn.currentTitle!
        print("saveStatus \(saveStatus)")
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get JobDetail Anonymouse User")
                showUserAnonymousDialog()
                return
            }
            
            AppDelegate.instance().showActivityIndicator()
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            if (saveStatus == "SAVE") {
                
                let newSave = ref.child("UserActivities").child(uid!).child("Saved").child(postid)
                
                let negatedtime  = -1*(getCurrentMillis()/1000)
                
                let savedetails = ["negatedtime": negatedtime,
                                   "time": ServerValue.timestamp(),
                                   "title": self.postTitle.text!,
                                   "desc": self.postDescrip.text!,
                                   "company": self.postCompany.text!,
                                   "city": self.city,
                                   "postimage": self.jobpostImage
                    ] as [String : Any]
                
                newSave.setValue(savedetails,  withCompletionBlock: { (error:Error?, refx:DatabaseReference!) in
                    
                    if (error != nil) {
                        // handle an error
                    }
                    else{
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("You saved this job post!", duration: 2.0, position: .center)
                        self.saveBtn.setTitle("SAVED", for: .normal)
                    }
                })
            }
            else if (saveStatus == "SAVED"){
                ref.child("UserActivities").child(uid!).child("Saved").child(postid).removeValue(completionBlock: { (error:Error?, refx:DatabaseReference!) in
                    
                    if (error != nil) {
                        // handle an error
                    }
                    else{
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("You have un-saved this job post!", duration: 2.0, position: .center)
                        self.saveBtn.setTitle("SAVE", for: .normal)
                    }
                })
            }
        }
    }
    
    @IBAction func applyPressed(_ sender: Any) {
        
        self.Apply(condition: 1)
    }
    
    @IBAction func reapplyPressed(_ sender: Any) {
        
        // create the alert
        let alert = UIAlertController(title: "Re-Apply", message: "You have one more chance to re-apply to this job post. Do you wish to re-apply again?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Re-Apply One More", style: UIAlertActionStyle.default, handler: { action in
            
            self.Apply(condition: 2)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func Apply(condition:Int!){
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get JobDetail Anonymouse User")
                showUserAnonymousDialog()
                return
            }
            
            AppDelegate.instance().showActivityIndicator()
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            //Remove saved post
            ref.child("UserActivities").child(uid!).child("Saved").child(postid).removeValue()
            self.saveBtn.setTitle("SAVE", for: .normal)
            
            //Notification Trigger
            let newApplyNotification = ref.child("ApplyNotification").child("Applications").childByAutoId()
            let newapplykey = newApplyNotification.key
            
            let applynotificationsdetails = ["ownerUid": uid!,
                                             "receiverUid": self.jobowneruid,
                                             "ownerName": self.ownuserName
                ] as [String : Any]
            
            newApplyNotification.setValue(applynotificationsdetails)
            ref.child("UserActivities").child(self.jobowneruid).child("ApplyNotification").child(newapplykey).setValue(newapplykey)
            
            //Add as applicant to owner's applicant list
            let newUser = ref.child("UserPostedPendingApplicants").child(self.jobowneruid).child(postid).child(uid!)
            let negatedtime  = -1*(getCurrentMillis()/1000)
            
            let newApplicantsDetails = ["negatedtime": negatedtime,
                                        "time": ServerValue.timestamp(),
                                        "name": self.ownuserName,
                                        "image": self.ownuserImage,
                                        "pressed": "false"
                
                ] as [String : Any]
            
            newUser.setValue(newApplicantsDetails,  withCompletionBlock: { (error:Error?, refx:DatabaseReference!) in
                
                if (error != nil) {
                    // handle an error
                }
                else{
                    ref.child("UserActivities").child(self.jobowneruid).child("NewMainNotification").setValue("true")
                    
                    ref.child("UserActivities").child(self.jobowneruid).child("NewPosted").setValue("true")
                    
                    self.incrementapplicants()
                }
            })
            
            //Add to own applied tab
            let newApplied = ref.child("UserActivities").child(uid!).child("Applied").child(postid)
            
            let newAppliedDetails = ["negatedtime": negatedtime,
                                     "time": ServerValue.timestamp(),
                                     "title": self.posttitle,
                                     "uid": self.jobowneruid,
                                     "desc": self.postdesc,
                                     "company": self.postcompany,
                                     "city": self.city,
                                     "postimage": self.jobpostImage,
                                     "status": "applied",
                                     "pressed": "false",
                                     "closed": "false"
                
                ] as [String : Any]
            
            newApplied.setValue(newAppliedDetails,  withCompletionBlock: { (error:Error?, refx:DatabaseReference!) in
                
                if (error != nil) {
                    // handle an error
                }
                else{
                    AppDelegate.instance().dismissActivityIndicator()
                    
                    if (condition == 1) {
                        self.saveapplyStackView.isHidden = true
                        self.appliedStackView.isHidden = false
                        self.view.makeToast("You applied to this job post! Good Luck!", duration: 2.0, position: .center)
                    }
                    else if (condition == 2) {
                        self.saveapplyStackView.isHidden = true
                        self.rejectedStackView.isHidden = true
                        self.appliedStackView.isHidden = false
                        self.view.makeToast("You re-applied to this job post! Good Luck!", duration: 2.0, position: .center)
                    }
                    
                }
            })
            
            //Add to user's chat
            
            let newReceiverChatRoom = ref.child("ChatRoom").child(self.jobowneruid).child(self.jobowneruid + "_" + uid!).child("ChatList").childByAutoId()
            let newChatListKey = newReceiverChatRoom.key
            let newOwnerChatRoom = ref.child("ChatRoom").child(uid!).child(uid! + "_" + self.jobowneruid).child("ChatList").child(newChatListKey)
            
            var newChatDetails = ["negatedtime": negatedtime,
                                  "time": ServerValue.timestamp(),
                                  "actiontitle": "applied",
                                  "ownerid": uid!,
                                  "jobtitle": self.posttitle,
                                  "jobdescrip": self.postdesc,
                                  "city": self.city,
                                  "postkey": self.postid
                
                ] as [String : Any]
            
            
            ref.child("ChatList").child(uid!).child("UserList").observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    if snapshot.childSnapshot(forPath: self.jobowneruid).exists() {
                        newChatDetails["oldtime"] = snapshot.childSnapshot(forPath: self.jobowneruid).childSnapshot(forPath: "time").value
                        
                        newOwnerChatRoom.setValue(newChatDetails)
                        newReceiverChatRoom.setValue(newChatDetails)
                    }
                    else {
                        newChatDetails["oldtime"] = 0
                        
                        newOwnerChatRoom.setValue(newChatDetails)
                        newReceiverChatRoom.setValue(newChatDetails)
                    }
                }
                else {
                    newChatDetails["oldtime"] = 0
                    
                    newOwnerChatRoom.setValue(newChatDetails)
                    newReceiverChatRoom.setValue(newChatDetails)
                }
            })
        }
        
    }
    
    func incrementapplicants(){
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            let applicantref = ref.child("UserPosted").child(self.jobowneruid).child(self.postid)
            
            applicantref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                
                if var data = currentData.value as? [String: Any] {
                    var newapplicantscount = data["newapplicantscount"] as? Int ?? 0
                    newapplicantscount += 1
                    data["newapplicantscount"] = newapplicantscount
                    
                    var applicantscount = data["applicantscount"] as? Int ?? 0
                    applicantscount += 1
                    data["applicantscount"] = applicantscount
                    
                    currentData.value = data
                }
                
                return TransactionResult.success(withValue: currentData)
            }) 
            
        }
    }
}


