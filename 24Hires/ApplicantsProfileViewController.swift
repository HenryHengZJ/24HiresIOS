//
//  ApplicantsProfileViewController.swift
//  JobIn24
//
//  Created by MacUser on 20/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import AAViewAnimator
import SKPhotoBrowser


class ApplicantsProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlet & IBAction & Declaration
    @IBOutlet weak var profileTableView : UITableView!
    @IBOutlet weak var coverImage       : UIImageView!
    @IBOutlet weak var profileName      : UILabel!
    @IBOutlet weak var profileimage     : UIImageView!
    @IBOutlet weak var profileLocation  : UILabel!
    @IBOutlet weak var reviewLabel      : UILabel!
    @IBOutlet weak var reviewStarView   : CosmosView!
    @IBOutlet weak var chatView         : UIView!
    @IBOutlet weak var reviewView       : UIView!
    @IBOutlet weak var actionView       : UIView!
    @IBOutlet weak var messageButton    : UIButton!
    @IBOutlet weak var acceptButton     : UIButton!
    @IBOutlet weak var rejectButton     : UIButton!
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        //Check Internet
        if ReachabilityTest.isConnectedToNetwork(){
            //Check status type
            if status == .shortlisted{
                /*let shortlistAction = UIAlertAction(title: "SHORTLIST", style: .default) { (action) in
                    self.shortlistApplicant()
                }
                showAlertBoxWithAction(title: "Are you sure you want to shortlist \(userName!)", msg: "", buttonString: "CANCEL", buttonAction: shortlistAction)*/
                
                // create the alert
                let alert = UIAlertController(title: "Are you sure you want to shortlist \(userName!)", message: "", preferredStyle: .alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Shortlist", style: UIAlertActionStyle.default, handler: { action in
                    
                    self.shortlistApplicant()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                   
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            }else{
              
                print("HIRE BUTTON PRESSED")
                self.goToHireForm()
               
            }
        }else{
            noInternetAlert()
        }
       
    }
    
    @IBAction func rejectButtonPressed(_ sender: UIButton) {
        
        if ReachabilityTest.isConnectedToNetwork(){
            
            // create the alert
            let alert = UIAlertController(title: "Are you sure you want to reject \(userName!)", message: "", preferredStyle: .alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.default, handler: { action in
                
                self.rejectApplicant()
                self.rejectButton.setTitle("REJECTED", for: .normal)
                self.rejectButton.isEnabled = false
                self.acceptButton.isHidden = true
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in

            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }else{
            noInternetAlert()
        }
        
    }
    
    @IBAction func ChatPressed(_ sender: UIButton) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Applicant Anonymouse User")
                showUserAnonymousDialog()
                return
            }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Start", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "InsideChatViewController") as! InsideChatViewController2
        //        nextViewController.hidesBottomBarWhenPushed = true
        
        nextViewController.receiverID       = userID
        nextViewController.receiverImage    = usercoverImage
        nextViewController.receiverName     = userName
        nextViewController.ownerID          = ownerID
        nextViewController.ownerName        = ownerName
        nextViewController.ownerImage       = ownerImage
        
        if (self.userID != nil && self.usercoverImage != nil && self.userName != nil
            && self.ownerID != nil && self.ownerName != nil && self.ownerImage != nil) {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    enum ApplicationStatus {
        case shortlisted, hired, completed
    }
    
    
    var usercoverImage      : String?
    var userprofileImage    : String?
    var userID              : String!
    var userName            : String!
    
    var ownerID     : String!
    var ownerName   : String!
    var ownerImage  : String!
    var postkey     : String!
    var jobCity     : String!
    
    var jobTitle    = String()
    var jobDesc     = String()
    

    var status          = ApplicationStatus.shortlisted
    var countValue      = 0
    var segmentindex    = 0
    var segmentint      = 0

    var reviewposts = [UserReview]()
    var posts       = [Post]()
    
    var profileabout        = ["none"]
    var profileemail        = ["none"]
    var profilephone        = ["none"]
    var profileeducation    = ["none"]
    var profilelanguages    = ["none"]
    var profileGender       = ["none"]
    var profileBirthdate    = ["none"]
    var profileWeight       = ["none"]
    var profileHeight       = ["none"]
    
    var profileworktitle    = ["none","none","none","none","none"]
    var profileworkplace    = ["none","none","none","none","none"]
    var profileworklength   = ["none","none","none","none","none"]
    
    var reviewcount5: Double?
    var reviewcount4: Double?
    var reviewcount3: Double?
    var reviewcount2: Double?
    var reviewcount1: Double?
    var totalreviewcount: Double? = 0.0
    
    var refreshControl: UIRefreshControl!
    
    let userPostedRef       = Database.database().reference().child("UserPosted")
    let userActivitiesRef   = Database.database().reference().child("UserActivities")
    let chatRoomRef         = Database.database().reference().child("ChatRoom")
    let userChatListRef     = Database.database().reference().child("UserChatList")
    let userReportRef       = Database.database().reference().child("UserReport")

    let userPostedShortlistedApplicantsRef  = Database.database().reference().child("UserPostedShortlistedApplicants")
    let userPostedPendingApplicants         = Database.database().reference().child("UserPostedPendingApplicants")
    let userShortlistedNotification         = Database.database().reference().child("ShortlistedNotification")


    //MARK:- Override Func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("==================== Applicant Status =====================\n\(status)\n")
        print("[PostKey]: \(postkey!)")
        print("[userID] : \(userID)")
        
        
        if (self.userName != nil){
            self.title = self.userName
        }
        else {
            self.title = "Profile"
        }
        
        //Set button Title
        checkApplicantStatus()
        
        //show and hide message button
        checkSameUID()
        
        //load job details
        loadAppliedJobDetails()
        
        // Do any additional setup after loading the view.
        profileTableView.dataSource = self
        profileTableView.delegate = self
        
        // dynamic table view cell height
        profileTableView.estimatedRowHeight = profileTableView.rowHeight
        profileTableView.rowHeight = UITableViewAutomaticDimension
        
        chatView.layer.cornerRadius     = 10
        chatView.clipsToBounds          = true
        
        chatView.layer.masksToBounds    = false
        chatView.layer.shadowRadius     = 3.0
        chatView.layer.shadowColor      = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        chatView.layer.shadowOffset     = CGSize(width: 0, height:3)
        chatView.layer.shadowOpacity    = 1.0

        profileimage.layer.cornerRadius = profileimage.frame.size.width/2
        profileimage.clipsToBounds = true
        profileimage.layer.borderWidth = 2.0
        profileimage.layer.borderColor = UIColor.white.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(ApplicantsProfileViewController.updateStatus(_:)), name: Notification.Name("updateStatus"), object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ApplicantsProfileViewController.userProfileImageClicked))
        self.profileimage.addGestureRecognizer(tapGestureRecognizer)
        self.profileimage.isUserInteractionEnabled = true
        
        let coverimgtapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ApplicantsProfileViewController.userCoverImageClicked))
        self.coverImage.addGestureRecognizer(coverimgtapGestureRecognizer)
        self.coverImage.isUserInteractionEnabled = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        actionView.aa_animate(duration: 1.5, springDamping: .slight, animation: .fromBottom) { isAnimating in
            if isAnimating {
                //VIEW is animating
            }
            else {
                //VIEW animation finish
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        profileTableView.addSubview(refreshControl)
        
        
        let sysActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action , target: self, action: #selector(self.clickButton))
        self.navigationItem.rightBarButtonItem  = sysActionBarButtonItem

        
        if(self.userID != nil){
            
            loadPictureName(uid:self.userID)
            
            loadLocation(uid:self.userID)
            
            loadReviewStar(uid:self.userID)
            
            loadApplicantUserProfileData()
            
        }

        loadOwnProfileData()
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        
        if(self.userID != nil){
            
            loadPictureName(uid:self.userID)
            
            loadLocation(uid:self.userID)
            
            loadReviewStar(uid:self.userID)
            
            loadApplicantUserProfileData()
            
        }
        
        let when = DispatchTime.now() + 1.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func updateStatus(_ notification: NSNotification) {
        
        acceptButton.setTitle("HIRED", for: .normal)
        acceptButton.isEnabled = false
        acceptButton.backgroundColor = UIColor.init(red: 113/255, green: 216/255, blue: 103/255, alpha: 1.0)
        rejectButton.isHidden = true
    }
    
    @objc func userProfileImageClicked(){
        if (userprofileImage != nil) {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL(userprofileImage!)
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
            
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            present(browser, animated: true, completion: {})
        }
    }
    
    
    @objc func userCoverImageClicked(){
        if (usercoverImage != nil) {
            if (usercoverImage != userprofileImage) {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImageURL(usercoverImage!)
                photo.shouldCachePhotoURLImage = true
                images.append(photo)
                
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: {})
            }
        }
    }
    
    @objc func segmentSelected(sender: OtherUserSegmentedControl){
        
        if(sender.selectedSegmentIndex == 1){
            loadReviewData()
            if (reviewposts.count == 0){
                self.countValue = 0
            }
            else {
                self.countValue = reviewposts.count
            }
            
        }
        else if(sender.selectedSegmentIndex == 0){
            loadApplicantUserProfileData()
            self.countValue = 5
            print("select0")
            
        }
        else{
            loadPostedData()
            if (posts.count == 0){
                self.countValue = 0
            }
            else {
                self.countValue = posts.count
            }
        }
        
        self.segmentindex = sender.selectedSegmentIndex
        
    }
    

    @objc func clickButton() {
        // create the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add the actions (buttons)
//        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { action in
//
//            self.ShareJob()
//
//        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        if (self.userID != nil ) {
            if (self.ownerID != self.userID) {
                alert.addAction(UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: { action in
                    
                    self.ReportJob()
                    
                }))
            }else{
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
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
                print("[Get Applicant Anonymouse User")
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
                self.userReportRef.child(uid!).child("User").child("Spam").child(self.userID).setValue(self.userID)
                self.showThankYouAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Irrelavant", style: UIAlertActionStyle.destructive, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                self.userReportRef.child(uid!).child("User").child("Irrelavant").child(self.userID).setValue(self.userID)
                self.showThankYouAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Inappropriate", style: UIAlertActionStyle.destructive, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                self.userReportRef.child(uid!).child("User").child("Inappropriate").child(self.userID).setValue(self.userID)
                
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
    
    
    //MARK:- Functions
    
    func checkApplicantStatus(){
        
        print("status = \(status)")
        
        switch status {
            
        case .hired:
            // change hired button
            acceptButton.setTitle("HIRE", for: .normal)
            acceptButton.backgroundColor = UIColor.init(red: 113/255, green: 216/255, blue: 103/255, alpha: 1.0)
            break
        case .shortlisted:
            // show shortlisted
            acceptButton.setTitle("SHORTLIST", for: .normal)
            acceptButton.backgroundColor = UIColor.init(red: 103/255, green: 184/255, blue: 237/255, alpha: 1.0)
            break
            
        case .completed:
            // show completed
            acceptButton.setTitle("HIRED", for: .normal)
            acceptButton.isEnabled = false
            acceptButton.backgroundColor = UIColor.init(red: 113/255, green: 216/255, blue: 103/255, alpha: 1.0)
            rejectButton.isHidden = true
            break
            
        default:
            actionView.isHidden = true
            break
        }
    }
    
    
    
    
    func checkSameUID(){
        let ownUID = Auth.auth().currentUser?.uid
        
        if ownUID == self.userID{
            messageButton.isHidden = true
        }else{
            messageButton.isHidden = false
        }
    }
    
    func loadAppliedJobDetails(){
        
        let jobRef = Database.database().reference().child("Job").child(jobCity).child(postkey)
        
        jobRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                return
            }
            
            if snapshot.hasChild("title"){
                self.jobTitle = (snapshot.childSnapshot(forPath: "title").value as? String)!
            }
            else{
                self.jobTitle = ""
            }
            
            if snapshot.hasChild("desc"){
                self.jobDesc  = (snapshot.childSnapshot(forPath: "desc").value as? String)!
            }else{
                self.jobDesc = ""
            }
        })
    }
    
    func loadReviewStar(uid:String) {
        
        let ref = Database.database().reference()
        
        self.reviewLabel.text = "\(Int(totalreviewcount!)) Reviews"
        self.reviewStarView.rating =  0
        
        ref.child("UserReview").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                return
            }
            
            if(snapshot.hasChild("Rate5")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate5").value as? Double
                {
                    self.reviewcount5 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate4")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate4").value as? Double
                {
                    self.reviewcount4 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate3")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate3").value as? Double
                {
                    self.reviewcount3 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate2")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate2").value as? Double
                {
                    self.reviewcount2 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate1")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate1").value as? Double
                {
                    self.reviewcount1 = getReviewData
                }
            }
            
            if (self.reviewcount5 != nil && self.reviewcount4 != nil && self.reviewcount3 != nil && self.reviewcount2 != nil && self.reviewcount1 != nil ){
                
                self.totalreviewcount = self.reviewcount5! + self.reviewcount4! + self.reviewcount3! + self.reviewcount2! + self.reviewcount1!
                
                let top1divider = (5*self.reviewcount5!)+(4*self.reviewcount4!)+(3*self.reviewcount3!)
                
                let top2divider = (2*self.reviewcount2!)+(1*self.reviewcount1!)
                
                let combinedivider = top1divider+top2divider
                
                let starcount = combinedivider/self.totalreviewcount!
                
                let inttotalreview = Int(self.totalreviewcount!)
                
                self.reviewLabel.text = "\(inttotalreview) Reviews"
                
                self.reviewStarView.rating =  starcount
            }
            
        })
        
        ref.removeAllObservers()
    }
    
    func loadPictureName(uid:String) {
        
        let ref = Database.database().reference()
        
        ref.child("UserAccount").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {return}
            
            if let getData = snapshot.value as? [String:Any]{
                print(getData)
                
                let userName = getData["name"] as? String
                
                let userImage = getData["image"] as? String
                
                self.profileimage.downloadprofileImage(from: userImage!)
                self.usercoverImage = userImage
                self.userprofileImage = userImage
                self.profileName.text = userName
            }
            
        })
        
        ref.child("UserInfo").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {
                
                if let viewWithTag = self.coverImage.viewWithTag(100) {
                    viewWithTag.removeFromSuperview()
                }
                
                self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.tag = 100
                blurEffectView.frame = self.coverImage.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.coverImage.addSubview(blurEffectView)
                return
            }
            
            if let getData = snapshot.value as? [String:Any]{
                
                if snapshot.hasChild("CoverImage"){
                    
                    if let viewWithTag = self.coverImage.viewWithTag(200) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                    self.usercoverImage = getData["CoverImage"] as? String
                    self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                    
                    let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width: self.coverImage.frame.size.width, height: self.coverImage.frame.size.height))
                    overlay.backgroundColor = UIColor(red:0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                    overlay.tag = 200
                    self.coverImage.addSubview(overlay)
                    
                }
                else{
                    
                    if let viewWithTag = self.coverImage.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                    self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.tag = 100
                    blurEffectView.frame = self.coverImage.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.coverImage.addSubview(blurEffectView)
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    func loadLocation(uid:String) {
        
        let ref = Database.database().reference()
        
        ref.child("UserLocation").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                self.profileLocation.text = "Somewhere on earth"
                return
            }
            
            if (snapshot.hasChild("CurrentCity")){
                if let getLocationData = snapshot.childSnapshot(forPath: "CurrentCity").value as? String
                {
                    self.profileLocation.text = getLocationData
                    
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    func loadOwnProfileData(){
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            self.ownerID = uid
            
            let ref = Database.database().reference()
            
            ref.child("UserAccount").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                if let getData = snapshot.value as? [String:Any]{
                    
                    if let userImage = getData["image"] as? String
                    {
                        self.ownerImage = userImage
                        
                    }
                    
                    if let userName = getData["name"] as? String
                    {
                        self.ownerName = userName
                        
                    }
                }
            })
        }
    }
    
    func loadApplicantUserProfileData(){
        
        if(self.userID != nil){
            
            let ref = Database.database().reference()
            
            ref.child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(!snapshot.hasChild(self.userID)){
                    
                    self.profileabout      = ["none"]
                    self.profileemail      = ["none"]
                    self.profilephone      = ["none"]
                    self.profileGender     = ["none"]
                    self.profileBirthdate  = ["none"]
                    self.profileWeight     = ["none"]
                    self.profileHeight     = ["none"]
                    self.profileworktitle  = ["none","none","none","none","none"]
                    self.profileworkplace  = ["none","none","none","none","none"]
                    self.profileworklength = ["none","none","none","none","none"]
                    self.profileeducation  = ["none"]
                    self.profilelanguages  = ["none"]
                    
                    self.profileTableView.reloadData()

                    return
                }else{
                    
                    self.profileabout.removeAll()
                    self.profileemail.removeAll()
                    self.profilephone.removeAll()
                    self.profileworktitle.removeAll()
                    self.profileworkplace.removeAll()
                    self.profileworklength.removeAll()
                    self.profileeducation.removeAll()
                    self.profilelanguages.removeAll()
                }
                
               
                
                if snapshot.childSnapshot(forPath: self.userID).hasChild("WorkExp1"){
                    if let getWorkData = snapshot.childSnapshot(forPath: self.userID).childSnapshot(forPath: "WorkExp1").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: self.userID).hasChild("WorkExp2"){
                    if let getWorkData = snapshot.childSnapshot(forPath: self.userID).childSnapshot(forPath: "WorkExp2").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: self.userID).hasChild("WorkExp3"){
                    if let getWorkData = snapshot.childSnapshot(forPath: self.userID).childSnapshot(forPath: "WorkExp3").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: self.userID).hasChild("WorkExp4"){
                    if let getWorkData = snapshot.childSnapshot(forPath: self.userID).childSnapshot(forPath: "WorkExp4").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                
                if snapshot.childSnapshot(forPath: self.userID).hasChild("WorkExp5"){
                    if let getWorkData = snapshot.childSnapshot(forPath: self.userID).childSnapshot(forPath: "WorkExp5").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                
                
                if let getData = snapshot.childSnapshot(forPath: self.userID).value as? [String:Any]{
                    
                    if let userDescrip = getData["About"] as? String
                    {
                        self.profileabout.append(userDescrip)
                        
                    }
                    else{
                        self.profileabout.append("none")
                    }
                    
                    if let userAge = getData["Age"] as? String
                    {
                        self.profileBirthdate.append(userAge)
                        
                    }
                    else{
                        self.profileBirthdate.append("none")
                    }
                    
                    if let userGender = getData["Gender"] as? String
                    {
                        if userGender == "" {
                            self.profileGender.append("none")
                        }
                        else {
                            self.profileGender.append(userGender)
                        }
                    }
                    else{
                        self.profileGender.append("none")
                    }
                    
                    if let userWeight = getData["Weight"] as? String
                    {
                        self.profileWeight.append(userWeight)
                        
                    }
                    else{
                        self.profileWeight.append("none")
                    }
                    
                    if let userHeight = getData["Height"] as? String
                    {
                        self.profileHeight.append(userHeight)
                        
                    }
                    else{
                        self.profileHeight.append("none")
                    }
                    
                    if let userDescrip = getData["Email"] as? String
                    {
                        self.profileemail.append(userDescrip)
                        
                    }
                    else{
                        self.profileemail.append("none")
                    }
                    
                    
                    if let userDescrip = getData["Phone"] as? String
                    {
                        self.profilephone.append(userDescrip)
                        
                    }
                    else{
                        self.profilephone.append("none")
                    }
                    
                    
                    if let userDescrip = getData["Education"] as? String
                    {
                        self.profileeducation.append(userDescrip)
                        
                    }
                    else{
                        self.profileeducation.append("none")
                    }
                    
                    
                    if let userDescrip = getData["Language"] as? String
                    {
                        self.profilelanguages.append(userDescrip)
                        
                    }
                    else{
                        self.profilelanguages.append("none")
                    }
                    
                    self.profileTableView.reloadData()
                }
            })
            
        }
    }
    
    func loadReviewData(){
        
        if(self.userID != nil){
            
            let ref = Database.database().reference()
            
            ref.child("UserReview").child(self.userID).child("Review").queryOrdered(byChild: "time").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.reviewposts.removeAll()
                    self.profileTableView.reloadData()
                    return
                    
                }
                
                self.reviewposts.removeAll()
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let reviewreview = UserReview()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if let userReviewMessage = restDict["reviewmessage"] as? String,
                        let userImage = restDict["userimage"] as? String,
                        let userName = restDict["username"] as? String,
                        let ratingstar = restDict["rating"] as? Double,
                        let t = restDict["time"] as? TimeInterval {
                        
                        let poststartdate = Date(timeIntervalSince1970: t/1000)
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "dd MMM yyyy"
                        let strDate = dateFormatter.string(from: poststartdate)
                        
                        reviewreview.userName = userName
                        reviewreview.userImage = userImage
                        reviewreview.userReviewMessage = userReviewMessage
                        reviewreview.userTime = strDate
                        reviewreview.userRating = ratingstar
                        
                        self.reviewposts.append(reviewreview)
                        
                    }
                }
                
                self.profileTableView.reloadData()
                
            })
            
        }
    }
    
    
    func loadPostedData(){
        
        if(self.userID != nil){
            
            let ref = Database.database().reference()
            
            ref.child("UserPosted").child(self.userID).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.posts.removeAll()
                    self.profileTableView.reloadData()
                    return
                    
                }
                
                self.posts.removeAll()
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let postpost = Post()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if  let postImage = restDict["postimage"] as? String,
                        let postTitle = restDict["title"] as? String,
                        let postDesc = restDict["desc"] as? String,
                        let postClosed = restDict["closed"] as? String,
                        let postCompany = restDict["company"] as? String,
                        let postCity = restDict["city"] as? String,
                        let postPressed = restDict["pressed"] as? String,
                        let posttotalhiredcount = restDict["totalhiredcount"] as? Double,
                        let applicantscount = restDict["applicantscount"] as? Double,
                        let newapplicantscount = restDict["newapplicantscount"] as? Double,
                        let postKey = rest.key as? String{
                        
                        
                        
                        postpost.postTitle = postTitle
                        postpost.postImage = postImage
                        postpost.postDesc = postDesc
                        postpost.postCompany = postCompany
                        postpost.postKey = postKey
                        postpost.postClosed = postClosed
                        postpost.postCity = postCity
                        postpost.postPressed = postPressed
                        postpost.totalhiredcount = posttotalhiredcount
                        postpost.applicantscount = applicantscount
                        postpost.newapplicantscount = newapplicantscount
                        
                        self.posts.append(postpost)
                        
                    }
                }
                
                self.profileTableView.reloadData()
            })
        }
    }
    
    
    func shortlistApplicant(){
        
        userActivitiesRef.child(self.userID).child("Applied").child(self.postkey).observeSingleEvent(of: .value, with: { (snapshot) in
            print("")
            print(snapshot)
            print("")
            if snapshot.exists(){
                self.userActivitiesRef.child(self.userID).child("NewMainNotification").setValue("true")
                self.userActivitiesRef.child(self.userID).child("NewApplied").setValue("true")
                self.userActivitiesRef.child(self.userID).child("Applied").child(self.postkey).child("pressed").setValue("false")
                self.userActivitiesRef.child(self.userID).child("Applied").child(self.postkey).child("status").setValue("shortlisted")
                
                let newShortlistedNotification = Database.database().reference().child("ShortlistedNotification").child("ShortListed").childByAutoId()
                let shortlistNotificationKey = newShortlistedNotification.key
                
                var notificationData = [String:Any]()
                notificationData["ownerUid"]    =  Auth.auth().currentUser?.uid
                notificationData["receiverUid"] =  self.userID
                notificationData["ownerName"]   =  self.ownerName
                
                newShortlistedNotification.setValue(notificationData)
                
                self.userActivitiesRef.child(self.userID).child("ShortListedNotification").child(shortlistNotificationKey).setValue(shortlistNotificationKey, withCompletionBlock: { (error, ref) in
                    
                    //Change status and button
                    self.status = .hired
                    self.checkApplicantStatus()
                    
                    //show rating view
                    
                })
                
                
            }
        }) { (error) in
            self.showAlertBox(title: "System encountered some problem.\nPlease try again.", msg: "", buttonString: "Ok")
            print(error.localizedDescription)
        }
        
        let tsLong: Int64 = Int64(Utilities.getCurrentMillis()/1000)

        var shortlistedData = [String: Any]()
        shortlistedData["time"]         = ServerValue.timestamp()
        shortlistedData["negatedtime"]  = -1 * tsLong
        shortlistedData["name"]         = userName
        
        if userprofileImage == nil{
            shortlistedData["image"] = "default"
        }else{
            shortlistedData["image"]        = userprofileImage
        }
        userPostedShortlistedApplicantsRef.child((Auth.auth().currentUser?.uid)!).child(postkey).child(self.userID).setValue(shortlistedData) { (error, ref) in
            print(error.debugDescription)
        }

        //    .setValue(shortlistedData)
        
        //Remove User from UserPendingShortlist List
        userPostedPendingApplicants.child((Auth.auth().currentUser?.uid)!).child(postkey).child(self.userID).removeValue()
        
        //Add to user's chat
        let ownerChatRef        = chatRoomRef.child(ownerID!)
        let receiverChatRef     = chatRoomRef.child(self.userID!)
        let newReceiverChatRef  = receiverChatRef.child("\(self.userID!)_\(ownerID!))").child("ChatList").childByAutoId()
        let newChatListKey      = newReceiverChatRef.key
        let newOwnerChat        = ownerChatRef.child("\(ownerID!)_\(self.userID!)").child("ChatList").child(newChatListKey)

        var actionChatData = [String:Any]()
        
        actionChatData["negatedtime"]   = -1 * tsLong
        actionChatData["time"]          = ServerValue.timestamp()
        actionChatData["actiontitle"]   = "shortlisted"
        actionChatData["ownerid"]       = Auth.auth().currentUser?.uid
        actionChatData["jobtitle"]      = jobTitle
        actionChatData["jobdescrip"]    = jobDesc
        actionChatData["city"]          = jobCity
        actionChatData["postkey"]       = postkey
        
 userChatListRef.child(ownerID!).child("UserList").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.exists() {
                if snapshot.hasChild(self.userID){
                    actionChatData["oldtime"]   = snapshot.childSnapshot(forPath: "UserList").childSnapshot(forPath: self.userID).childSnapshot(forPath: "time").value as? String
                    
                    newOwnerChat.setValue(actionChatData)
                    newReceiverChatRef.setValue(actionChatData)
                }else{
                    actionChatData["oldtime"]   = 0
                    newOwnerChat.setValue(actionChatData)
                    newReceiverChatRef.setValue(actionChatData)
                }
            }else{
                actionChatData["oldtime"]   = 0
                newOwnerChat.setValue(actionChatData)
                newReceiverChatRef.setValue(actionChatData)
            }
        })
        
        
    }
    
    func decreamentApplicants(){
        userPostedRef.child((Auth.auth().currentUser?.uid)!).child(postkey).child("applicantscount").runTransactionBlock { (applicantData) -> TransactionResult in
            if(applicantData.value != nil){
                if (applicantData.value as! Double) == 0{
                    applicantData.value = 0
                }else{
                    if let value :Double = applicantData.value as? Double{
                        applicantData.value = value - 1
                    }
                }
            }
            return TransactionResult.success(withValue: applicantData)
        }
    }

    func rejectApplicant(){
        
        userActivitiesRef.child(self.userID).child("Applied").child(postkey).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                
                self.userActivitiesRef.child(self.userID).child("NewMainNotification").setValue("true")
                self.userActivitiesRef.child(self.userID).child("NewApplied").setValue("true")
                self.userActivitiesRef.child(self.userID).child("Applied").child(self.postkey).child("pressed").setValue("false")
                self.userActivitiesRef.child(self.userID).child("Applied").child(self.postkey).child("status").setValue("appliedrejected")
            
            }
        }
        
        //This is set to remember user has been rejected once, so user can only re-apply ONE MORE time
        let newRejected = userActivitiesRef.child(self.userID).child("RejectedApplied").child(self.postkey).childByAutoId()
        newRejected.setValue("true")
        
        //Delete user at UserPostedPendingApplicants List, and UserPostedShortlistedApplicants
        userPostedPendingApplicants.child((Auth.auth().currentUser?.uid)!).child(self.postkey).child(self.userID).removeValue()
        userPostedShortlistedApplicantsRef.child((Auth.auth().currentUser?.uid)!).child(postkey).child(self.userID).removeValue()
        
        //Decrement applicants count
        decreamentApplicants()
        
        //Add to user's chat
        let ownerChatRef        = chatRoomRef.child(ownerID!)
        let receiverChatRef     = chatRoomRef.child(self.userID!)
        let newReceiverChatRef  = receiverChatRef.child("\(self.userID!)_\(ownerID!))").child("ChatList").childByAutoId()
        let newChatListKey      = newReceiverChatRef.key
        let newOwnerChat        = ownerChatRef.child("\(ownerID!)_\(self.userID!)").child("ChatList").child(newChatListKey)
        
        let tsLong: Int64       = Int64(Utilities.getCurrentMillis()/1000)

        var actionChatData      = [String:Any]()
        
        actionChatData["negatedtime"]   = -1 * tsLong
        actionChatData["time"]          = ServerValue.timestamp()
        actionChatData["actiontitle"]   = "rejected"
        actionChatData["ownerid"]       = Auth.auth().currentUser?.uid
        actionChatData["jobtitle"]      = jobTitle
        actionChatData["jobdescrip"]    = jobDesc
        actionChatData["city"]          = jobCity
        actionChatData["postkey"]       = postkey
        
        userChatListRef.child(ownerID!).child("UserList").child(self.userID!).observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.exists() {
                if snapshot.hasChild(self.userID){
                    actionChatData["oldtime"]   = snapshot.childSnapshot(forPath: "UserList").childSnapshot(forPath: self.userID).childSnapshot(forPath: "time").value as? String
                    
                    newOwnerChat.setValue(actionChatData)
                    newReceiverChatRef.setValue(actionChatData)
                }else{
                    actionChatData["oldtime"]   = 0
                    newOwnerChat.setValue(actionChatData)
                    newReceiverChatRef.setValue(actionChatData)
                }
            }else{
                actionChatData["oldtime"]   = 0
                newOwnerChat.setValue(actionChatData)
                newReceiverChatRef.setValue(actionChatData)
            }
        })
    }
    
    
    func goToHireForm(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Start", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HireFormViewController") as! HireFormViewController
        nextViewController.hidesBottomBarWhenPushed = true
        
        
        print("============== Passing Data to Hire Form ==========")
        print("[Post Key]           : \(postkey!)")
        print("[Job City]           : \(jobCity!)")
        
        nextViewController.applicantName    = userName
        nextViewController.applicantUID     = userID
        nextViewController.postKey          = postkey
        nextViewController.jobCity          = jobCity
        if userprofileImage != nil {
            nextViewController.applicantImage   = userprofileImage!
        }
        else {
            nextViewController.applicantImage   = "default"
        }
        
        
        if postkey != "" && jobCity != ""{
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }else{
            showAlertBox(title: "System encountered some error.", msg: "", buttonString: "Ok")
        }
        
    }
    
    
   
    
    //MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (segmentindex == 2){
            
            let tablecell = tableView.cellForRow(at: indexPath) as! SavedTableViewCell
            
            let ref = Database.database().reference()
            ref.child("Job").child(self.posts[indexPath.row].postCity).child(self.posts[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
                    
                    destinationVC.postid = self.posts[indexPath.row].postKey
                    destinationVC.city = self.posts[indexPath.row].postCity
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                    
                }
                else {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedJob") as! RemovedJob
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                    
                }
                
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var tablecell: UITableViewCell!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell") as! OtherUserSegmentTableViewCell
        
        
        cell.swsegmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: UIControlEvents.valueChanged)
        
        
        if(segmentindex == 0){
            
            cell.swsegmentControl.selectedSegmentIndex = 0
            
            //self.segmentint = 0
        }
        else if (segmentindex == 1){
            
            cell.swsegmentControl.selectedSegmentIndex = self.segmentindex
            //self.segmentint = 1
        }
            
        else {
            cell.swsegmentControl.selectedSegmentIndex = self.segmentindex
            //self.segmentint = 2
        }
        
        tablecell = cell
        
        return tablecell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(segmentindex == 0){
            
            self.countValue = 5
            print(self.countValue)
        }
        else if(segmentindex == 1){
            if (reviewposts.count == 0){
                self.countValue = 0
            }
            else {
                self.countValue = reviewposts.count
            }
            
            print(self.countValue)
        }
        else {
            if (posts.count == 0){
                self.countValue = 0
            }
            else {
                self.countValue = posts.count
            }
            
            print(self.countValue)
        }
        
        return countValue
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        if(segmentindex == 0){
            
            var insidetablecell: UITableViewCell!
            
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ProfileInfoCell
                
                if(profileabout[0] != "none"){
                    cell.profileDescrip.setLineHeight(lineHeight: 5, textstring: profileabout[0])
                    cell.profileDescrip.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.profileDescrip.text = "No Description Added"
                    cell.profileDescrip.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                if(profileBirthdate[0] != "none"){
                    cell.birthdateLabel.setLineHeight(lineHeight: 5, textstring: profileBirthdate[0])
                    cell.birthdateStackView.isHidden = false
                }
                else{
                    cell.birthdateStackView.isHidden = true
                }
                
                
                if(profileGender[0] != "none"){
                    cell.genderLabel.setLineHeight(lineHeight: 5, textstring: profileGender[0])
                    cell.genderStackView.isHidden = false
                }
                else{
                    cell.genderStackView.isHidden = true
                }
                
                if(profileWeight[0] != "none"){
                    cell.weightLabel.setLineHeight(lineHeight: 5, textstring: profileWeight[0] + " kg")
                    cell.weightStackView.isHidden = false
                }
                else{
                    cell.weightStackView.isHidden = true
                }
                
                if(profileHeight[0] != "none"){
                    cell.heightLabel.setLineHeight(lineHeight: 5, textstring: profileHeight[0] + " cm")
                    cell.heightStackView.isHidden = false
                }
                else{
                    cell.heightStackView.isHidden = true
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
                
                if(profileemail[0] != "none"){
                    cell.emailLabel.setLineHeight(lineHeight: 5, textstring: profileemail[0])
                    cell.emailLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.emailLabel.text = "No Email Added"
                    cell.emailLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                if(profilephone[0] != "none"){
                    cell.phoneLabel.setLineHeight(lineHeight: 5, textstring: profilephone[0])
                    cell.phoneLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.phoneLabel.text = "No Phone Added"
                    cell.phoneLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 2){
                
                if(profileworktitle[0] == "none" && profileworkplace[0] == "none"){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoWorkExpCell", for: indexPath) as! NoWorkTableViewCell
                    
                    cell.worklabel.text = "Not Work Experience"
                    cell.worklabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                    insidetablecell = cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkCell2", for: indexPath) as! WorkTableViewCell2
                    
                    for i in (0..<5)
                    {
                        var workTitle: UILabel!
                        var workCompany: UILabel!
                        var workView: UIView!
                        
                        if(i == 0){
                            workTitle = cell.workTitle1
                            workCompany = cell.workCompany1
                            workView = cell.workView1
                        }
                        else if(i == 1){
                            workTitle = cell.workTitle2
                            workCompany = cell.workCompany2
                            workView = cell.workView2
                        }
                        else if (i == 2){
                            workTitle = cell.workTitle3
                            workCompany = cell.workCompany3
                            workView = cell.workView3
                        }
                        else if (i == 3){
                            workTitle = cell.workTitle4
                            workCompany = cell.workCompany4
                            workView = cell.workView4
                        }
                        else if (i == 4){
                            workTitle = cell.workTitle5
                            workCompany = cell.workCompany5
                            workView = cell.workView5
                        }
                        
                        if(profileworktitle[i] != "none"){
                            workTitle.setLineHeight(lineHeight: 5, textstring: profileworktitle[i])
                        }
                        else{
                            print("ixx1 =  \(i)")
                            workView.isHidden = true
                        }
                        if(profileworkplace[i] != "none"){
                            workCompany.setLineHeight(lineHeight: 5, textstring: profileworkplace[i])
                        }
                        else{
                            workView.isHidden = true
                        }
                        
                    }
                    
                    insidetablecell = cell
                }
                
                
                
            }
                
            else if (indexPath.row == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EduTableViewCell
                
                if(profileeducation[0] != "none"){
                    cell.eduLabel.setLineHeight(lineHeight: 5, textstring: profileeducation[0])
                    cell.eduLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.eduLabel.text = "Not Education Added"
                    cell.eduLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 4){
                let cell = tableView.dequeueReusableCell(withIdentifier: "LanguagesCell", for: indexPath) as! LanguagesTableViewCell
                
                if(profilelanguages[0] != "none"){
                    cell.languagesLabel.setLineHeight(lineHeight: 5, textstring: profilelanguages[0])
                    cell.languagesLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.languagesLabel.text = "Not Languages Added"
                    cell.languagesLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
            
            tablecell = insidetablecell
        }
            
        else if (segmentindex == 1){
            
            if(self.countValue != 0){
                
                let reviewcell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ProfileReviewCell
                
                reviewcell.userImage.sd_setImage(with: URL(string: self.reviewposts[indexPath.row].userImage), placeholderImage: UIImage(named: "userprofile_default"))
                
                //reviewcell.userImage.downloadprofileImage(from: self.reviewposts[indexPath.row].userImage)
                
                reviewcell.userName.text =  self.reviewposts[indexPath.row].userName
                
                reviewcell.userReviewMessage.setLineHeight(lineHeight: 2.5, textstring: self.reviewposts[indexPath.row].userReviewMessage)
                
                //reviewcell.userReviewMessage.text = self.reviewposts[indexPath.row].userReviewMessage
                
                reviewcell.timeLabel.text =  self.reviewposts[indexPath.row].userTime
                
                reviewcell.reviewRating.rating =  self.reviewposts[indexPath.row].userRating
                
                
                tablecell = reviewcell
            }
            
            
        }
            
        else {
            
            if(self.countValue != 0){
                
                let postedcell = tableView.dequeueReusableCell(withIdentifier: "PostedCell", for: indexPath) as! SavedTableViewCell
                
                if(posts[indexPath.row].postImage == "0"){
                    postedcell.postImage.image = UIImage(named: "job_bg1")
                }
                else if (posts[indexPath.row].postImage == "1"){
                    postedcell.postImage.image = UIImage(named: "job_bg2")
                }
                else if (posts[indexPath.row].postImage == "2"){
                    postedcell.postImage.image = UIImage(named: "job_bg3")
                }
                else{
                    postedcell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
                    
                }
                
                
                //savedcell.postImage.downloadpostImage(from: self.posts[indexPath.row].postImage)
                
                postedcell.postTitle.text = posts[indexPath.row].postTitle
                
                postedcell.postCompany.text = posts[indexPath.row].postCompany
                
                postedcell.postDescrip.text = posts[indexPath.row].postDesc
                
                postedcell.closedView.isHidden = true
                postedcell.closedText.isHidden = true
                postedcell.removedView.isHidden = true
                
                if (posts[indexPath.row].postClosed == "true") {
                    postedcell.closedView.isHidden = false
                    postedcell.closedText.isHidden = false
                }
                else {
                    postedcell.closedView.isHidden = true
                    postedcell.closedText.isHidden = true
                }
                
                tablecell = postedcell
            }
            
        }
        
        
        return tablecell
    }

}
