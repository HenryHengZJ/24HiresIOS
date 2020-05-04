//
//  EditProfileViewController.swift
//  JobIn24
//
//  Created by MacUser on 11/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage
import RSKImageCropper
import Toast_Swift
import GoogleMaps
import GooglePlacePicker

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate,GMSPlacePickerViewControllerDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var coverImageEditView: UIView!
    
    @IBOutlet weak var coverImageEditBtn: UIButton!
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileImageEditView: UIView!
    
    @IBOutlet weak var profileImageEditBtn: UIButton!
    
    @IBOutlet weak var profileImageBlackView: UIView!
    
    
    @IBOutlet weak var nametxtView: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var abouttxtView: UITextView!
    
    @IBOutlet weak var birthdatetxtField: UITextField!
    
    @IBOutlet weak var weighttxtView: UITextView!
    
    @IBOutlet weak var heighttxtView: UITextView!
    
    @IBOutlet weak var emailtxtView: UITextView!
    
    @IBOutlet weak var phonetxtView: UITextView!
    
    @IBOutlet weak var gendertxtField: UITextField!
    
    @IBOutlet weak var workCompany1: UILabel!
    @IBOutlet weak var workPosition1: UILabel!
    @IBOutlet weak var workLength1: UILabel!
    @IBOutlet weak var workView1: UIView!
    
    @IBOutlet weak var workCompany2: UILabel!
    @IBOutlet weak var workPosition2: UILabel!
    @IBOutlet weak var workLength2: UILabel!
    @IBOutlet weak var workView2: UIView!
    
    @IBOutlet weak var workCompany3: UILabel!
    @IBOutlet weak var workPosition3: UILabel!
    @IBOutlet weak var workLength3: UILabel!
    @IBOutlet weak var workView3: UIView!
    
    @IBOutlet weak var workCompany4: UILabel!
    @IBOutlet weak var workPosition4: UILabel!
    @IBOutlet weak var workLength4: UILabel!
    @IBOutlet weak var workView4: UIView!
    
    @IBOutlet weak var workCompany5: UILabel!
    @IBOutlet weak var workPosition5: UILabel!
    @IBOutlet weak var workLength5: UILabel!
    @IBOutlet weak var workView5: UIView!
    
    @IBOutlet weak var addnewExpBtn: UIButton!
    
    @IBOutlet weak var educationtxtView: UITextView!
    
    @IBOutlet weak var languagetxtView: UITextView!
    
    var userImage: String?
    var usercoverImage: String?
    var userstaticcoverImage: String?
    var userprofImage: String?
    var imgBtnClicked: String?
    var finallatitude: Double!
    var finallongitude: Double!
    var mProfImageUrl: URL!
    var mCoverImageUrl: URL!
    var city: String!

    
    var picker = UIImagePickerController()
    
    var blurEffectView: UIVisualEffectView!
    
    let gender_picker_values = ["","Male", "Female"]
    var genderPicker: UIPickerView! = UIPickerView()
    var selectedGender = ""
    
    var datePicker = UIDatePicker()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return gender_picker_values.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return gender_picker_values[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedGender = gender_picker_values[row]
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.resignFirstResponder()
        return false
    }
    
    @objc func updateLocation(_ notification: NSNotification) {
        
        if let locationval = notification.userInfo?["location"] as? String {
            if (locationval != "") {
                locationLabel.text = locationval
            }
        }
    }
    
    @objc func updateWorkExp1(_ notification: NSNotification) {
        
        if  let removalval = notification.userInfo?["removal"] as? String,
            let worktitleval = notification.userInfo?["worktitle"] as? String,
            let workcompanyval = notification.userInfo?["workcompany"] as? String,
            let worktimeval = notification.userInfo?["worktime"] as? String
            
        {
            if (removalval == "true") {
                workCompany1.text = ""
                workPosition1.text = ""
                workLength1.text = ""
            }
            else {
                workCompany1.text = workcompanyval
                workPosition1.text = worktitleval
                workLength1.text = worktimeval
            }
        }
    }
    
    @objc func updateWorkExp2(_ notification: NSNotification) {
        
        if  let removalval = notification.userInfo?["removal"] as? String,
            let worktitleval = notification.userInfo?["worktitle"] as? String,
            let workcompanyval = notification.userInfo?["workcompany"] as? String,
            let worktimeval = notification.userInfo?["worktime"] as? String
            
        {
            if (removalval == "true") {
                workView2.isHidden = true
                workCompany2.text = ""
                workPosition2.text = ""
                workLength2.text = ""
            }
            else {
                workView2.isHidden = false
                workCompany2.text = workcompanyval
                workPosition2.text = worktitleval
                workLength2.text = worktimeval
            }
        }
    }
    
    @objc func updateWorkExp3(_ notification: NSNotification) {
        
        if  let removalval = notification.userInfo?["removal"] as? String,
            let worktitleval = notification.userInfo?["worktitle"] as? String,
            let workcompanyval = notification.userInfo?["workcompany"] as? String,
            let worktimeval = notification.userInfo?["worktime"] as? String
            
        {
            if (removalval == "true") {
                workView3.isHidden = true
                workCompany3.text = ""
                workPosition3.text = ""
                workLength3.text = ""
            }
            else {
                workView3.isHidden = false
                workCompany3.text = workcompanyval
                workPosition3.text = worktitleval
                workLength3.text = worktimeval
            }
        }
    }
    
    @objc func updateWorkExp4(_ notification: NSNotification) {
        
        if  let removalval = notification.userInfo?["removal"] as? String,
            let worktitleval = notification.userInfo?["worktitle"] as? String,
            let workcompanyval = notification.userInfo?["workcompany"] as? String,
            let worktimeval = notification.userInfo?["worktime"] as? String
            
        {
            if (removalval == "true") {
                workView4.isHidden = true
                workCompany4.text = ""
                workPosition4.text = ""
                workLength4.text = ""
            }
            else {
                workView4.isHidden = false
                workCompany4.text = workcompanyval
                workPosition4.text = worktitleval
                workLength4.text = worktimeval
            }
        }
    }
    
    @objc func updateWorkExp5(_ notification: NSNotification) {
        
        if  let removalval = notification.userInfo?["removal"] as? String,
            let worktitleval = notification.userInfo?["worktitle"] as? String,
            let workcompanyval = notification.userInfo?["workcompany"] as? String,
            let worktimeval = notification.userInfo?["worktime"] as? String
            
        {
            if (removalval == "true") {
                workView5.isHidden = true
                workCompany5.text = ""
                workPosition5.text = ""
                workLength5.text = ""
            }
            else {
                workView5.isHidden = false
                workCompany5.text = workcompanyval
                workPosition5.text = worktitleval
                workLength5.text = worktimeval
            }
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        
        picker.delegate = self
        
        self.workView2.isHidden = true
        self.workView3.isHidden = true
        self.workView4.isHidden = true
        self.workView5.isHidden = true
        
        self.profileImage.layer.cornerRadius = profileImage.bounds.size.width/2
        self.profileImage.clipsToBounds = true
        
        self.profileImageEditView.layer.cornerRadius = profileImageEditView.bounds.size.width/2
        self.profileImageEditView.layer.masksToBounds = true
        self.profileImageEditView.clipsToBounds = true
        self.profileImageEditView.backgroundColor = UIColor.clear
        self.profileImageEditView.layer.borderWidth = 2.0
        self.profileImageEditView.layer.borderColor = UIColor.white.cgColor
        
        self.coverImageEditView.layer.cornerRadius = coverImageEditView.bounds.size.width/2
        self.coverImageEditView.layer.masksToBounds = true
        self.coverImageEditView.clipsToBounds = true
        self.coverImageEditView.backgroundColor = UIColor.clear
        self.coverImageEditView.layer.borderWidth = 2.0
        self.coverImageEditView.layer.borderColor = UIColor.white.cgColor
        
        self.profileImageBlackView.layer.cornerRadius = profileImageBlackView.bounds.size.width/2
        self.profileImageBlackView.layer.masksToBounds = true
        self.profileImageBlackView.clipsToBounds = true
        
        self.gendertxtField.inputAccessoryView = UIView()
        self.birthdatetxtField.inputAccessoryView = UIView()
        
        self.genderPicker = UIPickerView(frame: CGRect(x:0, y:40, width:0, height:0))
        self.datePicker = UIDatePicker(frame: CGRect(x:0, y:40, width:0, height:0))
        
        self.gendertxtField.delegate = self
        self.birthdatetxtField.delegate = self
        
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateLocation(_:)), name: Notification.Name("updateProfileLocation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateWorkExp1(_:)), name: Notification.Name("updateWorkExp1"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateWorkExp2(_:)), name: Notification.Name("updateWorkExp2"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateWorkExp3(_:)), name: Notification.Name("updateWorkExp3"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateWorkExp4(_:)), name: Notification.Name("updateWorkExp4"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.updateWorkExp5(_:)), name: Notification.Name("updateWorkExp5"), object: nil)
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserAccount").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                if let getData = snapshot.value as? [String:Any]{
                    
                    let userName = getData["name"] as? String
                    
                    self.userImage = getData["image"] as? String
                    
                    print("self.userImage = \(self.userImage)")
                    
                    self.profileImage.downloadprofileImage(from: self.userImage!)
                    self.usercoverImage = self.userImage
                    self.userstaticcoverImage = self.userImage
                    self.userprofImage = self.userImage
                    
                    if (userName != nil) {
                        self.nametxtView.text = userName
                    }
                    else {
                        self.nametxtView.text = ""
                    }
                    
                    ref.child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if(!snapshot.hasChild(uid!)){
                            self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                            self.blurEffectView.tag = 100
                            self.blurEffectView.frame = self.coverImage.bounds
                            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.coverImage.addSubview(self.blurEffectView)
                            return
                        }
                        
                        if let getData = snapshot.childSnapshot(forPath: uid!).value as? [String:Any]{
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("CoverImage"){
                                self.usercoverImage = getData["CoverImage"] as? String
                                self.userstaticcoverImage = getData["CoverImage"] as? String
                                self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                                
                                let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width: self.coverImage.frame.size.width, height: self.coverImage.frame.size.height))
                                overlay.backgroundColor = UIColor(red:0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                                self.coverImage.addSubview(overlay)
                                
                            }
                            else{
                                self.coverImage.downloadprofileImage(from: self.usercoverImage!)
                                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                                self.blurEffectView.tag = 100
                                self.blurEffectView.frame = self.coverImage.bounds
                                self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                self.coverImage.addSubview(self.blurEffectView)
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("About") {
                                let abouttxt = getData["About"] as? String
                                self.abouttxtView.text = abouttxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Age") {
                                let agetxt = getData["Age"] as? String
                                self.birthdatetxtField.text = agetxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Weight") {
                                let weighttxt = getData["Weight"] as? String
                                self.weighttxtView.text = weighttxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Height") {
                                let heighttxt = getData["Height"] as? String
                                self.heighttxtView.text = heighttxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Gender") {
                                let gendertxt = getData["Gender"] as? String
                                self.gendertxtField.text = gendertxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Phone") {
                                let phonetxt = getData["Phone"] as? String
                                self.phonetxtView.text = phonetxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Email") {
                                let emailtxt = getData["Email"] as? String
                                self.emailtxtView.text = emailtxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Education") {
                                let educationtxt = getData["Education"] as? String
                                self.educationtxtView.text = educationtxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("Language") {
                                let languagetxt = getData["Language"] as? String
                                self.languagetxtView.text = languagetxt
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp1") {
                                
                                if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp1").value as? [String:Any]
                                {
                                    if let workTitle = getWorkData["worktitle"] as? String
                                    {
                                        self.workPosition1.text = workTitle
                                        
                                    }
                                    if let workCompany = getWorkData["workcompany"] as? String
                                    {
                                        self.workCompany1.text = workCompany
                                        
                                    }
                                    if let workTime = getWorkData["worktime"] as? String
                                    {
                                        self.workLength1.text = workTime
                                        
                                    }
                                }
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp2") {
                                
                                self.workView2.isHidden = false
                                
                                if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp2").value as? [String:Any]
                                {
                                    if let workTitle = getWorkData["worktitle"] as? String
                                    {
                                        self.workPosition2.text = workTitle
                                        
                                    }
                                    if let workCompany = getWorkData["workcompany"] as? String
                                    {
                                        self.workCompany2.text = workCompany
                                        
                                    }
                                    if let workTime = getWorkData["worktime"] as? String
                                    {
                                        self.workLength2.text = workTime
                                        
                                    }
                                }
                            }
                            else{
                                self.workView2.isHidden = true
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp3") {
                                
                                self.workView3.isHidden = false
                                
                                if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp3").value as? [String:Any]
                                {
                                    if let workTitle = getWorkData["worktitle"] as? String
                                    {
                                        self.workPosition3.text = workTitle
                                        
                                    }
                                    if let workCompany = getWorkData["workcompany"] as? String
                                    {
                                        self.workCompany3.text = workCompany
                                        
                                    }
                                    if let workTime = getWorkData["worktime"] as? String
                                    {
                                        self.workLength3.text = workTime
                                        
                                    }
                                }
                            }
                            else{
                                self.workView3.isHidden = true
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp4") {
                                
                                self.workView4.isHidden = false
                                
                                if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp4").value as? [String:Any]
                                {
                                    if let workTitle = getWorkData["worktitle"] as? String
                                    {
                                        self.workPosition4.text = workTitle
                                        
                                    }
                                    if let workCompany = getWorkData["workcompany"] as? String
                                    {
                                        self.workCompany4.text = workCompany
                                        
                                    }
                                    if let workTime = getWorkData["worktime"] as? String
                                    {
                                        self.workLength4.text = workTime
                                        
                                    }
                                }
                            }
                            else{
                                self.workView4.isHidden = true
                            }
                            
                            if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp5") {
                                
                                self.workView5.isHidden = false
                                self.addnewExpBtn.isHidden = true
                                
                                if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp5").value as? [String:Any]
                                {
                                    if let workTitle = getWorkData["worktitle"] as? String
                                    {
                                        self.workPosition5.text = workTitle
                                        
                                    }
                                    if let workCompany = getWorkData["workcompany"] as? String
                                    {
                                        self.workCompany5.text = workCompany
                                        
                                    }
                                    if let workTime = getWorkData["worktime"] as? String
                                    {
                                        self.workLength5.text = workTime
                                        
                                    }
                                }
                            }
                            else{
                                self.workView5.isHidden = true
                            }
                        }
                    })
                }
                
            })
            
            ref.child("UserLocation").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if !snapshot.exists() {
                    self.locationLabel.text = "Somewhere on earth"
                    return
                    
                }
                
                if let getData = snapshot.value as? [String:Any]{
                    
                    let userCity = getData["CurrentCity"] as? String
                    
                    if (userCity != nil) {
                        self.locationLabel.text = userCity
                    }
                    else {
                        self.locationLabel.text = "Somewhere on earth"
                    }
                }
            })
            
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        if (imgBtnClicked == "ProfileClicked") {
            mProfImageUrl = documentsPath?.appendingPathComponent("profileimage.jpg")
            
            let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
            
            let controller: RSKImageCropViewController = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
//            let tabBar = self.tabBarController as! MainTabBarController
//            tabBar.hideCenterButton()
            self.navigationController?.pushViewController(controller, animated: true)
        }
            
        else if (imgBtnClicked == "CoverClicked") {
            mCoverImageUrl = documentsPath?.appendingPathComponent("coverimage.jpg")
            
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
                try! UIImageJPEGRepresentation(pickedImage, 0.1)?.write(to: mCoverImageUrl)
                self.coverImage.image = pickedImage
                if let viewWithTag = self.coverImage.viewWithTag(100) {
                    viewWithTag.removeFromSuperview()
                    let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width: self.coverImage.frame.size.width, height: self.coverImage.frame.size.height))
                    overlay.backgroundColor = UIColor(red:0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                    self.coverImage.addSubview(overlay)
                }
                usercoverImage = ""
            }
            
        }
        
        picker.dismiss(animated: true) {
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
//        let tabBar = self.tabBarController as! MainTabBarController
//        tabBar.showCenterButton()
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        profileImage.image = croppedImage
        
        if let pickedImage = croppedImage as? UIImage{
            try! UIImageJPEGRepresentation(pickedImage, 0.1)?.write(to: mProfImageUrl)
      
        }
        
        if (usercoverImage == userprofImage) {
            self.coverImage.image = croppedImage
        }
//        let tabBar = self.tabBarController as! MainTabBarController
//        tabBar.showCenterButton()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if (segue.identifier == "newworksegue") {
            
            let destinationVC = segue.destination as! EditWorkExpViewController
            
            destinationVC.workcompanytext1 = workCompany1.text
            destinationVC.workpositiontext1 = workPosition1.text
            destinationVC.worklengthtext1 = workLength1.text
            
            destinationVC.workcompanytext2 = workCompany2.text
            destinationVC.workpositiontext2 = workPosition2.text
            destinationVC.worklengthtext2 = workLength2.text
            
            destinationVC.workcompanytext3 = workCompany3.text
            destinationVC.workpositiontext3 = workPosition3.text
            destinationVC.worklengthtext3 = workLength3.text
            
            destinationVC.workcompanytext4 = workCompany4.text
            destinationVC.workpositiontext4 = workPosition4.text
            destinationVC.worklengthtext4 = workLength4.text
            
            destinationVC.workcompanytext5 = workCompany5.text
            destinationVC.workpositiontext5 = workPosition5.text
            destinationVC.worklengthtext5 = workLength5.text
            
        }
    }
    
    @IBAction func chgprofpicPressed(_ sender: UIButton) {
        
        imgBtnClicked = "ProfileClicked"
        
        picker.allowsEditing = false
        
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func chgcoverpicPressed(_ sender: UIButton) {
        
        imgBtnClicked = "CoverClicked"
        
        picker.allowsEditing = true
        
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        
        if nametxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            // string contains non-whitespace characters
            
            // create the alert
            let alert = UIAlertController(title: "Invalid Name", message: "Name must not be left empty", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: { action in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        AppDelegate.instance().showActivityIndicator()
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            let newUserAccount = ref.child("UserAccount").child(uid!)
            let newUserInfo = ref.child("UserInfo").child(uid!)
            let newUserLocation = ref.child("UserLocation").child(uid!)
            
            let storage = Storage.storage().reference()
            
            // GOT Profile Picture and Cover Picture
            if (mProfImageUrl != nil && mCoverImageUrl != nil) {
                
                let profileimageRef = storage.child("ProfilePhotos").child("\(uid!)\(mProfImageUrl.lastPathComponent)")
                let coverimageRef = storage.child("CoverPhotos").child("\(uid!)\(mCoverImageUrl.lastPathComponent)")
                
                let oldprofilestorage = Storage.storage().reference(forURL: self.userprofImage!)
                let oldcoverstorage = Storage.storage().reference(forURL: self.userstaticcoverImage!)
                
                oldcoverstorage.delete(completion: { (error) in
                    if error != nil{
                        print("old cover photo not found")
                        return
                    }
                    
                    print("deleted old cover photo")
                })
                
                oldprofilestorage.delete(completion: { (error) in
                    if error != nil{
                        print("old profile photo not found")
                        return
                    }
                    
                    print("deleted old profile photo")
                })
                
                let profileuploadTask = profileimageRef.putFile(from: mProfImageUrl, metadata: nil) { (metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("Photo Upload failed", duration: 2.0, position: .center)
                        return
                    }
                    
                    profileimageRef.downloadURL(completion: { (url, error) in
                        if let profileurl = url{
                            
                            let profilestringurl = profileurl.absoluteString
                            
                            let coveruploadTask = coverimageRef.putFile(from: self.mCoverImageUrl, metadata: nil) { (metadata, error) in
                                if error != nil{
                                    print(error!.localizedDescription)
                                    AppDelegate.instance().dismissActivityIndicator()
                                    self.view.makeToast("Photo Upload failed", duration: 2.0, position: .center)
                                    return
                                }
                                
                                coverimageRef.downloadURL(completion: { (url, error) in
                                    if let coverurl = url{
                                        
                                        let coverstringurl = coverurl.absoluteString
                                        
                                        self.startUpdating(uid: uid!, profilestringurl: profilestringurl, coverstringurl: coverstringurl, newUserAccount: newUserAccount, newUserInfo: newUserInfo, newUserLocation: newUserLocation)
                                    }
                                })
                            }
                            
                            coveruploadTask.resume()
                        }
                    })
                }
                
                profileuploadTask.resume()
            }
                
                // NO Profile Picture and GOT Cover Picture
            else if (mProfImageUrl == nil && mCoverImageUrl != nil) {
                
                let coverimageRef = storage.child("CoverPhotos").child("\(uid!)\(mCoverImageUrl.lastPathComponent)")
                
                let oldcoverstorage = Storage.storage().reference(forURL: self.userstaticcoverImage!)
                
                oldcoverstorage.delete(completion: { (error) in
                    if error != nil{
                        print("old cover photo not found")
                        return
                    }
                    
                    print("deleted old profile photo")
                })
                
                let coveruploadTask = coverimageRef.putFile(from: self.mCoverImageUrl, metadata: nil) { (metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("Photo Upload failed", duration: 2.0, position: .center)
                        return
                    }
                    
                    coverimageRef.downloadURL(completion: { (url, error) in
                        if let coverurl = url{
                            
                            let coverstringurl = coverurl.absoluteString
                            
                            self.startUpdating(uid: uid!, profilestringurl: self.userprofImage!, coverstringurl: coverstringurl, newUserAccount: newUserAccount, newUserInfo: newUserInfo, newUserLocation: newUserLocation)
                            
                            
                        }
                    })
                }
                
                coveruploadTask.resume()
            }
                
                // GOT Profile Picture and NO Cover Picture
            else if (mProfImageUrl != nil && mCoverImageUrl == nil) {
                let profileimageRef = storage.child("ProfilePhotos").child("\(uid!)\(mProfImageUrl)")
               
                let oldprofilestorage :StorageReference = Storage.storage().reference(forURL: self.userprofImage!)

                oldprofilestorage.delete(completion: { (error) in
                        if error != nil{
                            print("old profile photo not found")
                            return
                        }
                        
                        print("deleted old profile photo")
                    })
                    
                
                
             
                let profileuploadTask = profileimageRef.putFile(from: mProfImageUrl, metadata: nil) { (metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("Photo Upload failed", duration: 2.0, position: .center)
                        return
                    }
                    
                    profileimageRef.downloadURL(completion: { (url, error) in
                        if let profileurl = url{
                            
                            let profilestringurl = profileurl.absoluteString
                            
                            self.startUpdating(uid:uid!, profilestringurl: profilestringurl, coverstringurl: self.usercoverImage!, newUserAccount: newUserAccount, newUserInfo: newUserInfo, newUserLocation: newUserLocation)
                            
                        }
                    })
                }
                
                profileuploadTask.resume()
            }
                
                //NO Profile Picture and NO Cover Picture
            else {
                self.startUpdating(uid:uid!, profilestringurl:self.userprofImage!, coverstringurl:self.usercoverImage!, newUserAccount:newUserAccount, newUserInfo:newUserInfo, newUserLocation: newUserLocation)
            }
            
            
        }
        else {
            AppDelegate.instance().dismissActivityIndicator()
            self.view.makeToast("User not found, please re-login to try again", duration: 2.0, position: .center)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func birthdatePressed(_ sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        datePicker.tintColor = tintColor
        datePicker.datePickerMode = .date
        datePicker.center.x = inputView.center.x
        inputView.addSubview(datePicker) // add picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(doneDateButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(cancelDatePicker(_:)) , for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @objc func cancelDatePicker(_ sender: UIButton) {
        //Remove view when select cancel
        
        self.birthdatetxtField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    @objc func doneDateButton(_ sender: UIButton) {
        //Remove view when select cancel
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        self.birthdatetxtField.text = formatter.string(from: datePicker.date)
        
        self.birthdatetxtField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    @IBAction func genderPressed(_ sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        genderPicker.tintColor = tintColor
        genderPicker.center.x = inputView.center.x
        inputView.addSubview(genderPicker) // add picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(doneGenderButton(_:) ) , for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(cancelGenderPicker(_:) ), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    
   @objc func cancelGenderPicker(_ sender: UIButton) {
        //Remove view when select cancel
        
        self.gendertxtField.resignFirstResponder()
        
    }
    
   @objc func doneGenderButton(_ sender: UIButton) {
        //Remove view when select cancel
        
        self.gendertxtField.text = self.selectedGender
        self.gendertxtField.resignFirstResponder()
        
    }
    
    @IBAction func locationPressed(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
        
    }
    
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
        
        finallatitude = latitude
        finallongitude = longitude
        
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
                self.city = pm.administrativeArea
                
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
    
    
    
    
    
    
    
    func startUpdating(uid:String, profilestringurl:String, coverstringurl:String, newUserAccount:DatabaseReference, newUserInfo:DatabaseReference, newUserLocation: DatabaseReference) {
        
        var newUserInfoDetails = [:] as [String : Any]
        
        var newUserAccountDetails = ["image": profilestringurl] as [String : Any]
        
        var newUserLocationDetails = [:] as [String : Any]
        
        var newUserChangedInfo = [:] as [String : Any]
        
        let username = nametxtView.text
        if !nametxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserAccountDetails["name"] = username
            newUserChangedInfo["name"] = username
        }
        
        let userlocation = locationLabel.text
        if !locationLabel.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserLocationDetails["CurrentCity"] = userlocation
            newUserChangedInfo["CurrentCity"] = userlocation
        }
        
        let userabout = abouttxtView.text
        if !abouttxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["About"] = userabout
        }
        else {
            newUserInfo.child("About").removeValue()
        }
        
        let userage = birthdatetxtField.text
        if !birthdatetxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Age"] = userage
        }
        else {
            newUserInfo.child("Age").removeValue()
        }
        
        let usergender = gendertxtField.text
        if !gendertxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Gender"] = usergender
        }
        else {
            newUserInfo.child("Gender").removeValue()
        }
        
        let userweight = weighttxtView.text
        if !weighttxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Weight"] = userweight
        }
        else {
            newUserInfo.child("Weight").removeValue()
        }
        
        let userheight = heighttxtView.text
        if !heighttxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Height"] = userheight
        }
        else {
            newUserInfo.child("Height").removeValue()
        }
        
        let useremail = emailtxtView.text
        if !emailtxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Email"] = useremail
        }
        else {
            newUserInfo.child("Email").removeValue()
        }
        
        let userphone = phonetxtView.text
        if !phonetxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Phone"] = userphone
        }
        else {
            newUserInfo.child("Phone").removeValue()
        }
        
        let usereducation = educationtxtView.text
        if !educationtxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Education"] = usereducation
        }
        else {
            newUserInfo.child("Education").removeValue()
        }
        
        let userlanguage = languagetxtView.text
        if !languagetxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            newUserInfoDetails["Language"] = userlanguage
        }
        else {
            newUserInfo.child("Language").removeValue()
        }
        
        if (coverstringurl != profilestringurl) {
            newUserInfoDetails["CoverImage"] = coverstringurl
            newUserChangedInfo["CoverImage"] = coverstringurl
        }
        
        if (profilestringurl != self.userImage) {
            newUserChangedInfo["ProfileImage"] = profilestringurl
        }
        
        
        if (!newUserAccountDetails.isEmpty) {
            newUserAccount.updateChildValues(newUserAccountDetails)
        }
        
        if (!newUserLocationDetails.isEmpty) {
            newUserLocation.updateChildValues(newUserLocationDetails)
        }
        
        if (!newUserInfoDetails.isEmpty) {
            newUserInfo.updateChildValues(newUserInfoDetails,  withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
                
                if (error != nil) {
                    AppDelegate.instance().dismissActivityIndicator()
                    self.view.makeToast("Update Failed", duration: 2.0, position: .center)
                }
                else {
                    
  
                    AppDelegate.instance().dismissActivityIndicator()

                    self.navigationController?.popViewController(animated: true)
                    
//                    NotificationCenter.default.post(name: Notification.Name("updateInfo"), object: nil, userInfo: newUserChangedInfo)
                }
            })
        }
        else {
            print("userinfo empty")
            AppDelegate.instance().dismissActivityIndicator()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
