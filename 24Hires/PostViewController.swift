//
//  PostViewController.swift
//  JobIn24
//
//  Created by MacUser on 03/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Koyomi
import GooglePlacePicker
import GoogleMaps
import Toast_Swift
import GeoFire

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GMSPlacePickerViewControllerDelegate, CLLocationManagerDelegate, VerificationAlertDelegate,VerificationAlert2Delegate {
    
    @IBOutlet weak var deleteDateBtn: UIButton!
    
    @IBOutlet weak var ratetxtfield: UITextField!
    @IBOutlet weak var rateBtn: UIButton!
    
    @IBOutlet weak var currencyBtn: UIButton!
    
    @IBOutlet weak var currencytxtfield: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var uploadphotoBtn: UIButton!
    @IBOutlet weak var uploadView: UIView!
    
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var titletxtview: UITextView!
    
    @IBOutlet weak var descriptxtview: UITextView!
    
    @IBOutlet weak var companytxtview: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var amountwagestxtview: UITextView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var ImageEditView: UIView!
    
    var selectedCurrency = "MYR"
    var selectedRate = "per hour"
    var city: String!
    var myownname: String!
    var myownimage: String!
    var mjobbg1: String!
    var mjobbg2: String!
    var mjobbg3: String!
    
    var categorynum: Int64!
    var startingdate = ""
    var finallatitude: Double!
    var finallongitude: Double!
    var mImageUrl: URL!
    
    let picker_values = ["MYR", "SGD", "CHY", "USD","GBP", "EUR", "NTD", "HKD","INR", "IDR"]
    let rate_values = ["per hour", "per day", "per month"]
    var myPicker: UIPickerView! = UIPickerView()
    var myPicker2: UIPickerView! = UIPickerView()
    var PickerCurrencySelectedRow :Int64 = 0
    var PickerRateSelectedRow = 0
    
    var picker = UIImagePickerController()
    
    var titleplaceholderLabel : UILabel!
    var descripplaceholderLabel : UILabel!
    var categoryplaceholderLabel : UILabel!
    var companyplaceholderLabel : UILabel!
    var locationplaceholderLabel : UILabel!
    var amountwagesplaceholderLabel : UILabel!
    var dateplaceholderLabel : UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Post Anonymouse User")
                showUserAnonymousDialog()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteDateBtn.imageEdgeInsets = UIEdgeInsets(top:10,left:10, bottom:10, right:10)
        
        self.currencytxtfield.inputAccessoryView = UIView()
        self.ratetxtfield.inputAccessoryView = UIView()
        
        self.hideKeyboardWhenTappedAround()
        
        picker.delegate = self
        
        self.myPicker = UIPickerView(frame: CGRect(x:0, y:40, width:0, height:0))
        
        self.ratetxtfield.delegate = self
        self.currencytxtfield.delegate = self
        
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        self.myPicker.tag = 1
        
        self.myPicker2.delegate = self
        self.myPicker2.dataSource = self
        self.myPicker2.tag = 2
        
        titletxtview.delegate = self
        titletxtview.tag = 0
        
        descriptxtview.delegate = self
        descriptxtview.tag = 1
        
        categoryLabel.sizeToFit()
        categoryLabel.tag = 2
        
        companytxtview.delegate = self
        companytxtview.tag = 3
        
        locationLabel.sizeToFit()
        locationLabel.tag = 4
        
        amountwagestxtview.delegate = self
        amountwagestxtview.tag = 5
        
        dateLabel.sizeToFit()
        dateLabel.tag = 6
        
        titleplaceholderLabel = UILabel()
        setTextViewPlaceHolderLabel(phlabel: titleplaceholderLabel,txtview: titletxtview)
        
        descripplaceholderLabel = UILabel()
        setTextViewPlaceHolderLabel(phlabel: descripplaceholderLabel,txtview: descriptxtview)
        
        categoryplaceholderLabel = UILabel()
        setLabelPlaceHolderLabel(phlabel: categoryplaceholderLabel,label: categoryLabel)
        
        companyplaceholderLabel = UILabel()
        setTextViewPlaceHolderLabel(phlabel: companyplaceholderLabel,txtview: companytxtview)
        
        locationplaceholderLabel = UILabel()
        setLabelPlaceHolderLabel(phlabel: locationplaceholderLabel,label: locationLabel)
        
        amountwagesplaceholderLabel = UILabel()
        setTextViewPlaceHolderLabel(phlabel: amountwagesplaceholderLabel,txtview: amountwagestxtview)
        
        dateplaceholderLabel = UILabel()
        setLabelPlaceHolderLabel(phlabel: dateplaceholderLabel,label: dateLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.updateCategoryLabel(_:)), name: Notification.Name("updateCategory"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.updateDateLabel(_:)), name: Notification.Name("updateDate"), object: nil)
        
        self.ImageEditView.layer.cornerRadius = ImageEditView.bounds.size.width/2
        self.ImageEditView.layer.masksToBounds = true
        self.ImageEditView.clipsToBounds = true
        self.ImageEditView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.ImageEditView.layer.borderWidth = 2.0
        self.ImageEditView.layer.borderColor = UIColor.white.cgColor
        
        let ref = Database.database().reference()
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Post Anonymouse User")
              
            }
            else {
                
                let uid = currentUser?.uid
                
                getOwnUserDetails()
                
                ref.child("UserPhone").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                       // self.getphonenumber()
                        return
                        
                    }
                    
                    if snapshot.hasChild("verification") {
                        let verified_val = snapshot.childSnapshot(forPath: "verification").value as! String
                        
                        if verified_val == "pending" {
                            
                           // self.getverificationCode()
                        }
                        
                    }
                    
                })
                
            }
 
        }
        
        ref.child("DefaultJobPhotos").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            if (snapshot.hasChild("jobbg1")){
                if let jobbg1 = snapshot.childSnapshot(forPath: "jobbg1").value as? String
                {
                    self.mjobbg1 = jobbg1
                }
            }
            if (snapshot.hasChild("jobbg2")){
                if let jobbg2 = snapshot.childSnapshot(forPath: "jobbg2").value as? String
                {
                    self.mjobbg2 = jobbg2
                }
            }
            if (snapshot.hasChild("jobbg3")){
                if let jobbg3 = snapshot.childSnapshot(forPath: "jobbg3").value as? String
                {
                    self.mjobbg3 = jobbg3
                }
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateCategoryLabel(_ notification: NSNotification) {
        
        if let categoryval = notification.userInfo?["category"] as? String {
            if (categoryval != "") {
                categoryLabel.text = categoryval
                categoryplaceholderLabel.isHidden = true
            }
        }
        if let categorynumval = notification.userInfo?["categorynum"] as? String {
            if (categorynumval != "") {
                categorynum = Int64(categorynumval)
                print("categorynum = \(categorynum!)")
            }
        }
        
    }
    
    @objc func updateDateLabel(_ notification: NSNotification) {
        
        if let dateval = notification.userInfo?["labeldate"] as? String {
            if (dateval != "") {
                dateLabel.text = dateval
                dateplaceholderLabel.isHidden = true
            }
        }
        if let startdateval = notification.userInfo?["startdate"] as? String {
            if (startdateval != "") {
                startingdate = startdateval
                print("startingdate = \(startingdate)")
            }
        }
    }
    
    func showUserAnonymousDialog() {
       
        let alert = UIAlertController(title: "Login via social media or email is required to perform further actions", message: "", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Log In", style: UIAlertActionStyle.default, handler: { action in
            
            self.logOutAnonymous()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
      
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.tag == 0){
            titleplaceholderLabel.isHidden = !textView.text.isEmpty
        }
        else if (textView.tag == 1){
            descripplaceholderLabel.isHidden = !textView.text.isEmpty
        }
        else if (textView.tag == 2){
            categoryplaceholderLabel.isHidden = !textView.text.isEmpty
        }
        else if (textView.tag == 3){
            companyplaceholderLabel.isHidden = !textView.text.isEmpty
        }
        else if (textView.tag == 5){
            //amountwagesplaceholderLabel.isHidden = !textView.text.isEmpty
            if let amountString = textView.text?.currencyInputFormatting() {
                textView.text = amountString
                amountwagesplaceholderLabel.isHidden = !textView.text.isEmpty
            }
        }
    }
    
    func setTextViewPlaceHolderLabel(phlabel: UILabel, txtview: UITextView){
        
        if (txtview.tag == 0){
            phlabel.text = "Name the job's title"
        }
        else if (txtview.tag == 1){
            phlabel.text = "Tell more about the jobs, i.e attires / time"
        }
        else if (txtview.tag == 3){
            phlabel.text = "Name of company / stall / outlet"
        }
        else if (txtview.tag == 5){
            phlabel.text = "i.e 80.00"
        }
        
        phlabel.font = UIFont.italicSystemFont(ofSize: (txtview.font?.pointSize)!)
        phlabel.sizeToFit()
        txtview.addSubview(phlabel)
        phlabel.frame.origin = CGPoint(x: 5, y: (txtview.font?.pointSize)! / 2)
        phlabel.textColor = UIColor.lightGray
        phlabel.isHidden = !txtview.text.isEmpty
    }
    
    func setLabelPlaceHolderLabel(phlabel: UILabel, label: UILabel){
        
        if (label.tag == 2){
            phlabel.text = "Tap to select category"
        }
        else if (label.tag == 4){
            phlabel.text = "Pick the job's location"
        }
        else if (label.tag == 6){
            phlabel.text = "Tap to select dates of job"
        }
        
        phlabel.font = UIFont.italicSystemFont(ofSize: (label.font?.pointSize)!)
        phlabel.sizeToFit()
        label.addSubview(phlabel)
        phlabel.frame.origin = CGPoint(x: 5, y: (label.font?.pointSize)! / 2)
        phlabel.textColor = UIColor.lightGray
        phlabel.isHidden = false
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView.tag == 1){
            return picker_values.count
        }else{
            return rate_values.count
        }
        
    }
    
    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView.tag == 1){
            return picker_values[row]
        }else{
            return rate_values[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Your Function
        
        if (pickerView.tag == 1){
            self.selectedCurrency = picker_values[row]
            PickerCurrencySelectedRow = Int64(row)
        }else{
            self.selectedRate = rate_values[row]
            PickerRateSelectedRow = row
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        mImageUrl = documentsPath?.appendingPathComponent("image.jpg")
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            self.previewImage.image = pickedImage
            uploadView.isHidden = true
            self.ImageEditView.isHidden = false
            try! UIImageJPEGRepresentation(pickedImage, 0.4)?.write(to: mImageUrl)
        }
        
        print("mImageUrl = \(mImageUrl)")
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func deleteDatePressed(_ sender: Any) {
        dateLabel.text = ""
        startingdate = ""
        dateplaceholderLabel.isHidden = false
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func editPhotoPressed(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        
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
                    
                    self.locationplaceholderLabel.isHidden = true
                }
                else if (fulladdress != "") {
                    self.locationLabel.text = placename + ", " + fulladdress
                    self.locationplaceholderLabel.isHidden = true
                }
                else{
                    self.locationLabel.text = "Address not found"
                    self.locationplaceholderLabel.isHidden = true
                }
                
            }
        }
        
    }
    
    @IBAction func rateEdit(_ sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        myPicker2.tintColor = tintColor
        myPicker2.center.x = inputView.center.x
        inputView.addSubview(myPicker2) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(PostViewController.doneRateButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(PostViewController.cancelRatePicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @IBAction func ratePressed(_ sender: UIButton) {
        
        self.ratetxtfield.becomeFirstResponder()
    }
    
    @objc func cancelRatePicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.ratetxtfield.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneRateButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.ratetxtfield.text = self.selectedRate
        self.ratetxtfield.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    
    
    @IBAction func currencyEdit(_ sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        myPicker.tintColor = tintColor
        myPicker.center.x = inputView.center.x
        inputView.addSubview(myPicker) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(doneButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(cancelPicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @IBAction func currencyPressed(_ sender: UIButton) {
        self.currencytxtfield.becomeFirstResponder()
    }
    
    @objc func cancelPicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencytxtfield.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencytxtfield.text = self.selectedCurrency
        self.currencytxtfield.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    func getOwnUserDetails() {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserAccount").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                if (snapshot.hasChild("name")){
                    if let userName = snapshot.childSnapshot(forPath: "name").value as? String
                    {
                        self.myownname = userName
                    }
                }
                if (snapshot.hasChild("image")){
                    if let userImage = snapshot.childSnapshot(forPath: "image").value as? String
                    {
                        self.myownimage = userImage
                    }
                }
                
            })
        }
    }
    
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func publishPressed(_ sender: Any) {
        
        if (titletxtview.text != "" && descriptxtview.text != "" && categoryLabel.text != ""
            && companytxtview.text != "" && locationLabel.text != "") {
            
            AppDelegate.instance().showActivityIndicator()
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                let ref = Database.database().reference()
                let newPost = ref.child("Job").child(self.city).childByAutoId()
                let newPostKey = newPost.key
                let newPosted = ref.child("UserPosted").child(uid!).child(newPostKey)
                let mGeoFire = ref.child("JobsLocation").child(self.city)
                let geoFire = GeoFire(firebaseRef: mGeoFire)
                
                let storage = Storage.storage().reference()
                let imageRef = storage.child("JobPhotos").child("\(newPostKey).jpg")
                
                // GOT Picture
                if (mImageUrl != nil && self.city != nil) {
                    
                    let uploadTask = imageRef.putFile(from: mImageUrl, metadata: nil) { (metadata, error) in
                        if error != nil{
                            print(error!.localizedDescription)
                            AppDelegate.instance().dismissActivityIndicator()
                            return
                        }
                        
                        
                        imageRef.downloadURL(completion: { (url, error) in
                            if let url = url{
                                
                                let stringurl = url.absoluteString
                                
                                self.startPosting(uid:uid!, stringurl:stringurl, newPost:newPost, newPosted:newPosted, newPostKey: newPostKey, newLocation: geoFire)
                            }
                        })
                    }
                    
                    uploadTask.resume()
                }
                    //Else, NO Picture
                else if (mImageUrl == nil && self.city != nil) {
                    
                    var imageurlstring = ""
                    
                    let diceRoll = Int(arc4random_uniform(3))
                    
                    if diceRoll == 0 {
                        imageurlstring = self.mjobbg1
                    }
                    else if diceRoll == 1 {
                        imageurlstring = self.mjobbg2
                    }
                    else if diceRoll == 2 {
                        imageurlstring = self.mjobbg3
                    }
                    
                    self.startPosting(uid:uid!, stringurl:imageurlstring, newPost:newPost, newPosted:newPosted, newPostKey: newPostKey, newLocation: geoFire)
                }
                
                
            }
            else {
                AppDelegate.instance().dismissActivityIndicator()
                self.view.makeToast("User not found, please re-login to try again", duration: 2.0, position: .center)
                dismiss(animated: true, completion: nil)
            }
            
            
            
        }
        
        
        
    }
    
    func startPosting(uid:String, stringurl:String, newPost:DatabaseReference, newPosted:DatabaseReference, newPostKey: String, newLocation:GeoFire) {
        
        let titleval:String! =  titletxtview.text
        let descripval:String! =  descriptxtview.text
        let categoryval:String! =  categoryLabel.text
        let companyval:String! =  companytxtview.text
        let locationval:String! =  locationLabel.text
        
        let wagesamountval:String! =  amountwagestxtview.text
        let dateval:String! =  dateLabel.text
        let wagesrateval:String! =  ratetxtfield.text
        let wagescurrencyval:String! =  currencytxtfield.text
        
        let wagesamount: Double = amountwagestxtview.text.toDouble
        let amountcoins: Double = (wagesamount.truncatingRemainder(dividingBy: 1) * 100).rounded() / 100
        let amountwhole = Int64(wagesamount.rounded(.towardZero))
        
        let tsLong = self.getCurrentMillis()/1000
        
        let negatedtime  = -1*tsLong
        
        var newPostDetails = ["negatedtime": negatedtime,
                              "time": ServerValue.timestamp(),
                              "title": titleval,
                              "lowertitle": titleval.lowercased(),
                              "desc": descripval,
                              "category": categoryval,
                              "company": companyval,
                              "fulladdress": locationval,
                              "city": self.city,
                              "latitude": self.finallatitude,
                              "longitude": self.finallongitude,
                              "uid": uid,
                              "postimage": stringurl,
                              "userimage": self.myownimage,
                              "postkey": newPostKey,
                              "closed": "false",
                              "username": self.myownname
            
            ] as [String : Any]
        
        //UserPosted
        let newUserPostedDetails = ["title": titleval,
                                    "desc": descripval,
                                    "company": companyval,
                                    "city": self.city,
                                    //                                    "category": categoryval,
            "pressed": "true",
            "closed": "false",
            //                                    "removed": "false",
            "totalhiredcount": 0,
            "applicantscount": 0,
            "newapplicantscount": 0,
            "postimage": stringurl
            ] as [String : Any]
        
        newPosted.setValue(newUserPostedDetails)
        
        //GEoFire
        
        //Job Database
        let categorylong :Int64 = Int64(self.categorynum * 10000000000)
        let categoryNts :Int64 = categorylong + tsLong
        
        newPostDetails["category_negatedtime"] = -1 * (categoryNts)
        print("categorylong = \(categorylong)")
        
        //If wages are set
        if (wagesamountval != "") {
            print("wagescurrencyval = \(wagescurrencyval)")
            print("wagesamountval = \(wagesamountval)")
            print("wagesrateval = \(wagesrateval)")
            
            newPostDetails["wages"] = wagescurrencyval + " " + wagesamountval + " " + wagesrateval
            
            print("newPostDetails = \(newPostDetails)")
            
            var wagescategory :Int64 = 0
            
            if (wagesrateval == "per hour") {
                if (amountwhole < 5) { wagescategory = 11}
                else if (amountwhole >= 5 && amountwhole <= 10) { wagescategory = 12}
                else if (amountwhole >= 11 && amountwhole <= 20) { wagescategory = 13}
                else if (amountwhole >= 21 && amountwhole <= 50) { wagescategory = 14}
                else if (amountwhole > 50) { wagescategory = 15}
            }
            else if (wagesrateval == "per day") {
                if (amountwhole < 70) { wagescategory = 21}
                else if (amountwhole >= 70 && amountwhole <= 100) { wagescategory = 22}
                else if (amountwhole >= 101 && amountwhole <= 200) { wagescategory = 23}
                else if (amountwhole >= 201 && amountwhole <= 500) { wagescategory = 24}
                else if (amountwhole > 500) { wagescategory = 25}
            }
            else if (wagesrateval == "per month") {
                if (amountwhole < 1000) { wagescategory = 31}
                else if (amountwhole >= 1000 && amountwhole <= 1500) { wagescategory = 32}
                else if (amountwhole >= 1501 && amountwhole <= 2000) { wagescategory = 33}
                else if (amountwhole >= 2001 && amountwhole <= 5000) { wagescategory = 34}
                else if (amountwhole > 5000) { wagescategory = 35}
            }
            
            let wagesMultiply = Int64(wagescategory * 10000000000)
            let mostrecent2 = Int64((self.PickerCurrencySelectedRow + 11) * 1000000000000)
            
            let mostrecent_wagesrange : Int64 = Int64(tsLong + wagesMultiply + mostrecent2)
            newPostDetails["mostrecent_wagesrange"] = -1 * mostrecent_wagesrange
            
            let categorywageslong = Int64(self.categorynum * 100000000000000)
            let addCatnMostRecent = Int64(categorywageslong + mostrecent_wagesrange)
            newPostDetails["category_mostrecent_wagesrange"] = -1 * (addCatnMostRecent)
            
            
            //If wages and dates are set
            if (self.startingdate != "") {
                
                let truncatedlongtime = tsLong%100000000
                
                let categorymostrecent = Int64(self.categorynum * 100000000000000000)
                
                let startdate_Str = Int64(self.startingdate)!
                let opreation1 = Int64(startdate_Str * 100000000)
                
                let mostrecent_wagesrange_startdate_1 = ((truncatedlongtime) + opreation1)
                
                
                let mostrecent_wagesrange_startdate_2 = Int64((wagescategory * 100000000000000) + ((self.PickerCurrencySelectedRow + 11) * 10000000000000000))
                
                let category_mostrecent_wagesrange_startdate_2 = Int64((wagescategory * 100000000000000) + ((self.PickerCurrencySelectedRow) * 10000000000000000))
                
                let mostrecent_wagesrange_startdate = -1 * (mostrecent_wagesrange_startdate_1 + mostrecent_wagesrange_startdate_2)
                
                newPostDetails["mostrecent_wagesrange_startdate"] = mostrecent_wagesrange_startdate
                
                let category_mostrecent_wagesrange_startdate = -1 * Int64((mostrecent_wagesrange_startdate_1 + category_mostrecent_wagesrange_startdate_2 + categorymostrecent))
                
                newPostDetails["category_mostrecent_wagesrange_startdate"] = category_mostrecent_wagesrange_startdate
            }
                //If no dates are set
            else {
                newPostDetails["mostrecent_wagesrange_startdate"] = 0
                newPostDetails["category_mostrecent_wagesrange_startdate"] = 0
            }
        }
            //If wages are not set
        else {
            print("wages not set")
            newPostDetails["wages"] = "none"
            newPostDetails["mostrecent_wagesrange"] = 0
            newPostDetails["category_mostrecent_wagesrange"] = 0
            newPostDetails["mostrecent_wagesrange_startdate"] = 0
            newPostDetails["category_mostrecent_wagesrange_startdate"] = 0
        }
        
        
        //If dates are set
        if (dateval != "") {
            newPostDetails["date"] = dateval
            
            if (self.startingdate != "") {
                let startdate = Int64(self.startingdate)
                let mostrecent_startdate = (startdate! * 10000000000) + tsLong
                newPostDetails["mostrecent_startdate"] = -1 * mostrecent_startdate
                
                let categorywageslong = Int64(self.categorynum * 10000000000000000)
                let category_mostrecent_startdate = (startdate! * 10000000000) + tsLong
                newPostDetails["category_mostrecent_startdate"] = -1 * (category_mostrecent_startdate + categorywageslong)
            }
            else {
                newPostDetails["mostrecent_startdate"] = 0
                newPostDetails["category_mostrecent_startdate"] = 0
            }
        }
            //If dates are not set
        else {
            print("dates not set")
            newPostDetails["date"] = "none"
            newPostDetails["mostrecent_startdate"] = 0
            newPostDetails["category_mostrecent_startdate"] = 0
        }
        
        print("finalnewPostDetails = \(newPostDetails)")
        
        newPost.setValue(newPostDetails,  withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
            
            print("inisde")
            
            if (error != nil) {
                // handle an error
                AppDelegate.instance().dismissActivityIndicator()
                self.view.makeToast("Post Failed", duration: 2.0, position: .center)
                newLocation.setLocation(CLLocation(latitude: self.finallatitude, longitude: self.finallongitude), forKey: newPostKey, withCompletionBlock: { (error) in
                    if (error != nil) {
                        print("cant save geolocation")
                    }
                    else {
                        print("successfully save geolocation")
                    }
                })
                
                self.dismiss(animated: true, completion: nil)
            }
            else{
                //Set prefs
                ref.child("SortFilter").child(uid).removeValue()
                AppDelegate.instance().dismissActivityIndicator()
                self.view.makeToast("Post Successfully Published!", duration: 2.0, position: .center)
                newLocation.setLocation(CLLocation(latitude: self.finallatitude, longitude: self.finallongitude), forKey: newPostKey, withCompletionBlock: { (error) in
                    if (error != nil) {
                        print("cant save geolocation")
                    }
                    else {
                        print("successfully save geolocation")
                    }
                })
                self.dismiss(animated: true, completion: nil)
            }
        })
        
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func getphonenumber() {
        print("getphonenumber")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        
        let customAlert = storyBoard.instantiateViewController(withIdentifier: "VerificationAlert") as! VerificationAlert
        
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func okButtonTapped(textFieldValue: String) {
        
        AppDelegate.instance().showActivityIndicator()
        
        PhoneAuthProvider.provider().verifyPhoneNumber(textFieldValue, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                // TODO: show error
                print("error sending phone verifi = \(error)")
                AppDelegate.instance().dismissActivityIndicator()
                // create the alert
                let alert = UIAlertController(title: "Error", message: "Invalid phone number", preferredStyle: .alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard let verificationID = verificationID else {
                print("wrong veriID")
                AppDelegate.instance().dismissActivityIndicator()
                // create the alert
                let alert = UIAlertController(title: "Error", message: "Invalid phone number", preferredStyle: .alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let ref = Database.database().reference()
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                ref.child("UserPhone").child(uid!).child("verification").setValue("pending")
            }
            
            self.getverificationCode()
            AppDelegate.instance().dismissActivityIndicator()
            
        }
        
        print("TextField has value: \(textFieldValue)")
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func getverificationCode() {
        print("getverificationCode")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        
        let customAlert2 = storyBoard.instantiateViewController(withIdentifier: "VerificationAlert2") as! VerificationAlert2
        
        customAlert2.providesPresentationContextTransitionStyle = true
        customAlert2.definesPresentationContext = true
        customAlert2.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert2.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert2.delegate = self
        self.present(customAlert2, animated: true, completion: nil)
    }
    
    func resendButtonTapped() {
        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
            
            let customAlert = storyBoard.instantiateViewController(withIdentifier: "VerificationAlert") as! VerificationAlert
            
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
        }
        
    }
    
    func editPhoneTapped() {
        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
            
            let customAlert = storyBoard.instantiateViewController(withIdentifier: "VerificationAlert") as! VerificationAlert
            
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
        }
    }
    
    func verifyButtonTapped(textFieldValue: String) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        let verificationCode = textFieldValue
        
        if verificationID != nil && verificationCode != "" {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
            Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (err) in
                if err != nil {
                    print("error updating phone number = \(err?.localizedDescription)")
                    // create the alert
                    let alert = UIAlertController(title: "Error", message: "Phone number has been used before", preferredStyle: .alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let ref = Database.database().reference()
                
                let currentUser = Auth.auth().currentUser
                
                if(currentUser != nil){
                    
                    let uid = currentUser?.uid
                    
                    ref.child("UserPhone").child(uid!).child("verification").setValue("verified")
                }
            })
            // TODO: handle sign in
            
        }
    }
    
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        print("amountWithPrefix = \(amountWithPrefix)")
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        print("self.characters.count = \(self.characters.count)")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        print("number = \(number)")
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        print("formatter.string(from: number)! = \(formatter.string(from: number)!)")
        
        var stringnum =  formatter.string(from: number)!
        
        if let sep = formatter.currencyGroupingSeparator {
            stringnum = stringnum.replacingOccurrences(of: sep, with: "")
        }
        
        print("stringnum = \(stringnum)")
        
        return stringnum
        
    }
    
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}
