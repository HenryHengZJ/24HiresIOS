//
//  HomeViewController.swift
//  JobIn24
//
//  Created by MacUser on 10/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import RevealingSplashView
import BetterSegmentedControl
import MapKit
import CoreLocation
import NVActivityIndicatorView
import FirebaseInstanceID


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, UIScrollViewDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var LocationBar      : UIView!
    @IBOutlet weak var talentView       : UIView!
    @IBOutlet weak var filterView       : UIView!
    @IBOutlet weak var filterNumberView : UIView!
    @IBOutlet weak var loadingView      : UIView!
    @IBOutlet weak var loadingBallView  : UIView!
    @IBOutlet weak var noJobView        : UIView!
    @IBOutlet weak var stateButtonView  : UIView!
    @IBOutlet weak var topLocationLabel : UILabel!
    @IBOutlet weak var filterNumLabel   : UILabel!
    @IBOutlet weak var noJobLabel       : UILabel!
    @IBOutlet weak var stateLabel       : UILabel!
    @IBOutlet weak var locationButton   : UIButton!
    @IBOutlet weak var stateButton      : UIButton!
    @IBOutlet weak var talentImage      : UIImageView!
    @IBOutlet weak var jobtableView     : UITableView!
    @IBOutlet weak var bannerScrollView : UIScrollView!
    @IBOutlet weak var bannerPageControl: UIPageControl!
    @IBOutlet weak var segmentController: BetterSegmentedControl!
    @IBOutlet weak var loadingBall      : NVActivityIndicatorView!


    
    //MARK: - Variable
    
    var displaySplash                   : Bool!
    var mostrecent_startdate            : Int64!
    var mostrecent_wagesrange           : Int64!
    var mostrecent_wagesrange_startdate : Int64!
    var finalstartwagesfilter           : Int64!
    var finalstarttime                  : Int64!
    var postkey                         : String!
    var selectedcity                    : String!
    var city                            : String = ""
    var lastpostTime                    : TimeInterval!
    var refreshControl                  : UIRefreshControl!
    var latitude                        : CLLocationDegrees!
    var longitude                       : CLLocationDegrees!
    var ref                             : DatabaseReference!
    
    var startdate        :Int64   = 0
    var enddate          :Int64   = 0
    var wagescategory    :Int64   = 0
    
    var posts               = [Post]()
    var loadlimit           = 8
    var filterbywages       = 1111
    var filterbystart       = ""
    var filterbyend         = ""
    var oldfilterbywages    = "true"
    var firstloadData       = false
    var scenario            = 33
    var userUID             = String()
    var categoryName        = String()
    var categoryNumber      = Int64()
    var bannerArray         = [String]()
    var bannerURL           = [String]()
    var loadingData         = false
    var pagingindicator     = UIActivityIndicatorView()
    
    let locationManager     = CLLocationManager()
    let delegate            = UIApplication.shared.delegate as! AppDelegate
    
    
    
    
    
    //MARK: - Override Func
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("""

        ============================================================
                Home Page
        ============================================================

        """)
        
        //Start Main Func
        splashScreenPrepare()
      //  checkVersion()
        setLoadingScreen()
        getBannerPicture()
        
        //Get UID
        let currentuser = Auth.auth().currentUser
        if currentuser != nil {
            if currentuser!.isAnonymous {
                print("[Get Home Anonymouse User")
            }
            else {
                let userID :String  = currentuser!.uid
                print("[Get UID]: \(userID)\n")
                userUID = userID
                
                addToken()
                checkFirstTokenRun()
                connectedRef()
                checkApplicantPass24()
                checkAppliedJobPass24()
                checkAccepted()
            }
            
            loadTalentImage()
            getCurrentLocation()
        }
       
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Notification.Name("updateHomeLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateFilter(_:)), name: Notification.Name("updateFilter"), object: nil)
        
        
        noJobView.isHidden                  = true
        filterNumberView.layer.cornerRadius = filterNumberView.frame.size.height/2
        filterNumberView.clipsToBounds      = true
        
        // Control 1: Created and designed in IB that announces its value on interaction
        segmentController.titles            = ["EXPLORE JOBS", "DISCOVER TALENTS"]
        segmentController.titleFont         = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        segmentController.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        
        let indicatorView   = UIView(frame: CGRect(x: segmentController.frame.origin.x , y: segmentController.frame.size.height - 5, width: segmentController.frame.size.width/2, height: 2) )
        
        indicatorView.backgroundColor       = .white
        indicatorView.layer.cornerRadius    = indicatorView.frame.height/2
        
        segmentController.addSubviewToIndicator(indicatorView)
        
        LocationBar.layer.cornerRadius  = 5.0
        LocationBar.layer.masksToBounds = true
        
//        stateButton.layer.cornerRadius  = 5
//        stateButton.layer.shadowColor   = UIColor.lightGray.cgColor
//        stateButton.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
//        stateButton.layer.shadowOpacity = 1.0
//        stateButton.layer.shadowRadius  = 3.0
//        stateButton.layer.masksToBounds = false
        
        jobtableView.dataSource         = self
        jobtableView.delegate           = self
        bannerScrollView.delegate       = self
        
        // dynamic table view cell height
        jobtableView.estimatedRowHeight = jobtableView.rowHeight
        jobtableView.rowHeight          = UITableViewAutomaticDimension
        jobtableView.separatorColor     = UIColor.clear
        
        refreshControl                  = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        jobtableView.addSubview(refreshControl)
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "JobDetail"){
            let vc      = segue.destination as! JobDetail
            vc.postid   = postkey
            vc.city     = selectedcity
            print("Prepare:\(postkey!)")
            print("Prepare:\(selectedcity!)\n")
            
        }else if (segue.identifier == AppConstant.segueIdentifier_HomeToSearchMenu){
            let vc      = segue.destination as! SearchesViewController
            vc.location = self.city
            
        }else if(segue.identifier == AppConstant.segueIdentifier_homeToStateList){
            let dest = segue.destination as! HomeLocationTableViewController
            dest.fromviewcontroller = "Home"
            
        }else if (segue.identifier == AppConstant.segueIdentifier_homeToSearchCategory){
            let dest = segue.destination as! SearchCategoryViewController
            if categoryNumber > 0 {
                dest.categoryTitle  = categoryName
                dest.categoryNumber = Int64(categoryNumber)
                dest.currentCity    = self.city
            }
        }
    }
    
//    disable storyboard segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    //MARK: - Screen Preparation Func
    func splashScreenPrepare(){
        displaySplash       = delegate.displayHomeVCSplashScreen
        if(displaySplash != nil){
            if(displaySplash){
                let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Apps_transparent_logo")!,iconInitialSize: CGSize(width: 130, height: 130), backgroundColor: UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1.00))
                
                self.view.addSubview(revealingSplashView)
                
                revealingSplashView.duration            = 1.5
                revealingSplashView.useCustomIconColor  = false
                revealingSplashView.startAnimation()
            }
        }
    }
    //MARK: - Banner Functions

    func getBannerPicture(){
        ref = Database.database().reference()
        ref.child("Banner").child("BannerPicture").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let bannerSnapshot = snapshot.children.allObjects as! [DataSnapshot]
                print("Setting Up Banner\n=================")
                print("[Banner Count]: \(bannerSnapshot.count)\n")
                
                for child in bannerSnapshot {
                    let bannerlink = child.value as! String
                    self.bannerArray.append(bannerlink)
                }
                self.bannerPrepare()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("Banner").child("BannerLink").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let bannerURLSnapshot = snapshot.children.allObjects as! [DataSnapshot]
                
                for child in bannerURLSnapshot{
                    let bannerStringURL = child.value as! String
                    self.bannerURL.append(bannerStringURL)
                }
            }
        }
    }
    
    func bannerPrepare(){
        
        for i in 0..<bannerArray.count{
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.sd_setImage(with: URL(string: self.bannerArray[i]))
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.bannerScrollView.frame.width, height: self.bannerScrollView.frame.height)
            
            bannerScrollView.contentSize.width = bannerScrollView.frame.width * (CGFloat(i) + 1)
            bannerScrollView.addSubview(imageView)
        }
        
    }
    
    func bannerRedirect(page:Int){
        
        let selectedBannerLink = bannerURL[page]
        
        if selectedBannerLink != ""{
            UIApplication.shared.openURL(URL.init(string: selectedBannerLink)!)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth   : CGFloat = scrollView.frame.width
        let currentPage : CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth) + 1
        self.bannerPageControl.currentPage = Int(currentPage)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth   : CGFloat = scrollView.frame.width
        let currentPage : CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth) + 1
        self.bannerPageControl.currentPage = Int(currentPage)
    }

    @objc func moveToNextPage (){
        let pageWidth       :CGFloat   = bannerScrollView.frame.width
        let maxWidth        :CGFloat   = pageWidth * CGFloat(bannerArray.count)
        let contentOffset   :CGFloat   = bannerScrollView.contentOffset.x

        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth
        {
            slideToX = 0
        }
        bannerScrollView.setContentOffset(CGPoint(x:slideToX, y:0), animated: true)
    }
    
    //MARK:- Core Function
    func checkVersion(){
        ref = Database.database().reference()
        ref.child("AppVersion").observeSingleEvent(of: .value) { (snapshot) in
            print("\n================== CHECK VERSION ===============\n")

            if snapshot.exists(){
                let latestAppVersion = snapshot.childSnapshot(forPath: "IOSVersion").value as! String
                let promptType = snapshot.childSnapshot(forPath: "IOSUpdateType").value as! String
                print("Apps Version\n==================")
                print("[Check Version]Latest IOS Version: \(latestAppVersion)")
                print("[Check Version]Prompt Type: \(promptType)")
                
                let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                    print("[Check Version]Current Apps Version: \(currentVersion)\n")
                
                if latestAppVersion != currentVersion{
                    //prompt action
                    print("[Check Version] Version Update is available.")
                    self.displayUpdateAlertMessage(promptMessage: Utilities.text(forKey: "update_Message"), prompType: promptType, latestVersion: latestAppVersion)
                }
            }
        }
    }

    func checkFirstTokenRun(){
        let preferences     = UserDefaults.standard
        let instanceIDKey   = "Token"
        var token           = String()
        let firstRunFlagKey = "firstRun"
        
//        InstanceID.instanceID().getID { (identity, error) in
//            if error != nil{
//                print(error?.localizedDescription ?? "")
//            }else{
        
        print("Check First Run Token\n=====================")
        
        token = Messaging.messaging().fcmToken!
        print("[Token]: \(token)\n")
    
        if preferences.object(forKey: firstRunFlagKey) == nil {
            //First Time Run, No Token
            preferences.set(token, forKey: instanceIDKey)
            preferences.set(true, forKey: firstRunFlagKey)
//            createToken(token: token)
            
            print("[Check Token]: (First Run) ")
            print("Token: \(preferences.object(forKey: instanceIDKey)!)\n")
            
        }else if (preferences.object(forKey: instanceIDKey) as! String != token){
            //Not First Time, Check if Token Refreshed
            preferences.set(token, forKey: instanceIDKey)
            
            print("[Check Token]: FCM Token Refreshed")
            print("New FCM Token: \(preferences.object(forKey: instanceIDKey)!)\n")
        }
    }
    
    //Not Using
    func createToken(token: String){
        let userUID = Auth.auth().currentUser?.uid
        print("[Profile UID]: \(userUID!)")
        
        ref = Database.database().reference()
        
        let newChatTokenRef        = ref.child("UserActivities").child(userUID!).child("ChatTokens")
        let newApplyTokenRef       = ref.child("UserActivities").child(userUID!).child("ApplyTokens")
        let newShortlistTokenRef   = ref.child("UserActivities").child(userUID!).child("ShortlistTokens")
        let newBookingTokenRef     = ref.child("UserActivities").child(userUID!).child("BookingTokens")
        let newHireTokenRef        = ref.child("UserActivities").child(userUID!).child("HireTokens")

        ref.child("UserActivities").child(userUID!).child("Tokens").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let newToken = snapshot.value
                newApplyTokenRef.setValue(newToken)
                newShortlistTokenRef.setValue(newToken)
                newBookingTokenRef.setValue(newToken)
                newHireTokenRef.setValue(newToken)
                newChatTokenRef.setValue(newToken, withCompletionBlock: { (error, ref) in
                    if error == nil{
                        print("========== Updated New Token, Remove Token value ==========")
                        ref.child("UserActivities").child(userUID!).child("Tokens").removeValue()
                    }else{
                        print("[Remove Token Error]: \(error?.localizedDescription ?? "")")
                    }
                })
            }else{
                self.addToken()
            }
        }
    }
    
    func connectedRef(){
        ref = Database.database().reference()
        let myConnectionRef = ref.child("UserActivities").child(userUID).child("Connections")
        let lastOnlineRef   = ref.child("UserActivities").child(userUID).child("Lastonline")
        let connectedRef    = Database.database().reference(fromURL: "https://jobseed-2cb76.firebaseio.com/.info/connected")
        connectedRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let connected = snapshot.value as! Bool
                if connected{
                    myConnectionRef.childByAutoId().setValue(true)
                    myConnectionRef.onDisconnectRemoveValue()
                    
                    lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
                }
            }
        }) { (error) in
            print("[Connection Reference Error]\n")
        }
    }
    
   
    
    func addToken(){
        let UID     = Auth.auth().currentUser?.uid
        let token = Messaging.messaging().fcmToken!
        print("========== FCM TOKEN ==========\n[FCM Token]: \(token)\n==========")

        if token != ""{
            let userActivitiesRef   = Database.database().reference().child("UserActivities")
            let chatTokensRef       = userActivitiesRef.child(UID!).child("ChatTokens")
            let applyTokensRef      = userActivitiesRef.child(UID!).child("ApplyTokens")
            let shortlistTokensRef  = userActivitiesRef.child(UID!).child("ShortlistTokens")
            let bookingTokensRef    = userActivitiesRef.child(UID!).child("BookingTokens")
            let hireTokensRef       = userActivitiesRef.child(UID!).child("HireTokens")

            let preferences     = UserDefaults.standard
            let newUserKey      = "newUser"
            
            if !(preferences.object(forKey: newUserKey) as! Bool) {
                print("\n[Check New User For Token]: User Not New User\n")
                userActivitiesRef.child(UID!).observeSingleEvent(of: .value) { (snapshot) in
                    print("========== Refresh Token ===========\n")
                    if snapshot.hasChild("ChatTokens"){
                        chatTokensRef.removeValue(completionBlock: { (error, ref) in
                            if error == nil{
                                chatTokensRef.child(token).setValue(true, withCompletionBlock: { (error, ref) in
                                    if error == nil{
                                        print("[ChatToken]          : Refreshed Done.")
                                    }
                                })
                            }
                        })
                        
                    }
                    if snapshot.hasChild("ApplyTokens"){
                        applyTokensRef.removeValue(completionBlock: { (error, ref) in
                            if error == nil{
                                applyTokensRef.child(token).setValue(true, withCompletionBlock: { (error, ref) in
                                    if error == nil{
                                        print("[ApplyToken]         : Refreshed Done.")
                                    }
                                })
                            }
                        })
                    }
                    if snapshot.hasChild("ShortlistTokens"){
                        shortlistTokensRef.removeValue(completionBlock: { (error, ref) in
                            if error == nil{
                                shortlistTokensRef.child(token).setValue(true, withCompletionBlock: { (error, ref) in
                                    if error == nil{
                                        print("[ShortlistTokens]    : Refreshed Done.")
                                    }
                                })
                            }
                        })
                    }
                    if snapshot.hasChild("BookingTokens"){
                        bookingTokensRef.removeValue(completionBlock: { (error, ref) in
                            if error == nil{
                                bookingTokensRef.child(token).setValue(true, withCompletionBlock: { (error, ref) in
                                    if error == nil{
                                        print("[BookingTokens]      : Refreshed Done.")
                                    }
                                })
                            }
                        })
                    }
                    if snapshot.hasChild("HireTokens"){
                        hireTokensRef.removeValue(completionBlock: { (error, ref) in
                            if error == nil{
                                hireTokensRef.child(token).setValue(true, withCompletionBlock: { (error, ref) in
                                    if error == nil{
                                        print("[HireTokens]         : Refreshed Done.\n")
                                    }
                                })
                            }
                        })
                    }
                }
            }else{
                print("\n[Check New User For Token]: User Is New User\n")

                chatTokensRef.child(token).setValue(true)
                applyTokensRef.child(token).setValue(true)
                shortlistTokensRef.child(token).setValue(true)
                bookingTokensRef.child(token).setValue(true)
                hireTokensRef.child(token).setValue(true) { (error, ref) in
                    if error == nil{
                        preferences.set(false, forKey: newUserKey)
                    }
                }
            }
        }else{
            print("[Add Token] FCM Token is Empty!")
        }
    }
    
//    func updateUserToken(){
//        let userActivitiesRef   = Database.database().reference().child("UserActivities").child(userUID)
//        let newChatTokens       = userActivitiesRef.child("ChatTokens")
//        let newApplyTokens      = userActivitiesRef.child("ApplyTokens")
//        let newShortlistTokens = userActivitiesRef.child("ShortlistTokens")
//        let newBookingTokens    = userActivitiesRef.child("BookingTokens")
//        let newHireTokens       = userActivitiesRef.child("HireTokens")
//
//        userActivitiesRef.child("Tokens").observeSingleEvent(of: .value, with: { (snapshot) in
//            if (snapshot.exists()){
//                newApplyTokens.setValue(snapshot.value)
//                newShortlistTokens.setValue(snapshot.value)
//                newBookingTokens.setValue(snapshot.value)
//                newHireTokens.setValue(snapshot.value)
//                newChatTokens.setValue(snapshot.value, withCompletionBlock: { (error, complete) in
//                    userActivitiesRef.child("Tokens").removeValue()
//                })
//            }else{
//                //Add Token Func
//                self.addToken()
//            }
//        }) { (error) in
//            print("[Update User Token Error]\n")
//        }
//    }
    
    func checkApplicantPass24(){
        
        let pendingApplicantRef = Database.database().reference().child("UserPostedPendingApplicants")
        pendingApplicantRef.child(userUID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("\n[Applicant Passed 24 Hour Check]")

            let pendingApplicantSnapShot = snapshot.children.allObjects as! [DataSnapshot]
            
            for detail in pendingApplicantSnapShot{
                let postKey         = detail.key
                let userSnapShot    = detail.children.allObjects as! [DataSnapshot]
                
                for userDetail in userSnapShot{
                    let userID          = userDetail.key
                    let time            = userDetail.childSnapshot(forPath: "time").value as? TimeInterval
                    let pressedValue    = userDetail.childSnapshot(forPath: "pressed").value as! String
                    
                    //Do Date Comparison
                    let convertedTime = Utilities.convertServerTimestamp(timestamp: time!)
                    print("[checkApplicantPass24 Converted Time]: \(convertedTime)")
                    let addedTime   = Calendar.current.date(byAdding: .hour, value: 24 + 8 , to: convertedTime)
                    let currentTime = Date()
                    
                    if addedTime! < currentTime{
                        self.deleteApplicant(targetKey: postKey, targetID: userID, targetPressedValue: pressedValue)
                    }
                }
            }
        }) { (error) in
            print("[Check Applicant Passed 24hr Error]: \(error.localizedDescription)\n")
        }
        
    }
    
    func checkAppliedJobPass24(){
        let appliedJobQuery : DatabaseQuery = Database.database().reference().child("UserActivities").child(userUID).child("Applied").queryOrdered(byChild: "status").queryEqual(toValue: "applied")
        appliedJobQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            print("\n[Applied Job Passed 24 Hour Check]")

            for userSnapShot in snapshot.children.allObjects as! [DataSnapshot]{
                let postKey = userSnapShot.key
                if userSnapShot.hasChild("time"){
                    let time = userSnapShot.childSnapshot(forPath: "time").value as? TimeInterval
                    //Do Date Comparison
                    
                    let convertedTime = Utilities.convertServerTimestamp(timestamp: time!)
                    print("[checkApplicantPass24 Converted Time]: \(convertedTime)")
                    
                    let expiredTime   = Calendar.current.date(byAdding: .hour, value: 24, to: convertedTime)
                    let currentTime   = Date()
                    
                    print("[Current Time]: \(currentTime)")
                    print("[Expired Time]: \(expiredTime!))")
                    
                    if expiredTime! < currentTime{
                        print("[Over 24 Hour]")
                        let userActivitiesRef   = Database.database().reference().child("UserActivities").child(self.userUID)
                        userActivitiesRef.child("NewMainNotification").setValue("true")
                        userActivitiesRef.child("NewApplied").setValue("true")
                        userActivitiesRef.child("Applied").child(postKey).child("status").setValue("appliedrejected")
                        userActivitiesRef.child("Applied").child(postKey).child("pressed").setValue("false")

                    }
                }
            }
        }) { (error) in
            print("[Check Applied Job Over 24 Hour Error]: \(error.localizedDescription)")
        }
        
    }
    
    func checkAccepted(){
        let acceptedQuery: DatabaseQuery = Database.database().reference().child("UserActivities").child(userUID).child("Applied").queryOrdered(byChild: "status").queryEqual(toValue: "acceptedoffer")
        
        acceptedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            print("\n[Accepted Job Passed 24 Hour Check]")

            for detail in snapshot.children.allObjects as! [DataSnapshot]{
                let postKey = detail.key
                
                var seperated   = [String]()
                var lastDate    = String()
                
                if !detail.hasChild("reviewed"){
                    if detail.hasChild("date"){
                        let reviewDate = detail.childSnapshot(forPath: "date").value as! String
                        //Do Date seperation
                        print(reviewDate)
                        
                        if(!reviewDate.contains("to")){
                            seperated   = reviewDate.components(separatedBy: "/")
                            lastDate    = seperated[seperated.count - 1]
                        }else{
                            seperated   = reviewDate.components(separatedBy: " to ")
                            lastDate    = seperated[1]
                        }
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yy"
                        let endDate = formatter.date(from: lastDate)
                        let addedDate = Calendar.current.date(byAdding: .hour, value: 0, to: endDate!)
                        let currentDate = Date()
                        
                        if addedDate! < currentDate{
                            if !detail.hasChild("reviewpressed"){
                                let userActivitiesRef   = Database.database().reference().child("UserActivities").child(self.userUID)
                                userActivitiesRef.child("Applied").child(postKey).child("reviewpressed").setValue("false")
                                    userActivitiesRef.child("NewMainNotification").setValue("true")
                                    userActivitiesRef.child("NewApplied").setValue("true")
                            }
                        }
                    
                    }
                }
            }
            
        }) { (error) in
            print("[Check Accepted Job Error]: \(error.localizedDescription)")
        }
    }
    
    
    func checkBooking(){
        let checkBookingQuery: DatabaseQuery = Database.database().reference().child("UserBookingMade").child(userUID).queryOrdered(byChild: "status").queryEqual(toValue: "acceptedbooking")
        
        checkBookingQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            print("\n[Booking Passed 24 Hour Check]")

            for bookingDetail in snapshot.children.allObjects as! [DataSnapshot]{
                let postKey = bookingDetail.key
                
                if (!bookingDetail.hasChild("reviewed")){

                    if (bookingDetail.hasChild("dates")){
                        
                        var seperated   = [String]()
                        var lastDate    = String()
                        
                        let bookingDate = bookingDetail.childSnapshot(forPath: "dates").value as! String
                        print(bookingDate)

                        if(!bookingDate.contains("to")){
                            seperated   = bookingDate.components(separatedBy: "/")
                            lastDate    = seperated[seperated.count - 1]
                        }else{
                            seperated   = bookingDate.components(separatedBy: " to ")
                            lastDate    = seperated[1]
                        }
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yy"
                        let endDate = formatter.date(from: lastDate)
                        let addedDate = Calendar.current.date(byAdding: .hour, value: 0, to: endDate!)
                        let currentDate = Date()
                        
                        if addedDate! < currentDate{
                            if !bookingDetail.hasChild("reviewpressed"){
                                let userActivitiesRef   = Database.database().reference().child("UserActivities").child(self.userUID)
                                let bookingActRef = Database.database().reference().child("UserBookingMade")
                            bookingActRef.child(self.userUID).child(postKey).child("reviewpressed").setValue("false")
                                userActivitiesRef.child("NewTalentMainNotification").setValue("true")
                                userActivitiesRef.child("NewBookingsMade").setValue("true")
                            }
                        }
                    }
                }
            }
            
        }) { (error) in
            print("[Check Booking Error]: \(error.localizedDescription)")
        }
        
        
    }
    
    func deleteApplicant(targetKey: String, targetID: String, targetPressedValue: String){
        ref = Database.database().reference()
        //For More Than 1 day, Remove Record
        ref.child("UserPostedPendingApplicants").child(userUID).child(targetKey).child(targetID).removeValue()
        //Decrement Applicant Count
        decrementApplicantsCount(selfID: userUID, key: targetKey)
        //Decrement New Applicant Count for Unpressed
        if targetPressedValue == "false"{
            decreamentNewApplicantCount(selfID: userUID, key: targetKey)
        }
        
        ref.child("UserActivities").child(targetID).child("Applied").child(targetKey).observeSingleEvent(of: .value, with: { (snapshot) in
            //Check user Applied Tab
            if snapshot.exists(){
                //If User Still Have Job, check job status reject or not
                if snapshot.hasChild("status"){
                    let status = snapshot.childSnapshot(forPath: "status").value as! String
                    if status == "applied"{
                        self.ref.child(targetID).child("NewMainNotification").setValue("true")
                        self.ref.child(targetID).child("NewApplied").setValue("true")
                        self.ref.child(targetID).child("Applied").child("status").setValue("appliedrejected")
                        self.ref.child(targetID).child("Applied").child("pressed").setValue("false")
                    }
                }
            }
            
        }) { (error) in
            print("[Delete Applicant Error]: \(error.localizedDescription)")
        }
        
        //This is set to remember user has been rejected once, so user can only re-apply ONE MORE time
        ref.child(targetID).child("RejectedApplied").child(targetKey).childByAutoId().setValue("true")
        

    }
    
    func decrementApplicantsCount(selfID: String, key: String ){
        ref = Database.database().reference()
        ref.child("UserPosted").child(selfID).child(key).child("applicantscount").runTransactionBlock { (applicantData) -> TransactionResult in
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
    
    func decreamentNewApplicantCount(selfID: String, key: String){
        ref = Database.database().reference()
        ref.child("UserPosted").child(selfID).child(key).child("newapplicantscount").runTransactionBlock { (newApplicantData) -> TransactionResult in
            if newApplicantData.value != nil{
                if newApplicantData.value as! Double == 0{
                    newApplicantData.value = 0
                }else{
                    if let newApplicantValue = newApplicantData.value as? Double{
                        newApplicantData.value = newApplicantValue
                    }
                    
                }
            }
            return TransactionResult.success(withValue: newApplicantData)
        }
    }
    
    
    func getCurrentLocation(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("[Location Service Enabled]")
            locationManager.delegate        = self

            if (CLLocationManager.authorizationStatus() == .denied ) ||
                (CLLocationManager.authorizationStatus() == .restricted) ||
                (CLLocationManager.authorizationStatus() == .notDetermined){
                
//                removeLoadingScreen()
//                noJobView.isHidden = false
                promptLocationAlert()
                
                self.city = "Penang"
                stateLabel.text = "Penang"
                checkSortFilter()
            }
            
            else{
                print("[Location Manager]: Service Enabled")
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                locationManager.stopUpdatingLocation()
            }
            
        }else{
            print("No Location Service")
            promptLocationAlert()
            self.city = "Penang"
            stateLabel.text = "Penang"
            checkSortFilter()
        }
    }
    
    //Current Not Using
    func promptLocationAlert(){
        
        let alertVC = UIAlertController(title: "Location Service is not enabled", message: "You are require to enable location service for nearby Job", preferredStyle: .alert )
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) { value in
            let path = "App-Prefs:root=Privacy&path=LOCATION_SERVICES"
            //            UIApplicationOpenSettingsURLString
            if let settingsURL = URL(string: path), UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.openURL(settingsURL)
            }
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedAlways || status == .authorizedWhenInUse ){
            locationManager.startUpdatingLocation()
        }else{
            promptLocationAlert()
        }
    }
    
    func displayUpdateAlertMessage(promptMessage:String, prompType: String , latestVersion: String){
        
        switch (prompType) {
            
        case "1":
            let myAlert = UIAlertController(title:"New Version", message: promptMessage, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title:"Update", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                UIApplication.shared.openURL(URL.init(string: "https://24hires.com/")!)
                print("[ Optional ][CheckVersion]: Agree To Update\n")
            })
            let cancelAct = UIAlertAction(title:"Ignore", style: UIAlertActionStyle.default, handler:{(UIAlertAction) in
                // Update action
                print("[ Optional ][CheckVersion]: Ignore Update\n")

            })
            myAlert.addAction(okAction)
            myAlert.addAction(cancelAct)
            self.present(myAlert, animated: true, completion: nil)
            break
            
        case "2":
            var updateFlag : String = ""
            if let flag: String = UserDefaults.standard.object(forKey: "UpdatePrompt") as? String{
                updateFlag = flag
            }else{
                UserDefaults.standard.set("", forKey: "UpdatePrompt")
            }
            
            if updateFlag == "" || updateFlag != latestVersion{
                
                let myAlert = UIAlertController(title:"New Version", message: promptMessage, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title:"Update", style: UIAlertActionStyle.default, handler:{(UIAlertAction) in
                    print("[ OneTime ][CheckVersion]: Agree To Update\n")
                    UserDefaults.standard.set(latestVersion, forKey: "UpdatePrompt")
                    UIApplication.shared.openURL(URL.init(string: "https://24hires.com/")!)
                })
                let cancelAct = UIAlertAction(title:"Ignore", style: UIAlertActionStyle.default, handler:{(UIAlertAction) in
                    // Update action save status to DB
                    print("[ OneTime ][CheckVersion]: Ignore Update\n")
                    UserDefaults.standard.set(latestVersion, forKey: "UpdatePrompt")
                })
                myAlert.addAction(okAction)
                myAlert.addAction(cancelAct)
                self.present(myAlert, animated: true, completion: nil)
                break
            }else{
                print("[Check Version]: Ignore Update for version: \(updateFlag)\n")
            }
            
        
        case "3":
            let myAlert = UIAlertController(title:"Software Update", message: promptMessage, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title:"Update", style: UIAlertActionStyle.default, handler:{(UIAlertAction) in
                self.checkVersion()
                UIApplication.shared.openURL(URL.init(string: "https://24hires.com/")!)
                print("[ Must ] [CheckVersion]: Update\n")
                
            })
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            break
            
        default:
            //Not Show Update window
            break
        }
        
    }
    
    
    
    func checkSortFilter() {
        
        ref             = Database.database().reference()
        
        let currentUser     = Auth.auth().currentUser
       
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            ref.child("SortFilter").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    return
                }
                
                if snapshot.childSnapshot(forPath: uid!).exists() {
                    //Got start no end
                    if (snapshot.childSnapshot(forPath: uid!).hasChild("StartDate") && !snapshot.childSnapshot(forPath: uid!).hasChild("EndDate")) {
                        
                        self.filterbystart = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "StartDate").value as! String
                        print("filterbystart sortfilter = \(self.filterbystart)")
                        self.filterbyend = ""
                        
                        //If user chose SHOW ALL WAGES
                        if (snapshot.childSnapshot(forPath: uid!).hasChild("OldWagesFilter")) {
                            self.scenario = 11
                            self.oldfilterbywages = "true"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "OldWagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "1"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                            
                        }
                        
                        //If user chose SPECIFIC range
                        else if (snapshot.childSnapshot(forPath: uid!).hasChild("WagesFilter")) {
                            self.scenario = 1
                            self.oldfilterbywages = "false"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "2"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                        
                        //If user leave to default
                        else {
                            self.scenario = 11
                            self.oldfilterbywages = "true"
                            self.filterbywages = 1111 //default value = MYR + per hour + Less Than 5
                            self.filterNumLabel.text = "1"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                    }
                    
                    
                    //Got start Got end
                    else if (snapshot.childSnapshot(forPath: uid!).hasChild("StartDate") && snapshot.childSnapshot(forPath: uid!).hasChild("EndDate")) {
                        
                        self.filterbystart = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "StartDate").value as! String
                        
                        self.filterbyend = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "EndDate").value as! String
                        
                        //If user chose SHOW ALL WAGES
                        if (snapshot.childSnapshot(forPath: uid!).hasChild("OldWagesFilter")) {
                            self.scenario = 22
                            self.oldfilterbywages = "true"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "OldWagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "2"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                            
                        }
                            
                        //If user chose SPECIFIC range
                        else if (snapshot.childSnapshot(forPath: uid!).hasChild("WagesFilter")) {
                            self.scenario = 2
                            self.oldfilterbywages = "false"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "3"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                            
                        //If user leave to default
                        else {
                            self.scenario = 22
                            self.oldfilterbywages = "true"
                            self.filterbywages = 1111 //default value = MYR + per hour + Less Than 5
                            self.filterNumLabel.text = "2"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                    }
                    
                    
                    //NO start NO end
                    else {
                        
                        self.filterbystart = ""
                        
                        self.filterbyend = ""
                        
                        //[NO START/ END DATE] SHOW ALL WAGES
                        if (snapshot.childSnapshot(forPath: uid!).hasChild("OldWagesFilter")) {
                            self.scenario = 33
                            self.oldfilterbywages = "true"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "OldWagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "0"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                            
                        }
                            
                            //If user chose SPECIFIC range
                        else if (snapshot.childSnapshot(forPath: uid!).hasChild("WagesFilter")) {
                            self.scenario = 3
                            self.oldfilterbywages = "false"
                            let Doublefilterbywages = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WagesFilter").value as! Double
                            self.filterbywages = Int(Doublefilterbywages)
                            self.filterNumLabel.text = "1"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                            
                        //If user leave to default
                        else {
                            self.scenario = 33
                            self.oldfilterbywages = "true"
                            self.filterbywages = 1111 //default value = MYR + per hour + Less Than 5
                            self.filterNumLabel.text = "0"
                            self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
                        }
                    }
                }
                else {
                    print("no User SortFilter")
                    self.scenario = 33
                    self.oldfilterbywages = "true"
                    self.filterbywages = 1111 //default value = MYR + per hour + Less Than 5
                    self.filterNumLabel.text = "0"
                    self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario
                    )
                }
                
            })
        }
    }
    
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    
    func loadData(filterbystart:String, filterbyend:String, filterbywages:Int, scenario:Int){
        
        print("Start Job Loading\n=================")
        print("[Load Job] scenario : \(scenario)")
        print("[Load Job] Location : \(self.city)")
        
        print("Clearing Old Post Data ===> Old Post Count: \(posts.count)")
        posts.removeAll()
        print("[Load Job] Cleared Post Data : \(posts.count)\n")
        
        var intwages         :Int64   = 0
        var currencyint      :Int64   = 0
        var wagescategoryint :Int64   = 0
        
        var mQueryJob: DatabaseQuery!
        let ref = Database.database().reference()

        if (filterbywages != 0) {
            // get currency number
            intwages = Int64(filterbywages % 100000)
            let stringintwages = String(intwages)
            let index = stringintwages.index(stringintwages.startIndex, offsetBy: 2)
            
            currencyint = Int64(stringintwages.substring(to: index))!
            
            // get wagescategory number
            wagescategoryint = intwages % 100
        }
        
        let tsLong: Int64 = Utilities.getCurrentMillis()/1000
       
        if (filterbystart != "") {
            startdate = Int64(filterbystart)!
        }
        if (filterbyend != "") {
            enddate = Int64(filterbyend)!
        }
        
        print("/////////////////////Home Category Scenario = \(scenario)//////////////////////////")

        //GOT START NO END
        if (scenario == 1) {
            
            //Got Wagesfilter
            
            let opsOne      : Int64 = (startdate * 100000000) + (wagescategoryint * 100000000000000)
            let opsTwo      : Int64 = (currencyint * 10000000000000000)
            let opsThree    : Int64 = opsOne + opsTwo
            
            finalstarttime = -1 * opsThree
            
//[original]  finalstarttime = -1 * Int64( (startdate * 100000000) + (wagescategoryint * 100000000000000) + (currencyint * 10000000000000000) )
            let nineInt64   : Int64 = 999999
            let tenInt64    : Int64 = 100000000
            
            let multiple    : Int64 = Int64(nineInt64 * tenInt64)
            let wagescategoryintOpreation = Int64(wagescategoryint * 100000000000000)
            let currencyIntOperation = Int64(currencyint * 10000000000000000)
            
            let endtime :Int64 = Int64( tsLong + multiple + wagescategoryintOpreation + currencyIntOperation )
            
            let finalendtime = endtime * -1
            
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_wagesrange_startdate").queryStarting(atValue: finalendtime).queryEnding(atValue: finalstarttime)
        }
        
        else if (scenario == 11) {
            
            //No Wagesfilter =  OldWagesFilter
            
            let startString = Int64(filterbystart + "0000000000")
            finalstarttime = -1 * startString!
            
            let endtime =  tsLong + (999999 * 10000000000)
            let finalendtime = endtime * -1
            
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_startdate").queryStarting(atValue: finalendtime).queryEnding(atValue: finalstarttime)
        }
        
            
        //GOT START GOT END
        else if (scenario == 2) {
            
            //Got Wagesfilter
            
            let opsOne :Int64 = (startdate * 100000000) + (wagescategoryint * 100000000000000)
            let opsTwo :Int64 = (currencyint * 10000000000000000)
            let opsThree : Int64 = opsOne + opsTwo
            
            finalstarttime = -1 * opsThree
            
//            finalstarttime = -1 * Int64( (startdate * 100000000) + (wagescategoryint * 100000000000000) + (currencyint * 10000000000000000) )
            
            let smalltsLong = tsLong % 100000000
            let endDateOperation = Int64(enddate * 100000000)
            
            let endtime1 =  Int64( smalltsLong + endDateOperation)
            
            let wagescategoryintOperation = Int64(wagescategoryint * 100000000000000)
            
            let currencyintOperation = Int64(currencyint * 10000000000000000)
            
            let endtime2 =  Int64( endtime1 + wagescategoryintOperation + currencyintOperation)
            let finalendtime = endtime2 * -1
            
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_wagesrange_startdate").queryStarting(atValue: finalendtime).queryEnding(atValue: finalstarttime)
        }
        
        else if (scenario == 22) {
            
            //No Wagesfilter =  OldWagesFilter
           
            finalstarttime = -1 * Int64(startdate * 10000000000)
            let endDateOperation = Int64(enddate * 10000000000)
            let endtime =  Int64( tsLong + endDateOperation)
            let finalendtime = endtime * -1
            
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_startdate").queryStarting(atValue: finalendtime).queryEnding(atValue: finalstarttime)
        }
        
            
        //NO START NO END
        else if (scenario == 3) {
            
            //Got Wagesfilter
            
            print("currencyint = \(currencyint)")
            print("wagescategoryint = \(wagescategoryint)")
            
            let currencylong = Int64(currencyint * 1000000000000)
            let wagescategorylong = Int64(wagescategoryint * 10000000000)

            let startwagesfilter =  wagescategorylong + currencylong
            finalstartwagesfilter = -1 * startwagesfilter
            
            let endwagesfilter =  tsLong + wagescategorylong + currencylong
            let finalendwagesfilter = -1 * endwagesfilter
            
            print("finalendwagesfilter = \(finalendwagesfilter)")
            print("finalstartwagesfilter = \(finalstartwagesfilter)")
            
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_wagesrange").queryStarting(atValue: finalendwagesfilter).queryEnding(atValue: finalstartwagesfilter)
        }
        
        else if (scenario == 33 || scenario == 0) {

            //No WagesFilter = OldWagesFilter
            mQueryJob = ref.child("Job").child(self.city).queryOrdered(byChild: "negatedtime")
        }
        
        else {
            return
        }
        
        ref.child("Job").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                self.removeLoadingScreen()
                self.noJobView.isHidden = false
                self.noJobLabel.text = "Sorry, it looks like there aren't any jobs available in \(self.city)"
                return
            }
            
            if !snapshot.childSnapshot(forPath: self.city).exists() {
                self.removeLoadingScreen()
                self.noJobView.isHidden = false
                self.noJobLabel.text = "Sorry, it looks like there aren't any jobs available in \(self.city)"
                return
            }
            
            mQueryJob.queryLimited(toFirst: UInt(self.loadlimit)).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.removeLoadingScreen()
                    self.noJobView.isHidden = false
                    self.noJobLabel.text = "Sorry, it looks like there aren't any jobs available in \(self.city)"
                    return
                    
                }else{
                    print("Getting Job\n===========")
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        let postpost = Post()
                        
                        guard let restDict = rest.value as? [String: Any] else { continue }
                        
                        if let userID = restDict["uid"] as? String,
                            let postImage       = restDict["postimage"] as? String,
                            let postTitle       = restDict["title"] as? String,
                            let postCategory    = restDict["category"] as? String,
                            let postDesc        = restDict["desc"] as? String,
                            let postDate        = restDict["date"] as? String,
                            let postWages       = restDict["wages"] as? String,
                            let postCompany     = restDict["company"] as? String,
                            let postClosed      = restDict["closed"] as? String,
                            let postTime        = restDict["negatedtime"] as? TimeInterval,
                            let mrecent_startdate   = restDict["mostrecent_startdate"] as? Int64,
                            let mrecent_wagesrange  = restDict["mostrecent_wagesrange"] as? Int64,
                            let mrecent_wagesrange_startdate = restDict["mostrecent_wagesrange_startdate"] as? Int64,
                            let postKey         = rest.key as? String,
                            let postCity        = restDict["city"] as? String,
                            let postLocation    = restDict["fulladdress"] as? String {
                            
                            print("Job Title : \(postTitle)")
                            
                            postpost.postTitle      = postTitle
                            postpost.postImage      = postImage
                            postpost.userID         = userID
                            postpost.postCategory   = postCategory
                            postpost.postDesc       = postDesc
                            postpost.postDate       = postDate
                            postpost.postWages      = postWages
                            postpost.postCompany    = postCompany
                            postpost.postLocation   = postLocation
                            postpost.postClosed     = postClosed
                            postpost.postKey        = postKey
                            postpost.postCity       = postCity
                            
                            
                            if(postClosed == "false"){
                                
                                self.posts.append(postpost)
                                self.lastpostTime = postTime
                                self.mostrecent_startdate = mrecent_startdate
                                self.mostrecent_wagesrange = mrecent_wagesrange
                                self.mostrecent_wagesrange_startdate = mrecent_wagesrange_startdate
                                
                            }
                            
                        }
                    }
                }
                print("============================================")
                print("[Total Job Count] : \(self.posts.count)")
                print("============================================\n")

                self.jobtableView.reloadData()
                self.jobtableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.removeLoadingScreen()
                self.noJobView.isHidden = true
                
            })
        })

        ref.removeAllObservers()
    }
    
    func loadTalentImage(){
        let ref = Database.database().reference()
        
        ref.child("TalentComingSoon").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            if let image = snapshot.value as? String {
                self.talentImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "addphoto_darker_bg"))
            }
        })
    }
    

    func loadMoreData(){
        
        //self.posts.removeAll()
        
        let ref = Database.database().reference()
        
        var firstkey = true
        
        var counttime = 1
        
        var postoldTime: TimeInterval!
        
        var mQueryLoadMore: DatabaseQuery!
        
        print("scenario load more = \(self.scenario)")
        
        //GOT start NO end
        if (self.scenario == 1 || self.scenario == 2) {
            
            //Got WagesFilter
            
            mQueryLoadMore = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_wagesrange_startdate").queryLimited(toFirst: UInt(loadlimit+1)).queryStarting(atValue: self.mostrecent_wagesrange_startdate).queryEnding(atValue: finalstarttime)
        }
        
        else if (self.scenario == 11 || self.scenario == 22) {
            
            //No WagesFilter
            
            mQueryLoadMore = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_startdate").queryLimited(toFirst: UInt(loadlimit+1)).queryStarting(atValue: self.mostrecent_startdate).queryEnding(atValue: finalstarttime)
            
        }
        
        else if (self.scenario == 3) {
            
            //Got WagesFilter
            
            mQueryLoadMore = ref.child("Job").child(self.city).queryOrdered(byChild: "mostrecent_wagesrange").queryLimited(toFirst: UInt(loadlimit+1)).queryStarting(atValue: self.mostrecent_wagesrange).queryEnding(atValue: finalstartwagesfilter)
            
            print("self.mostrecent_wagesrange load more = \(self.mostrecent_wagesrange)")
            
        }
        
        else if (self.scenario == 33 || self.scenario == 0) {
            
            //Got WagesFilter
            
            mQueryLoadMore = ref.child("Job").child(self.city).queryOrdered(byChild: "negatedtime").queryLimited(toFirst: UInt(loadlimit+1)).queryStarting(atValue: self.lastpostTime)
            
        }
        
        mQueryLoadMore.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                counttime += 1
                
                let postpost = Post()
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                if let userID = restDict["uid"] as? String,
                    let postImage = restDict["postimage"] as? String,
                    let postTitle = restDict["title"] as? String,
                    let postCategory = restDict["category"] as? String,
                    let postDesc = restDict["desc"] as? String,
                    let postDate = restDict["date"] as? String,
                    let postWages = restDict["wages"] as? String,
                    let postCompany = restDict["company"] as? String,
                    let postClosed = restDict["closed"] as? String,
                    let postKey = rest.key as? String,
                    let postTime = restDict["negatedtime"] as? TimeInterval,
                    let mrecent_startdate = restDict["mostrecent_startdate"] as? Int64,
                    let mrecent_wagesrange = restDict["mostrecent_wagesrange"] as? Int64,
                    let mrecent_wagesrange_startdate = restDict["mostrecent_wagesrange_startdate"] as? Int64,
                    let postCity = restDict["city"] as? String,
                    let postLocation = restDict["fulladdress"] as? String {
                    
                    print("loadmoretitle \(postTitle)")
                    print("mrecent_wagesrange \(mrecent_wagesrange)")
                    
                    postpost.postTitle = postTitle
                    postpost.postImage = postImage
                    postpost.userID = userID
                    postpost.postCategory = postCategory
                    postpost.postDesc = postDesc
                    postpost.postDate = postDate
                    postpost.postWages = postWages
                    postpost.postCompany = postCompany
                    postpost.postLocation = postLocation
                    postpost.postClosed = postClosed
                    postpost.postCity = postCity
                    postpost.postKey = postKey
                   
                    
                    if(firstkey){
                        firstkey = false
                    }
                    else{
                        if(postClosed == "false"){
                            
                            self.posts.append(postpost)
                            
                            self.lastpostTime = postTime
                            self.mostrecent_startdate = mrecent_startdate
                            self.mostrecent_wagesrange = mrecent_wagesrange
                            self.mostrecent_wagesrange_startdate = mrecent_wagesrange_startdate
                            
                            if(counttime >= self.loadlimit){
                                if(postTime == postoldTime){
                                    self.loadingData = true
                                }
                                else{
                                    self.loadingData = false
                                }
                            }
                            postoldTime = postTime
                        }
                    }
                }
            }
            
            self.jobtableView.reloadData()
            self.pagingindicator.stopAnimating()
            self.jobtableView.tableFooterView = nil
            self.jobtableView.tableFooterView?.isHidden = true
           
        })
        
        ref.removeAllObservers()
        
        /* Code to refresh table view
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            //self.loadingData = false
            self.jobtableView.reloadData()
            self.pagingindicator.stopAnimating()
            self.jobtableView.tableFooterView = nil
            self.jobtableView.tableFooterView?.isHidden = true
      
        }*/
    }
    
    private func setFooterIndicator(){
       
        pagingindicator.activityIndicatorViewStyle = .gray
        pagingindicator.startAnimating()
        pagingindicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: jobtableView.bounds.width, height: CGFloat(44))
        
        self.jobtableView.tableFooterView = pagingindicator
        self.jobtableView.tableFooterView?.isHidden = false
        
        loadMoreData()
        
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        loadingBall.type            = .ballPulseSync
        loadingBall.startAnimating()
        loadingBallView.isHidden    = false
        loadingBallView.alpha       = 1.0
        
        loadingView.isHidden    = false
        filterView.isHidden     = true
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        filterView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
    
    //MARK: - OBJ C Function
    
    @objc func refresh() {
        // Code to refresh table view
        posts.removeAll()
        loadingData = false
        //startdate = 0
       // enddate = 0
       // wagescategory = 0
        //filterbywages = 0
        //filterbystart = ""
       // filterbyend = ""
        self.loadData(filterbystart:self.filterbystart, filterbyend:self.filterbyend, filterbywages:self.filterbywages, scenario:self.scenario)
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.refreshControl.endRefreshing()
        }
    }
    @objc func updateFilter(_ notification: NSNotification) {
        
        if let scenarioval = notification.userInfo?["scenario"] as? Int,
            let filterbywagesval = notification.userInfo?["filterbywages"] as? Int,
            let filterbystartval = notification.userInfo?["filterbystart"] as? String,
            let filterbyendval = notification.userInfo?["filterbyend"] as? String,
            let oldfilterbywagesval = notification.userInfo?["oldfilterbywages"] as? String
            
        {
            self.scenario = scenarioval
            self.filterbywages = filterbywagesval
            self.filterbystart = filterbystartval
            self.filterbyend = filterbyendval
            self.oldfilterbywages = oldfilterbywagesval
            
            print("filterbywages = \(filterbywages)")
            print("filterbystart = \(filterbystart)")
            print("filterbyend = \(filterbyend)")
            print("oldfilterbywages = \(oldfilterbywages)")
            
            if (scenarioval == 33) {
                self.filterNumLabel.text = "0"
            }
            else if (scenarioval == 11 || scenarioval == 3) {
                self.filterNumLabel.text = "1"
            }
            else if (scenarioval == 22 || scenarioval == 1) {
                self.filterNumLabel.text = "2"
            }
            else if (scenarioval == 2) {
                self.filterNumLabel.text = "3"
            }
            
            setLoadingScreen()
            if (self.city != ""){
                refresh()
            }
            else {
                removeLoadingScreen()
            }
        }
    }
    
    @objc func updateLocation(_ notification: NSNotification) {
        //Notification Action From State List
        
        if let locationval = notification.userInfo?["location"] as? String {
            if (locationval != "") {
                locationManager.stopUpdatingLocation()
                
                self.city = locationval
                stateLabel.text = self.city
//                stateButton.setTitle(self.city, for: .normal)
                refresh()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updatedLocation")
        self.locationManager.stopUpdatingLocation()
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        self.getCityFromGeoCoordinate(latitude: locValue.latitude, longitude: locValue.longitude)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error getting location")
        self.city = ""
        self.removeLoadingScreen()
        self.noJobView.isHidden = false
        noJobLabel.text = "Please specify your location in order to see more jobs"
        topLocationLabel.text = "Specify your location"
    }
    
   
    
    func getCityFromGeoCoordinate(latitude: Double, longitude: Double){
        
        var center:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        
        center.latitude = latitude
        center.longitude = longitude
        
        let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
            if (error != nil){
                print("reverse geo error")
            }else{
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    self.city = pm.administrativeArea!
    
                    var administrativeArea = pm.administrativeArea
                    var subAdministrativeArea = pm.subAdministrativeArea
                    
                    if (subAdministrativeArea == nil) {
                        subAdministrativeArea = ""
                    }
                    
                    if (administrativeArea == nil) {
                        administrativeArea = ""
                    }
                    
                    if ( (administrativeArea!.contains("Pulau Pinang") || administrativeArea!.contains("Penang")) ||
                        (subAdministrativeArea!.contains("Pulau Pinang") || subAdministrativeArea!.contains("Penang")) ){
                        self.city = "Penang"
                    }
                    else if ( administrativeArea!.contains("Kuala Lumpur") || subAdministrativeArea!.contains("Kuala Lumpur") ){
                        self.city = "Kuala Lumpur"
                    }
                    else if ( administrativeArea!.contains("Labuan") || subAdministrativeArea!.contains("Labuan") ){
                        self.city = "Labuan"
                    }
                    else if ( administrativeArea!.contains("Putrajaya") || subAdministrativeArea!.contains("Putrajaya") ){
                        self.city = "Putrajaya"
                    }
                    else if ( administrativeArea!.contains("Johor") || subAdministrativeArea!.contains("Johor") ){
                        self.city = "Johor"
                    }
                    else if ( administrativeArea!.contains("Kelantan") || subAdministrativeArea!.contains("Kelantan") ){
                        self.city = "Kelantan"
                    }
                    else if ( (administrativeArea!.contains("Melaka") || administrativeArea!.contains("Melacca")) ||
                        (subAdministrativeArea!.contains("Melaka") || subAdministrativeArea!.contains("Melacca")) ){
                        self.city = "Melacca"
                    }
                    else if ( (administrativeArea!.contains("Negeri Sembilan") || administrativeArea!.contains("Seremban")) ||
                        (subAdministrativeArea!.contains("Negeri Sembilan") || subAdministrativeArea!.contains("Seremban")) ){
                        self.city = "Negeri Sembilan"
                    }
                    else if ( administrativeArea!.contains("Pahang") || subAdministrativeArea!.contains("Pahang") ){
                        self.city = "Pahang"
                    }
                    else if ( (administrativeArea!.contains("Perak") || administrativeArea!.contains("Ipoh")) ||
                        (subAdministrativeArea!.contains("Perak") || subAdministrativeArea!.contains("Ipoh")) ){
                        self.city = "Perak"
                    }
                    else if (administrativeArea!.contains("Perlis") || subAdministrativeArea!.contains("Perlis") ){
                        self.city = "Perlis"
                    }
                    else if (administrativeArea!.contains("Sabah") || subAdministrativeArea!.contains("Sabah") ){
                        self.city = "Sabah"
                    }
                    else if (administrativeArea!.contains("Sarawak") || subAdministrativeArea!.contains("Sarawak") ){
                        self.city = "Sarawak"
                    }
                    else if (administrativeArea!.contains("Selangor") || administrativeArea!.contains("Selangor") || administrativeArea!.contains("Klang")){
                        self.city = "Selangor"
                    }
                    else if (administrativeArea!.contains("Terengganu") || subAdministrativeArea!.contains("Terengganu") ){
                        self.city = "Terengganu"
                    }
                    else if (administrativeArea!.contains("Limerick") || subAdministrativeArea!.contains("Limerick")){
                        self.city = "County Limerick"
                    }
                    
                    if (self.city != "") {
                        print(self.city)
                        if (!self.firstloadData) {
                            self.locationManager.stopUpdatingLocation()
                            self.stateLabel.text = self.city
                            //                        self.stateButton.setTitle(self.city, for: .normal)
                            self.checkSortFilter()
                            self.firstloadData = true
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Table View Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell2
        
        if (posts.count > indexPath.row) {
            
           
            cell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "addphoto_darker_bg"))
            
            
            cell.postTitle.text     = posts[indexPath.row].postTitle
            cell.postCategory.text  = posts[indexPath.row].postCategory
            cell.postCompany.text   = posts[indexPath.row].postCompany
            cell.postLocation.text  = posts[indexPath.row].postLocation
            cell.postDescrip.setLineHeight(lineHeight: 2, textstring: posts[indexPath.row].postDesc)
           
            
            if (posts[indexPath.row].postWages == "none"){
                cell.postWages.text = "Wages not disclosed"
            }
            else{
                cell.postWages.text = posts[indexPath.row].postWages
            }
            
            if (posts[indexPath.row].postDate == "none"){
                cell.postDate.text = "No Specified Date"
            }
            else{
                cell.postDate.text = posts[indexPath.row].postDate
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.postkey        = posts[indexPath.row].postKey
        self.selectedcity   = posts[indexPath.row].postCity
       
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
        nextViewController.postid = postkey
        nextViewController.modalTransitionStyle = .crossDissolve
        nextViewController.modalPresentationStyle = .fullScreen
        //self.presentDetail(nextViewController)
        self.present(nextViewController, animated:true, completion:nil)*/
        
        self.performSegue(withIdentifier: "JobDetail", sender: self)

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && !loadingData {
            print("[LAST CELL SHOWN]\n")
            loadingData = true
            setFooterIndicator()
        }
    }
    

    // MARK: - IBAction
    @IBAction func bannerPressed(_ sender: Any) {
        bannerRedirect(page: bannerPageControl.currentPage)
    }
    
    @IBAction func stateButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToStateList, sender: self)
    }
    
    @IBAction func chglocationPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToStateList, sender: self)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        print("pressed")
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_HomeToSearchMenu, sender: self)
    }
    
   
//    @IBAction func SearchClicked(_ sender: Any) {
//
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SearchesViewController") as! SearchesViewController
//        nextViewController.location = userCurrentLocation
//        self.navigationController?.pushViewController(nextViewController, animated: true)
//
//    }
    
    @IBAction func nearbyPressed(_ sender: Any) {
        print("Nearby")
       // self.performSegue(withIdentifier: "toNearbyJob", sender: self)
        let storyBoard : UIStoryboard = UIStoryboard(name: "NearbyJob", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "NearbyJobViewController") as! NearbyJobViewController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        nextViewController.filterbywages    = filterbywages
        nextViewController.filterbystart    = filterbystart
        nextViewController.filterbyend      = filterbyend
        nextViewController.oldfilterbywages = oldfilterbywages
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func segmentChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            talentView.isHidden = true
        }
        else {
            talentView.isHidden = false
        }
    }
    
    //Search Categories IBAction
    @IBAction func baristaPressed(_ sender: Any) {
        print("[Barista Catergory Selected]\n")
        categoryName    = "Barista / Bartender"
        categoryNumber  = 11
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func beautyPressed(_ sender: Any) {
        print("[Beauty Catergory Selected]\n")
        categoryName    = "Beauty / Wellness"
        categoryNumber  = 12
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func chefPressed(_ sender: Any) {
        print("[Chef Catergory Selected]\n")
        categoryName    = "Chef / Kitchen Helper"
        categoryNumber  = 13
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }

    @IBAction func eventCrewPressed(_ sender: Any) {
        print("[Event Catergory Selected]\n")
        categoryName    = "Event Crew"
        categoryNumber  = 14
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func emceePressed(_ sender: Any) {
        print("[Emcee Catergory Selected]\n")
        categoryName    = "Emcee"
        categoryNumber  = 15
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func educationPressed(_ sender: Any) {
        print("[Education Catergory Selected]\n")
        categoryName    = "Education"
        categoryNumber  = 16
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func fitnessPressed(_ sender: Any) {
        print("[Fitness Catergory Selected]\n")
        categoryName    = "Fitness / Gym"
        categoryNumber  = 17
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func modellingPressed(_ sender: Any) {
        print("[Modelling Catergory Selected]\n")
        categoryName    = "Modelling / Shooting"
        categoryNumber  = 18
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func mascotPressed(_ sender: Any) {
        print("[Mascot Catergory Selected]\n")
        categoryName    = "Mascot"
        categoryNumber  = 19
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func officePressed(_ sender: Any) {
        print("[Office Catergory Selected]\n")
        categoryName    = "Office / Admin"
        categoryNumber  = 20
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func promoterPressed(_ sender: Any) {
        print("[Promoter Catergory Selected]\n")
        categoryName    = "Promoter / Sampling"
        categoryNumber  = 21
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func roadshowPressed(_ sender: Any) {
        print("[Roadshow Catergory Selected]\n")
        categoryName    = "Roadshow"
        categoryNumber  = 22
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func rovingTeamPressed(_ sender: Any) {
        print("[Roving Catergory Selected]\n")
        categoryName    = "Roving Team"
        categoryNumber  = 23
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func retailPressed(_ sender: Any) {
        print("[Retail Catergory Selected]\n")
        categoryName    = "Retial / Consumer"
        categoryNumber  = 24
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func servingPressed(_ sender: Any) {
        print("[Serving Catergory Selected]\n")
        categoryName    = "Serving"
        categoryNumber  = 25
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func usherPressed(_ sender: Any) {
        print("[Usher Catergory Selected]\n")
        categoryName    = "Usher / Ambassador"
        categoryNumber  = 26
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func waiterPressed(_ sender: Any) {
        print("[Waiter Catergory Selected]\n")
        categoryName    = "Waiter / Waitress"
        categoryNumber  = 27
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
    @IBAction func otherPressed(_ sender: Any) {
        print("[Other Catergory Selected]\n")
        categoryName    = "Other"
        categoryNumber  = 28
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_homeToSearchCategory, sender: self)

    }
    
}
    


extension UIViewController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}
