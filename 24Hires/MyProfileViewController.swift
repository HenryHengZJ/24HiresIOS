//
//  MyProfileViewController.swift
//  JobIn24
//
//  Created by Jeekson on 18/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase
import GooglePlacePicker
import GoogleMaps

class MyProfileViewController: UIViewController, GMSPlacePickerViewControllerDelegate {
  
    //MARK:- IBOutlet & IBAction
    
    @IBOutlet weak var profileView          : UIView!
    @IBOutlet weak var aboutMeView          : UIView!
    @IBOutlet weak var locationView         : UIView!
    @IBOutlet weak var contactsView         : UIView!
    @IBOutlet weak var workExpView          : UIView!
    @IBOutlet weak var educationView        : UIView!
    @IBOutlet weak var languagesView        : UIView!
    @IBOutlet weak var reviewView           : UIView!
    @IBOutlet weak var noReviewView         : UIView!
    @IBOutlet weak var workExpView1         : UIView!
    @IBOutlet weak var workExpView2         : UIView!
    @IBOutlet weak var workExpView3         : UIView!
    @IBOutlet weak var workExpView4         : UIView!
    @IBOutlet weak var workExpView5         : UIView!
    @IBOutlet weak var usernameLabel        : UILabel!
    @IBOutlet weak var reviewNumberLabel    : UILabel!
    @IBOutlet weak var verifiedEmailLabel   : UILabel!
    @IBOutlet weak var profileProgressLabel : UILabel!
    @IBOutlet weak var aboutMeLabel         : UILabel!
    @IBOutlet weak var locationLabel        : UILabel!
    @IBOutlet weak var contactsLabel        : UILabel!
    @IBOutlet weak var companyLabel1        : UILabel!
    @IBOutlet weak var companyLabel2        : UILabel!
    @IBOutlet weak var companyLabel3        : UILabel!
    @IBOutlet weak var companyLabel4        : UILabel!
    @IBOutlet weak var companyLabel5        : UILabel!
    @IBOutlet weak var jobTitle1            : UILabel!
    @IBOutlet weak var jobTitle2            : UILabel!
    @IBOutlet weak var jobTitle3            : UILabel!
    @IBOutlet weak var jobTitle4            : UILabel!
    @IBOutlet weak var jobTitle5            : UILabel!
    @IBOutlet weak var educationLabel       : UILabel!
    @IBOutlet weak var languagesLabel       : UILabel!
    @IBOutlet weak var ratingBar            : CosmosView!
    @IBOutlet weak var coverPhotoImageView  : UIImageView!
    @IBOutlet weak var profileImageView     : UIImageView!
    @IBOutlet weak var verifiedEmailIcon    : UIImageView!
    @IBOutlet weak var profileProgressBar   : UIProgressView!
    @IBOutlet weak var segmentControlView   : SWSegmentedControl!

    @IBOutlet weak var EditProfilePicButton: UIButton!
    
    @IBAction func coverImgEditPressed(_ sender: Any) {
    }
    
    @IBAction func profileImgEditPressed(_ sender: Any) {
    }
    
    @IBAction func aboutMeEditPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_myProfileToEditAboutMe, sender: self)
    }
    
    @IBAction func locationEditPressed(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBAction func contactsEditPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_myProfileToEditEmail, sender: self)
    }
    
    @IBAction func workExpEditPressed(_ sender: Any) {
    }
    
    @IBAction func educationEditPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_myProfileToEditEducation , sender: self)
    }
    
    @IBAction func languagesEditPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_myProfileToEditLanguages, sender: self)
    }
    
    //MARK:- Variable Declaration
    
    let currentUser         = Auth.auth().currentUser
    let refUserAccount      = Database.database().reference().child("UserAccount")
    let refUserInfo         = Database.database().reference().child("UserInfo")
    let refUserReview       = Database.database().reference().child("UserReview")

    
    var userUID             : String?
    var userName            : String?
    var profileImageString  : String?
    var coverImageString    : String?
    var fiveStarRate        = 0
    var fourStarRate        = 0
    var threeStarRate       = 0
    var twoStarRate         = 0
    var oneStarRate         = 0
    var totalReviewCount    = 0
    var starRating          = 0.0
    var city                = ""
    var finalLatitude       = 0.0
    var finalLongitude      = 0.0
    
    
    
    //MARK:- VC Func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden      = true
        reviewView.isHidden = true
        pageSetup()
        getUserData()
        
        EditProfilePicButton.backgroundColor = .white
        workExpView2.isHidden = true
        workExpView3.isHidden = true
        workExpView4.isHidden = true
        workExpView5.isHidden = true
        
    }

    func pageSetup(){
        
        //Profile Picture
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds      = true
        profileImageView.layer.borderWidth  = 2.0
        profileImageView.layer.borderColor  = UIColor.white.cgColor
        
        //Shadow For View
        
        //Profile View
        profileView.layer.shadowColor   = UIColor.lightGray.cgColor
        profileView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        profileView.layer.shadowOpacity = 1.0
        profileView.layer.shadowRadius  = 3.0
        profileView.layer.masksToBounds = false
        
        //About Me
        aboutMeView.layer.shadowColor   = UIColor.lightGray.cgColor
        aboutMeView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        aboutMeView.layer.shadowOpacity = 1.0
        aboutMeView.layer.shadowRadius  = 3.0
        aboutMeView.layer.masksToBounds = false
        
        //Location
        locationView.layer.shadowColor   = UIColor.lightGray.cgColor
        locationView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        locationView.layer.shadowOpacity = 1.0
        locationView.layer.shadowRadius  = 3.0
        locationView.layer.masksToBounds = false
        
        //Contacts
        contactsView.layer.shadowColor   = UIColor.lightGray.cgColor
        contactsView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        contactsView.layer.shadowOpacity = 1.0
        contactsView.layer.shadowRadius  = 3.0
        contactsView.layer.masksToBounds = false
        
        //Work Exp
        workExpView.layer.shadowColor   = UIColor.lightGray.cgColor
        workExpView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        workExpView.layer.shadowOpacity = 1.0
        workExpView.layer.shadowRadius  = 3.0
        workExpView.layer.masksToBounds = false
        
        //Education
        educationView.layer.shadowColor   = UIColor.lightGray.cgColor
        educationView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        educationView.layer.shadowOpacity = 1.0
        educationView.layer.shadowRadius  = 3.0
        educationView.layer.masksToBounds = false
        
        //Languages
        languagesView.layer.shadowColor   = UIColor.lightGray.cgColor
        languagesView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
        languagesView.layer.shadowOpacity = 1.0
        languagesView.layer.shadowRadius  = 3.0
        languagesView.layer.masksToBounds = false
        
        locationLabel.adjustsFontSizeToFitWidth = true
    }
    
    //MARK:- Getting Data
    
    func getUserData(){
        
        if currentUser != nil{
            userUID = currentUser?.uid
            getUserName(uid: userUID!)
        }
    }
    
    func getUserName(uid: String){
        
       refUserInfo.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                if snapshot.hasChild("Name"){
                    self.userName = snapshot.childSnapshot(forPath: "Name").value as? String
                    self.usernameLabel.text = self.userName
                }else{
                    self.refUserAccount.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            if snapshot.hasChild("name"){
                                self.userName = snapshot.childSnapshot(forPath: "name").value as? String
                            
                                self.usernameLabel.text = self.userName
                            }
                        }
                    })
                }
            }
        }
        
        getImage()
    }
    
    func getImage(){
        refUserInfo.child(userUID!).observeSingleEvent(of: .value) { (snapshot) in
            //Found Profile Picture
            if snapshot.exists() && snapshot.hasChild("UserImage"){
                print("[Get Profile Image]  : Profile Image Found\n")
                
                self.profileImageString = snapshot.childSnapshot(forPath: "UserImage").value as? String
                
                if self.profileImageString != "" || self.profileImageString != nil{
                   
                    if self.profileImageString == "default"{
                        //Set Default Picture
                        self.profileImageView.image = UIImage(named: "userprofile_default")
                    }else{
                        //Set Obtained Profile Picture By Link
                        self.profileImageView.sd_setImage(with: URL(string: self.profileImageString!) , completed: nil)
                        
                        //Found Cover Image
                        if snapshot.hasChild("CoverImage"){
                            self.coverImageString = snapshot.childSnapshot(forPath: "CoverImage").value as? String
                            
                            if self.coverImageString != "" || self.coverImageString != nil{
                                //Set Obtained Cover Image By Link
                                self.coverPhotoImageView.sd_setImage(with: URL(string: self.coverImageString!), completed: nil)
                            }
                        }
                    }
                }
            }
            // Profile Picture Not Found
            else{
                self.refUserAccount.child(self.userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() && snapshot.hasChild("image"){
                        print("[Get Profile Picture]    : Profile Picture Found In User Account.\n")
                        self.profileImageString = snapshot.childSnapshot(forPath: "image").value as? String
                        
                        if self.profileImageString != "" || self.profileImageString != nil{
                            
                            if self.profileImageString == "default"{
                                //Set Default Picture
                                print("[Set Default Profile Picture.]\n")
                                self.profileImageView.image = UIImage(named: "userprofile_default")
                            }else{
                                //Set Obtained Profile Picture By Link
                                print("[Set Profile Picture by Link]\n")
                                self.profileImageView.sd_setImage(with: URL(string: self.profileImageString!) , completed: nil)
                                //Found Cover Image
                                if snapshot.hasChild("CoverImage"){
                                    print("[Get Cover Image]    : Cover Image Found.")
                                    self.coverImageString = snapshot.childSnapshot(forPath: "CoverImage").value as? String
                                    
                                    if self.coverImageString != "" || self.coverImageString != nil{
                                        //Set Obtained Cover Image By Link
                                        self.coverPhotoImageView.sd_setImage(with: URL(string: self.coverImageString!), completed: nil)
                                    }
                                }
                            
                            }
                        }
                    }
                })
            }
        }
        getProfileUpperPartData()
    }
    
    
    func getProfileUpperPartData(){
        //Get Review Notification
        refUserReview.child(userUID!).observe(.value) { (snapshot) in
            if snapshot.exists(){
                if snapshot.value != nil{
                    let notification = snapshot.value as? String
                    if notification == "true"{
                        print("[Get Review Notification]    : Have Notification.")
                        //Set Red Dot to Review Tab
                    }else{
                        print("[Get Review Notification]    : No Notification.")
                    }
                }
            }
        }
        
        //Get Review Count & Ratings
        refUserReview.child(userUID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                //Get Ratings
                if snapshot.hasChild("Rate5"){
                    self.fiveStarRate = snapshot.childSnapshot(forPath: "Rate5").value as! Int
                }
                if (snapshot.hasChild("Rate4")){
                    self.fourStarRate = snapshot.childSnapshot(forPath: "Rate4").value as! Int
                }
                if (snapshot.hasChild("Rate3")){
                    self.threeStarRate = snapshot.childSnapshot(forPath: "Rate3").value as! Int
                }
                if (snapshot.hasChild("Rate2")){
                    self.twoStarRate = snapshot.childSnapshot(forPath: "Rate2").value as! Int
                }
                if (snapshot.hasChild("Rate1")){
                    self.oneStarRate = snapshot.childSnapshot(forPath: "Rate1").value as! Int
                }
                //Count Total Reviews
                self.totalReviewCount = self.fiveStarRate + self.fourStarRate + self.threeStarRate + self.twoStarRate + self.oneStarRate
            }
            self.reviewNumberLabel.text = "\(self.totalReviewCount) Reviews"
            
            //Count Star Rating
            if self.totalReviewCount != 0{
                let sumRate = (5*self.fiveStarRate) + (4*self.fourStarRate) + (3*self.threeStarRate) + (2*self.twoStarRate) + (1*self.oneStarRate)
                self.starRating = Double(sumRate/self.totalReviewCount)
                print("[Obtained Star Ratings]  : \(self.starRating)")
                
                self.ratingBar.rating = self.starRating
            }else{
                self.ratingBar.rating = 0
            }
        }
        getAccountType()
    }
    
    func getAccountType(){
        refUserAccount.child(userUID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                if snapshot.hasChild("provider"){
                    switch snapshot.childSnapshot(forPath: "provider").value as! String{
                    case "facebook" :
                        self.verifiedEmailIcon.isHidden  = false
                        self.verifiedEmailLabel.isHidden = false
                        break
                    case "Google":
                        self.verifiedEmailIcon.isHidden  = false
                        self.verifiedEmailLabel.isHidden = false
                        break
                    
                    default:
                        self.verifiedEmailIcon.isHidden  = false
                        self.verifiedEmailLabel.isHidden = false
                        break
                    }
                }
            }
        }
    }
    
    func getWorkExperience(){
        refUserInfo.child(userUID!).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.hasChild("WorkExp1") &&
                snapshot.childSnapshot(forPath: "WorkExp1").hasChild("worktitle") &&
                snapshot.childSnapshot(forPath: "WorkExp1").hasChild("workcompany")) {
                
        }
    }
    }
    
    
    
    
    
    
    //MARK: - Location Map
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        if (place.formattedAddress != nil){
            self.geCityFromGeoCoordinate(placename: place.name ,fulladdress: place.formattedAddress!, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        else{
            self.geCityFromGeoCoordinate(placename: place.name, fulladdress: "", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
        print("error")
    }
    
    func geCityFromGeoCoordinate(placename: String, fulladdress: String, latitude: Double, longitude: Double){
        
        finalLatitude = latitude
        finalLongitude = longitude
        
        var center:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        
        center.latitude = latitude
        center.longitude = longitude
        
        let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
            if (error != nil){
                print("reverse geo error")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                self.city = pm.administrativeArea!
                
                if (fulladdress.contains("Pulau Pinang") || fulladdress.contains("Penang")){
                    self.city = "Penang"
                }
                else if (fulladdress.contains("Kuala Lumpur")){
                    self.city = "Kuala Lumpur"
                }
                else if (fulladdress.contains("Labuan")){
                    self.city = "Labuan"
                }
                else if (fulladdress.contains("Putrajaya")){
                    self.city = "Putrajaya"
                }
                else if (fulladdress.contains("Johor")){
                    self.city = "Johor"
                }
                else if (fulladdress.contains("Kelantan")){
                    self.city = "Kelantan"
                }
                else if (fulladdress.contains("Melaka") || fulladdress.contains("Melacca")){
                    self.city = "Melacca"
                }
                else if (fulladdress.contains("Negeri Sembilan") || fulladdress.contains("Seremban")){
                    self.city = "Negeri Sembilan"
                }
                else if (fulladdress.contains("Pahang")){
                    self.city = "Pahang"
                }
                else if (fulladdress.contains("Perak") || fulladdress.contains("Ipoh")){
                    self.city = "Perak"
                }
                else if (fulladdress.contains("Perlis")){
                    self.city = "Perlis"
                }
                else if (fulladdress.contains("Sabah")){
                    self.city = "Sabah"
                }
                else if (fulladdress.contains("Sarawak")){
                    self.city = "Sarawak"
                }
                else if (fulladdress.contains("Selangor") || fulladdress.contains("Shah Alam") || fulladdress.contains("Klang")){
                    self.city = "Selangor"
                }
                else if (fulladdress.contains("Terengganu")){
                    self.city = "Terengganu"
                }
                else if (fulladdress.contains("Limerick")){
                    self.city = "County Limerick"
                }
                
                if (fulladdress == "" && (pm.locality != nil || pm.administrativeArea != nil)){
                    if (pm.locality == nil){
                        self.locationLabel.text = placename + ", " + pm.administrativeArea!
                    }
                    else{
                        self.locationLabel.text = placename + pm.locality! + ", " + pm.administrativeArea!
                    }
                    
                }
                else if (fulladdress != "") {
                    self.locationLabel.text = placename + ", " + fulladdress
                }
                else{
                    self.locationLabel.text = "Address not found"
                }
                
            }
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
