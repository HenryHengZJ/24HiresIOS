//
//  EditPostViewController.swift
//  JobIn24
//
//  Created by MacUser on 30/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
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

class EditPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GMSPlacePickerViewControllerDelegate, CLLocationManagerDelegate {
    
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
    var newcity: String!
    var postkey: String!
    var myownname: String!
    var myownimage: String!
    var mjobbg1: String!
    var mjobbg2: String!
    var mjobbg3: String!
    var jobpostimage: String!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getOwnUserDetails()
        
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
        
        fetchData()
        
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
                return
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                self.newcity = pm.administrativeArea
                
                if (fulladdress.contains("Pulau Pinang") || fulladdress.contains("Penang")){
                    self.newcity = "Penang"
                }
                else if (fulladdress.contains("Kuala Lumpur")){
                    self.newcity = "Kuala Lumpur"
                }
                else if (fulladdress.contains("Labuan")){
                    self.newcity = "Labuan"
                }
                else if (fulladdress.contains("Putrajaya")){
                    self.newcity = "Putrajaya"
                }
                else if (fulladdress.contains("Johor")){
                    self.newcity = "Johor"
                }
                else if (fulladdress.contains("Kelantan")){
                    self.newcity = "Kelantan"
                }
                else if (fulladdress.contains("Melaka") || fulladdress.contains("Melacca")){
                    self.newcity = "Melacca"
                }
                else if (fulladdress.contains("Negeri Sembilan") || fulladdress.contains("Seremban")){
                    self.newcity = "Negeri Sembilan"
                }
                else if (fulladdress.contains("Pahang")){
                    self.newcity = "Pahang"
                }
                else if (fulladdress.contains("Perak") || fulladdress.contains("Ipoh")){
                    self.newcity = "Perak"
                }
                else if (fulladdress.contains("Perlis")){
                    self.newcity = "Perlis"
                }
                else if (fulladdress.contains("Sabah")){
                    self.newcity = "Sabah"
                }
                else if (fulladdress.contains("Sarawak")){
                    self.newcity = "Sarawak"
                }
                else if (fulladdress.contains("Selangor") || fulladdress.contains("Shah Alam") || fulladdress.contains("Klang")){
                    self.newcity = "Selangor"
                }
                else if (fulladdress.contains("Terengganu")){
                    self.newcity = "Terengganu"
                }
                else if (fulladdress.contains("Limerick")){
                    self.newcity = "County Limerick"
                }
                print("newcity = \(self.newcity)")
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
    
    func fetchData() {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
           
            ref.child("Job").child(self.city).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                if snapshot.hasChild("title") {
                    self.titleplaceholderLabel.isHidden = true
                    self.titletxtview.text = snapshot.childSnapshot(forPath: "title").value as? String
                }
                
                if snapshot.hasChild("desc") {
                    self.descripplaceholderLabel.isHidden = true
                    self.descriptxtview.text = snapshot.childSnapshot(forPath: "desc").value as? String
                }
                
                if snapshot.hasChild("category") {
                    self.categoryplaceholderLabel.isHidden = true
                    self.categoryLabel.text = snapshot.childSnapshot(forPath: "category").value as? String
                }
                
                if snapshot.hasChild("company") {
                    self.companyplaceholderLabel.isHidden = true
                    self.companytxtview.text = snapshot.childSnapshot(forPath: "company").value as? String
                }
                
                if snapshot.hasChild("fulladdress") {
                    self.locationplaceholderLabel.isHidden = true
                    self.locationLabel.text = snapshot.childSnapshot(forPath: "fulladdress").value as? String
                }
                
                if snapshot.hasChild("longitude") {
                    self.finallongitude = snapshot.childSnapshot(forPath: "longitude").value as? Double
                }
                
                if snapshot.hasChild("latitude") {
                    self.finallatitude = snapshot.childSnapshot(forPath: "latitude").value as? Double
                }
                
                if snapshot.hasChild("postimage") {
                    self.previewImage.sd_setImage(with: URL(string: snapshot.childSnapshot(forPath: "postimage").value as! String), placeholderImage: UIImage(named: "addphoto_darker_bg"))
                    self.jobpostimage = snapshot.childSnapshot(forPath: "postimage").value as! String
                    
                    self.uploadView.isHidden = true
                    self.ImageEditView.isHidden = false
                }
                
                if snapshot.hasChild("date") {
                    let date = snapshot.childSnapshot(forPath: "date").value as? String
                    
                    if date != "none" {
                        self.dateplaceholderLabel.isHidden = true
                        self.dateLabel.text = snapshot.childSnapshot(forPath: "date").value as? String
                    }
                }
                
                if snapshot.hasChild("mostrecent_startdate") {
                    let mostrecent_startdatelong = snapshot.childSnapshot(forPath: "mostrecent_startdate").value as! Int64
                    
                    if mostrecent_startdatelong != 0 {
                        let mostrecent_startdatestring = String(describing: mostrecent_startdatelong)
                         print("mostrecent_startdatestring = \(mostrecent_startdatestring)")
                        let startIndex = mostrecent_startdatestring.index(mostrecent_startdatestring.startIndex, offsetBy: 1)
                        let endIndex = mostrecent_startdatestring.index(mostrecent_startdatestring.startIndex, offsetBy: 6)
                        self.startingdate = String(mostrecent_startdatestring[startIndex...endIndex])
                        //Swift 4: self.startingdate = String(str[startIndex...endIndex])
                        print("startingdate = \(self.startingdate)")
                        
                    }
                }
                
                if snapshot.hasChild("wages") {
                    let wagesval = snapshot.childSnapshot(forPath: "wages").value as! String
                    
                    if(wagesval != "none"){
                        
                        self.amountwagesplaceholderLabel.isHidden = true
                        
                        let separated1 = wagesval.components(separatedBy: "per")
                        let separated2 = separated1[0].components(separatedBy: " ")
                        
                        let fullwages = separated2[1]
                        let stringcurrency = separated2[0]
                        let rateper = separated1[1]
                        
                        self.amountwagestxtview.text = fullwages
                        
                        
                        if(rateper == "hour"){
                            self.selectedRate = "per hour"
                            self.ratetxtfield.text = self.selectedRate
                        }
                        else if(rateper == "day"){
                            self.selectedRate = "per day"
                            self.ratetxtfield.text = self.selectedRate
                        }
                        else{
                            self.selectedRate = "per month"
                            self.ratetxtfield.text = self.selectedRate
                        }
                        
                        if(stringcurrency.contains("MYR")){
                            self.selectedCurrency = "MYR"
                        }
                        else if(stringcurrency.contains("SGD")){
                            self.selectedCurrency = "SGD"
                        }
                        else if(stringcurrency.contains("CHY")){
                            self.selectedCurrency = "CHY"
                        }
                        else if(stringcurrency.contains("USD")){
                            self.selectedCurrency = "USD"
                        }
                        else if(stringcurrency.contains("GBP")){
                            self.selectedCurrency = "GBP"
                        }
                        else if(stringcurrency.contains("EUR")){
                            self.selectedCurrency = "EUR"
                        }
                        else if(stringcurrency.contains("NTD")){
                            self.selectedCurrency = "NTD"
                        }
                        else if(stringcurrency.contains("HKD")){
                            self.selectedCurrency = "HKD"
                        }
                        else if(stringcurrency.contains("INR")){
                            self.selectedCurrency = "INR"
                        }
                        else if(stringcurrency.contains("IDR")){
                            self.selectedCurrency = "IDR"
                        }
                        
                        self.currencytxtfield.text = self.selectedCurrency
                       
                    }
                   
                }

            })
        }
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
                
                var newPost: DatabaseReference!
                if newcity != nil && newcity != self.city {
                    newPost = ref.child("Job").child(self.newcity).child(self.postkey)
                }
                else {
                    newPost = ref.child("Job").child(self.city).child(self.postkey)
                }
                
                let newPosted = ref.child("UserPosted").child(uid!).child(self.postkey)
              
                let storage = Storage.storage().reference()
                let imageRef = storage.child("JobPhotos").child("\(self.postkey).jpg")
                
                // GOT Picture
                if (mImageUrl != nil && self.city != nil) {
                    
                    if self.jobpostimage != nil && self.mjobbg1 != nil && self.mjobbg2 != nil && self.mjobbg3 != nil {
                        if self.jobpostimage != self.mjobbg1 && self.jobpostimage != self.mjobbg2 && self.jobpostimage != self.mjobbg3 {
                            
                            let oldjobphotostorage = Storage.storage().reference(forURL: self.jobpostimage!)
                            
                            oldjobphotostorage.delete(completion: { (error) in
                                if error != nil{
                                    print("old photo not found")
                                    return
                                }
                                
                                print("deleted old photo")
                            })
                        }
                    }
     
                    let uploadTask = imageRef.putFile(from: mImageUrl, metadata: nil) { (metadata, error) in
                        if error != nil{
                            print(error!.localizedDescription)
                            AppDelegate.instance().dismissActivityIndicator()
                            return
                        }
                        
                        
                        imageRef.downloadURL(completion: { (url, error) in
                            if let url = url{
                                
                                let stringurl = url.absoluteString
                                
                                var citychanged = false
                                var photochanged = true
                                
                                if self.newcity != nil && self.newcity != self.city {
                                    citychanged = true
                                    self.startPosting(citychanged: citychanged, photochanged: photochanged, uid:uid!, stringurl:stringurl, newPost:newPost, newPosted:newPosted)
                                }
                                else {
                                    self.startPosting(citychanged: citychanged, photochanged: photochanged, uid:uid!, stringurl:stringurl, newPost:newPost, newPosted:newPosted)
                                }
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
                    
                    var citychanged = false
                    var photochanged = false
                    
                    if newcity != nil && newcity != self.city {
                        citychanged = true
                        self.startPosting(citychanged: citychanged, photochanged: photochanged, uid:uid!, stringurl:imageurlstring, newPost:newPost, newPosted:newPosted)
                    }
                    else {
                        self.startPosting(citychanged: citychanged, photochanged: photochanged, uid:uid!, stringurl:imageurlstring, newPost:newPost, newPosted:newPosted)
                    }
                    
                }
                
            }
            else {
                AppDelegate.instance().dismissActivityIndicator()
                self.view.makeToast("User not found, please re-login to try again", duration: 2.0, position: .center)
                dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    func startPosting(citychanged:  Bool, photochanged: Bool, uid:String, stringurl:String, newPost:DatabaseReference, newPosted:DatabaseReference) {
        
        let ref = Database.database().reference()

        let mOldGeoFire = ref.child("JobsLocation").child(self.city).child(self.postkey)

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
        
        switch (categoryval) {
            case "Barista / Bartender": categorynum = 11
            case "Beauty / Wellness": categorynum = 12
            case "Chef / Kitchen Helper": categorynum = 13
            case "Event Crew": categorynum = 14
            case "Emcee": categorynum = 15
            case "Education": categorynum = 16
            case "Fitness / Gym": categorynum = 17
            case "Modelling / Shooting": categorynum = 18
            case "Mascot": categorynum = 19
            case "Office / Admin": categorynum = 20
            case "Promoter / Sampling": categorynum = 21
            case "Roadshow": categorynum = 22
            case "Roving Team": categorynum = 23
            case "Retail / Consumer": categorynum = 24
            case "Serving": categorynum = 25
            case "Usher / Ambassador": categorynum = 26
            case "Waiter / Waitress": categorynum = 27
            case "Other": categorynum = 28
            default: categorynum = 28
        
        }
        
        
        //Job Post
        var newPostDetails = [
            "title": titleval,
            "lowertitle": titleval.lowercased(),
            "desc": descripval,
            "category": categoryval,
            "company": companyval,
            "fulladdress": locationval,
            "latitude": self.finallatitude,
            "longitude": self.finallongitude
            ] as [String : Any]
        
        //UserPosted
        var newUserPostedDetails = ["title": titleval,
                                    "desc": descripval,
                                    "company": companyval
            
            ] as [String : Any]
        
        
        //UserApplied
        var newUserAppliedDetails = ["title": titleval,
                                     "desc": descripval,
                                     "company": companyval
            
            ] as [String : Any]
        
        
        //GEoFire
        if citychanged == true {
 
            ref.child("JobsLocation").child(self.city).child(self.postkey).removeValue()
            
            let newGeoFire = ref.child("JobsLocation").child(self.newcity)
            let geoFire = GeoFire(firebaseRef: newGeoFire)
            
            geoFire.setLocation(CLLocation(latitude: self.finallatitude, longitude: self.finallongitude), forKey: self.postkey, withCompletionBlock: { (error) in
                if (error != nil) {
                    print("cant save geolocation")
                }
                else {
                    print("successfully save geolocation")
                }
            })

            newPostDetails["city"] = self.newcity
            newPostDetails["negatedtime"] = negatedtime
            newPostDetails["time"] = ServerValue.timestamp()
            
            newUserPostedDetails["city"] = self.newcity
            newUserAppliedDetails["city"] = self.newcity
            
        }
        
        //Changed Picture
        if photochanged == true {
            
            newPostDetails["postimage"] = stringurl
            newUserPostedDetails["postimage"] = stringurl
            newUserAppliedDetails["postimage"] = stringurl
            
        }
        
        //Job Post Other Details
        let categorylong :Int64 = Int64(self.categorynum * 10000000000)
        let categoryNts :Int64 = categorylong + tsLong
        
        newPostDetails["category_negatedtime"] = -1 * (categoryNts)
        
        
        //If wages are set
        if (wagesamountval != "") {
            
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
        
        if citychanged == true {
            print("citychanged 1")
            ref.child("Job").child(self.city).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                print("snapshot.value = \(snapshot.value as? [String:Any])")
                
                newPost.setValue(snapshot.value as? [String:Any],  withCompletionBlock: { (error:Error?, errref:DatabaseReference!) in
                    if (error != nil) {
                        AppDelegate.instance().dismissActivityIndicator()
                        self.view.makeToast("Post Failed to Publish!", duration: 2.0, position: .center)
                    }
                    else {

                        print("citychanged 2")
                        newPost.updateChildValues(newPostDetails, withCompletionBlock: { (error:Error?, errref:DatabaseReference!) in
                            if (error != nil) {
                                AppDelegate.instance().dismissActivityIndicator()
                                self.view.makeToast("Post Failed to Publish!", duration: 2.0, position: .center)
                            }
                            else {
                                ref.child("Job").child(self.city).child(self.postkey).removeValue()
                                
                                self.findApplicants(newUserAppliedDetails: newUserAppliedDetails);
                                
                                AppDelegate.instance().dismissActivityIndicator()
                                self.view.makeToast("Post Successfully Published!", duration: 2.0, position: .center)
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                            
                        })
                    }
                })
            })
        }
            
        else {
            
            print("city NO changed ")
                
            newPost.updateChildValues(newPostDetails, withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
                if (error != nil) {
                    AppDelegate.instance().dismissActivityIndicator()
                    self.view.makeToast("Post Failed to Publish!", duration: 2.0, position: .center)
                }
                else {
                    self.findApplicants(newUserAppliedDetails: newUserAppliedDetails)
                    AppDelegate.instance().dismissActivityIndicator()
                    self.view.makeToast("Post Successfully Published!", duration: 2.0, position: .center)
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
        }
                
        newPosted.updateChildValues(newUserPostedDetails)
            
    }
    
    func findApplicants(newUserAppliedDetails: Dictionary<String, Any>) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            //Notify all PENDING applicants who has applied to the job about the job has changed
            ref.child("UserPostedPendingApplicants").child(uid!).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
               
                    if let applicantuserid = rest.key as? String {
                        ref.child("UserActivities").child(applicantuserid).child("Applied").child(self.postkey).updateChildValues(newUserAppliedDetails)
                    }
                }
                
            })
            
            //Notify all SHORTLISTED applicants who has applied to the job about the job has changed
            ref.child("UserPostedShortlistedApplicants").child(uid!).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let applicantuserid = rest.key as? String {
                        ref.child("UserActivities").child(applicantuserid).child("Applied").child(self.postkey).updateChildValues(newUserAppliedDetails)
                    }
                }
                
            })
            
            //Notify all HIRED applicants who has applied to the job about the job has changed
            ref.child("UserPostedHiredApplicants").child(uid!).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let applicantuserid = rest.key as? String {
                        ref.child("UserActivities").child(applicantuserid).child("Applied").child(self.postkey).updateChildValues(newUserAppliedDetails)
                    }
                }
                
            })
            
        }
    }

    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

}

extension String {
    /*subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    var count: Int { return self.count }*/
}
