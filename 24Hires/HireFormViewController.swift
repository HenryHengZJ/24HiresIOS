//
//  HireFormViewController.swift
//  24Hires
//
//  Created by Jeekson Choong on 01/05/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps
import GooglePlacePicker
import NVActivityIndicatorView

class HireFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource , UITextFieldDelegate, GMSPlacePickerViewControllerDelegate, NVActivityIndicatorViewable,UITextViewDelegate {

    
    //MARK:- IBOutlet & IBAction
    @IBOutlet weak var jobImageView         : UIImageView!
    @IBOutlet weak var jobTitleLabel        : UILabel!
    @IBOutlet weak var hirerNameLabel       : UILabel!
    @IBOutlet weak var jobDescLabel         : UILabel!
    @IBOutlet weak var jobDateLabel         : UILabel!
    @IBOutlet weak var selectDateButton     : UIButton!
    @IBOutlet weak var jobAddressLabel      : UILabel!
    @IBOutlet weak var numOfDaysTF          : UITextField!
    @IBOutlet weak var numOfHourTF          : UITextField!
    @IBOutlet weak var basicPayTF           : UITextField!
    @IBOutlet weak var rateTF               : UITextField!
    @IBOutlet weak var currencyTF           : UITextField!
    @IBOutlet weak var totalBasicPayLabel   : UILabel!
    @IBOutlet weak var tipTF                : UITextField!
    @IBOutlet weak var totalPayLabel        : UILabel!
    @IBOutlet weak var additionalNoteTV     : UITextView!
    @IBOutlet weak var customPaymentDateView: UIView!
    @IBOutlet weak var customPaymentDateTF  : UITextField!
    @IBOutlet weak var paymentDateTF        : UITextField!
    @IBOutlet weak var numOfDaysTitle       : UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var navBarView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var hireBgView: UIView!
    @IBOutlet weak var hireBtn: UIButton!
    
    
    @IBAction func closeTap(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EditPost"), object: nil)
        }
    }
    
    @IBAction func viewJobButtonPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
        nextViewController.postid   = self.postKey
        nextViewController.city     = self.jobCity
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func rateDropDownButtonPressed(_ sender: UIButton) {
    }

    @IBAction func currencyDropDownButtonPressed(_ sender: UIButton) {
    }

    @IBAction func selectDateButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.updateDateLabel(_:)), name: Notification.Name("updateDate"), object: nil)

        self.performSegue(withIdentifier: AppConstant.segueIdentifier_hireFormToCalender, sender: self)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        jobDateLabel.text = ""
        dateplaceholderLabel.isHidden = false
        numOfDaysTF.text = ""
    }
    
    @IBAction func selectJobLocationButtonPressed(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func hireButtonPressed(_ sender: Any) {
       
        if isUpdate{

            // create the alert
            let alert = UIAlertController(title: "Are you sure you want to update \(applicantName)'s hiring details?", message: "", preferredStyle: .alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { action in
                
                if ReachabilityTest.isConnectedToNetwork(){
                    self.hireFunction()
                }else{
                    self.noInternetAlert()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
               
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            // create the alert
            let alert = UIAlertController(title: "Are you sure you want to hire \(applicantName)?", message: "", preferredStyle: .alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Hire", style: UIAlertActionStyle.default, handler: { action in
                
                if ReachabilityTest.isConnectedToNetwork(){
                    self.hireFunction()
                }else{
                    self.noInternetAlert()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
             
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    //MARK:- Variable

    var ownerName           = String()
    var applicantName       = String()
    var applicantUID        = String()
    var applicantImage      = String()
    var jobCity             = String()
    var postKey             = String()
    var finalLatitude       = Double()
    var finalLongitude      = Double()
    var finalJobCity        = String()
    var finalNoOfDays       = Int()
    var isMonthAvailable    = Bool()
    
    
    var ratePickerView          : UIPickerView! = UIPickerView()
    var currencyPickerView      : UIPickerView! = UIPickerView()
    var paymentDatePickerView   : UIPickerView! = UIPickerView()
    
    var dateplaceholderLabel : UILabel!
   
    var newAdditionalNote   = ""
    var ownerUID            = ""
    
    let textViewPlaceHolder = "e.g: Attire / Lunch Time"
    let currencyValues      = ["MYR", "SGD", "CHY", "USD","GBP", "EUR", "NTD", "HKD","INR", "IDR"]
    let rateValues          = ["per hour", "per day", "per month"]
    let rateWithoutMonth    = ["per hour","per day"]
    let paymentDate         = ["On The Spot Cash",
                               "3 Days After Event Finishes",
                               "7 Days After Event Finishes",
                               "14 Days After Event Finishes",
                               "30 Days After Event Finishes",
                               "2 Months After Event Finishes",
                               "3 Months After Event Finishes",
                               "Custom Payment Date"]
    
    //JobDetails
    var jobTitle    = ""
    var jobHirer    = ""
    var jobDesc     = ""
    var jobImage    = ""
    var jobDate     = ""
    var jobWages    = ""
    var jobLocation = ""
    var isUpdate = false
    
    //Firebase DB Reference
    let jobRef                  = Database.database().reference().child("Job")
    let userActivitiesRef       = Database.database().reference().child("UserActivities")
    let userHireNotificationRef = Database.database().reference().child("HireNotification")
    let userAccountRef          = Database.database().reference().child("UserAccount")
    let chatRoom                = Database.database().reference().child("ChatRoom")
    let userChatListRef         = Database.database().reference().child("UserChatList")
    let userPosted              = Database.database().reference().child("UserPosted")
    let userPostedHiredApplicants       = Database.database().reference().child("UserPostedHiredApplicants")
    let userPostedShortlistedApplicants = Database.database().reference().child("UserPostedShortlistedApplicants")

    //MARK:- Override Func

    override func viewDidLoad() {
        super.viewDidLoad()
        pageSetup()
        loadJobDetails()
        
        //Get Owner UID
        ownerUID = (Auth.auth().currentUser?.uid)!
        
        self.hideKeyboardWhenTappedAround()
        
        //TF Delegate
        paymentDateTF.delegate  = self
        basicPayTF.delegate     = self
        
        //Rate Picker View
        self.ratePickerView.delegate            = self
        self.ratePickerView.dataSource          = self
        ratePickerView.showsSelectionIndicator  = true
        ratePickerView.backgroundColor          = UIColor.white
        ratePickerView.translatesAutoresizingMaskIntoConstraints = false
        ratePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        
        //Currency Picker View
        self.currencyPickerView.delegate            = self
        self.currencyPickerView.dataSource          = self
        currencyPickerView.showsSelectionIndicator  = true
        currencyPickerView.backgroundColor          = UIColor.white
        currencyPickerView.translatesAutoresizingMaskIntoConstraints = false
        currencyPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
       
        //Payment Date Picker View
        self.paymentDatePickerView.delegate             = self
        self.paymentDatePickerView.dataSource           = self
        paymentDatePickerView.showsSelectionIndicator   = true
        paymentDatePickerView.backgroundColor           = UIColor.white
        paymentDatePickerView.translatesAutoresizingMaskIntoConstraints = false
        paymentDatePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        
        dateplaceholderLabel = UILabel()
        dateplaceholderLabel.text = "Tap to select dates of hiring"
        dateplaceholderLabel.font = UIFont.italicSystemFont(ofSize: (jobDateLabel.font?.pointSize)!)
        dateplaceholderLabel.sizeToFit()
        jobDateLabel.addSubview(dateplaceholderLabel)
        dateplaceholderLabel.frame.origin = CGPoint(x: 5, y: (jobDateLabel.font?.pointSize)! / 2)
        dateplaceholderLabel.textColor = UIColor.lightGray
        dateplaceholderLabel.isHidden = false
       
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
        
        if isUpdate{
            paymentDateTF.isEnabled     = false
            basicPayTF.isEnabled        = false
            
            paymentDateTF.isUserInteractionEnabled = false
            basicPayTF.isUserInteractionEnabled = false
            
            statusView.isHidden         = false
            navBarView.isHidden         = false
          
            buttonLabel.text            = "UPDATE"
            hireBgView.backgroundColor  = UIColor.init(red: 103/255, green: 184/255, blue: 237/255, alpha: 1.0)
        }else{
            statusView.isHidden         = true
            navBarView.isHidden         = true
            closeBtn.isHidden           = true
            
            buttonLabel.text            = "HIRE"
            hireBgView.backgroundColor  = UIColor.init(red: 98/255, green: 213/255, blue: 87/255, alpha: 1.0)
        }
        
       
    }

    //MARK:- Picker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 && isMonthAvailable{
            return rateValues.count
        }else if pickerView.tag == 1 && !isMonthAvailable{
            return rateWithoutMonth.count
        }else if pickerView.tag == 2{
            return currencyValues.count
        }else{
            return paymentDate.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 && isMonthAvailable{
            return rateValues[row]
        }else if pickerView.tag == 1 && !isMonthAvailable{
            return rateWithoutMonth[row]
        }else if pickerView.tag == 2{
            return currencyValues[row]
        }else{
            return paymentDate[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            if isMonthAvailable{
                print("month")
                rateTF.text = rateValues[row]
            }else{
                print("No month")
                rateTF.text = rateWithoutMonth[row]
            }
            
            /*if jobDateLabel.text != ""{
                daysCalculation(date: jobDateLabel.text!)
            }*/
        }else if pickerView.tag == 2{
            currencyTF.text = currencyValues[row]
        }else{
            paymentDateTF.text = paymentDate[row]
            
        }
    }
    
    //MARK:- Text Field Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        ratePickerView.reloadAllComponents()
        currencyPickerView.reloadAllComponents()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Custom Payment Date
        if textField.tag == 4{
            if textField.text == "Custom Payment Date"{
                customPaymentDateView.isHidden = false
            }else{
                customPaymentDateView.isHidden = true
            }
        }
        
        //Number of Hour
        if textField.tag == 5{
            if textField.text == "per hour"{
                numOfDaysTitle.text = "Num of Days"
                numOfHourTF.backgroundColor = UIColor.white
                numOfHourTF.isUserInteractionEnabled = true
            }else{
                numOfHourTF.backgroundColor = UIColor.lightGray
                numOfHourTF.isUserInteractionEnabled = false
            }
            
            if textField.text == "per month"{
                numOfDaysTitle.text = "Num of Months"
            }
        }
        
        wagesCalculation()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 7 ||
            textField.tag == 8 ||
            textField.tag == 9 ||
            textField.tag == 10{
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 15
        }
        return true
    }
    
    //MARK:- Text View Delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        newAdditionalNote = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text       = textViewPlaceHolder
            textView.textColor  = UIColor.lightGray
            if isUpdate{
                newAdditionalNote     = textViewPlaceHolder
            }else{
                newAdditionalNote     = ""
            }
            
        }else{
            newAdditionalNote = textView.text
        }
        
        print(newAdditionalNote)
    }
    
    
    //MARK:- Google Map Delegates
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
    
    //MARK:- ObjC Func
    @objc func endEditing(){
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 7{
            if let amountString = textField.text?.currencyInputFormatting(){
                textField.text = amountString
            }
        }
    }
    
    @objc func updateDateLabel(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateDate"), object: nil)
        
        if let dateval = notification.userInfo?["labeldate"] as? String {
            if (dateval != "") {
                jobDateLabel.text = dateval
                self.daysCalculation(date: dateval)
                dateplaceholderLabel.isHidden = true
                self.wagesCalculation()
            }
        }
        
        if jobDateLabel.text != ""{
            daysCalculation(date: jobDateLabel.text!)
            self.wagesCalculation()
        }
        ratePickerView.reloadAllComponents()
    }
    
    //MARK:- Functions
    func pageSetup(){
        self.title                      = "Hire Applicants"
        jobImageView.contentMode        = .scaleAspectFill
        customPaymentDateView.isHidden          = true
        numOfDaysTF.isUserInteractionEnabled    = false

        //Text View Placeholder
        additionalNoteTV.text       = textViewPlaceHolder
        additionalNoteTV.textColor  = UIColor.lightGray
        
        //Tag Assign
        ratePickerView.tag          = 1
        currencyPickerView.tag      = 2
        paymentDatePickerView.tag   = 3
        paymentDateTF.tag           = 4
        rateTF.tag                  = 5
        currencyTF.tag              = 6
        basicPayTF.tag              = 7
        numOfDaysTF.tag             = 8
        numOfHourTF.tag             = 9
        tipTF.tag                   = 10
        
        paymentDateTF.delegate      = self
        rateTF.delegate             = self
        currencyTF.delegate         = self
        basicPayTF.delegate         = self
        numOfDaysTF.delegate        = self
        numOfHourTF.delegate        = self
        tipTF.delegate              = self
        additionalNoteTV.delegate   = self
        
        //Set Input to Picker
        rateTF.inputView            = ratePickerView
        currencyTF.inputView        = currencyPickerView
        paymentDateTF.inputView     = paymentDatePickerView

        
        //Create Padding for TF
        let dropDownPadding    = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let dropDownImageView  = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 15, height: 15))
        let dropDownImg        = UIImage(named: "dropdown")
        dropDownImageView.image        = dropDownImg
        dropDownImageView.contentMode  = .scaleAspectFit
        dropDownPadding.addSubview(dropDownImageView)

        paymentDateTF.rightViewMode = UITextFieldViewMode.always
        rateTF.rightViewMode        = UITextFieldViewMode.always
        currencyTF.rightViewMode    = UITextFieldViewMode.always
        paymentDateTF.rightView     = dropDownPadding
        
        //Set default picker selection
        ratePickerView.selectRow(0, inComponent: 0, animated: true)
        currencyPickerView.selectRow(0, inComponent: 0, animated: true)
        paymentDatePickerView.selectRow(0, inComponent: 0, animated: true)
        
        rateTF.text         = rateValues[0]
        currencyTF.text     = currencyValues[0]
        paymentDateTF.text  = paymentDate[0]
        
        //Add Observer on Amount TF
        basicPayTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)

        
    }
    
    func loadJobDetails(){
        
        jobRef.child(jobCity).child(postKey).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("\n============== Loaded Job Details ==========")
                print(snapshot)
                
                self.jobTitle = snapshot.childSnapshot(forPath: "title").value as! String
                self.jobHirer = snapshot.childSnapshot(forPath: "company").value as! String
                self.jobDesc  = snapshot.childSnapshot(forPath: "desc").value as! String
                self.jobImage = snapshot.childSnapshot(forPath: "postimage").value as! String
                
                if self.jobImage != ""{
                  
                    self.jobImageView.sd_setImage(with: URL(string: self.jobImage), completed: { (image, error, cacheType, URL) in
                        if error != nil{
                            self.jobImageView.image = UIImage(named: "profilebg3")
                        }
                    })
                }else{
                    self.jobImageView.image = UIImage(named: "profilebg3")
                }
                
                if !self.isUpdate{
                    //Pending update value if else statement
                    self.jobDate        = snapshot.childSnapshot(forPath: "date").value as! String
                    self.jobWages       = snapshot.childSnapshot(forPath: "wages").value as! String
                    self.jobLocation    = snapshot.childSnapshot(forPath: "fulladdress").value as! String
                    
                    if (self.jobWages != "none"){
                        print(self.jobWages)
                        self.wagesSeperator(wages: self.jobWages)
                    }
                    
                    if (self.jobDate != "none"){
                        self.jobDateLabel.text = self.jobDate
                        self.dateplaceholderLabel.isHidden = true
                    }
                    else {
                        self.dateplaceholderLabel.isHidden = false
                    }
                    
                    self.jobAddressLabel.text   = self.jobLocation
                    //                    self.wagesCalculation()
                }else{
                    self.loadHiredDetails()
                }
                
                //Set Data To Label
                self.jobTitleLabel.text     = self.jobTitle
                self.hirerNameLabel.text    = self.jobHirer
                self.jobDescLabel.text      = self.jobDesc
                self.daysCalculation(date: self.jobDate)
            }
        }
    }
    
    func loadHiredDetails(){
        userPostedHiredApplicants.child(ownerUID).child(postKey).child(applicantUID).observe(.value) { (snapshot) in
            print("\n============\nHired Details\n============")
            print(snapshot)
            
            if snapshot.hasChild("date"){
                self.jobDateLabel.text = snapshot.childSnapshot(forPath: "date").value as? String
                self.dateplaceholderLabel.isHidden = true
            }
            if snapshot.hasChild("location"){
                self.jobAddressLabel.text = snapshot.childSnapshot(forPath: "location").value as? String
            }
            if snapshot.hasChild("numdates"){
                self.numOfDaysTF.text = snapshot.childSnapshot(forPath: "numdates").value as? String
            }
            if snapshot.hasChild("basicpay"){
                self.basicPayTF.text = snapshot.childSnapshot(forPath: "basicpay").value as? String
            }
            if snapshot.hasChild("basictotalpay"){
                self.totalBasicPayLabel.text = snapshot.childSnapshot(forPath: "basictotalpay").value as? String
            }
            if snapshot.hasChild("totalallpay"){
                self.totalPayLabel.text = snapshot.childSnapshot(forPath: "totalallpay").value as? String
            }
            if snapshot.hasChild("paymentdate"){
                self.paymentDateTF.text = snapshot.childSnapshot(forPath: "paymentdate").value as? String
            }
            if snapshot.hasChild("numhours"){
                self.numOfHourTF.text = snapshot.childSnapshot(forPath: "numhours").value as? String
            }
            if snapshot.hasChild("spinnercurrency"){
                self.currencyTF.text = snapshot.childSnapshot(forPath: "spinnercurrency").value as? String
            }
            if snapshot.hasChild("spinnerrate"){
                if snapshot.childSnapshot(forPath: "spinnerrate").value as? String != "per hour"{
                    
                    self.numOfHourTF.backgroundColor = UIColor.lightGray
                    self.numOfHourTF.isUserInteractionEnabled = false
                }
                self.rateTF.text    = snapshot.childSnapshot(forPath: "spinnerrate").value as? String
            }
            if snapshot.hasChild("tipspay"){
                self.tipTF.text = snapshot.childSnapshot(forPath: "tipspay").value as? String
            }
            if snapshot.hasChild("additionalnote"){
                self.additionalNoteTV.text = snapshot.childSnapshot(forPath: "additionalnote").value as? String
                self.additionalNoteTV.textColor = UIColor.black
            }
            if snapshot.hasChild("paymentdate"){
                self.paymentDateTF.text = snapshot.childSnapshot(forPath: "paymentdate").value as? String
            }
            
        }
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
                self.finalJobCity = pm.administrativeArea!
                
                if (fulladdress.contains("Pulau Pinang") || fulladdress.contains("Penang")){
                    self.finalJobCity = "Penang"
                }
                else if (fulladdress.contains("Kuala Lumpur")){
                    self.finalJobCity = "Kuala Lumpur"
                }
                else if (fulladdress.contains("Labuan")){
                    self.finalJobCity = "Labuan"
                }
                else if (fulladdress.contains("Putrajaya")){
                    self.finalJobCity = "Putrajaya"
                }
                else if (fulladdress.contains("Johor")){
                    self.finalJobCity = "Johor"
                }
                else if (fulladdress.contains("Kelantan")){
                    self.finalJobCity = "Kelantan"
                }
                else if (fulladdress.contains("Melaka") || fulladdress.contains("Melacca")){
                    self.finalJobCity = "Melacca"
                }
                else if (fulladdress.contains("Negeri Sembilan") || fulladdress.contains("Seremban")){
                    self.finalJobCity = "Negeri Sembilan"
                }
                else if (fulladdress.contains("Pahang")){
                    self.finalJobCity = "Pahang"
                }
                else if (fulladdress.contains("Perak") || fulladdress.contains("Ipoh")){
                    self.finalJobCity = "Perak"
                }
                else if (fulladdress.contains("Perlis")){
                    self.finalJobCity = "Perlis"
                }
                else if (fulladdress.contains("Sabah")){
                    self.finalJobCity = "Sabah"
                }
                else if (fulladdress.contains("Sarawak")){
                    self.finalJobCity = "Sarawak"
                }
                else if (fulladdress.contains("Selangor") || fulladdress.contains("Shah Alam") || fulladdress.contains("Klang")){
                    self.finalJobCity = "Selangor"
                }
                else if (fulladdress.contains("Terengganu")){
                    self.finalJobCity = "Terengganu"
                }
                else if (fulladdress.contains("Limerick")){
                    self.finalJobCity = "County Limerick"
                }
                
                if (fulladdress == "" && (pm.locality != nil || pm.administrativeArea != nil)){
                    if (pm.locality == nil){
                        self.jobAddressLabel.text = placename + ", " + pm.administrativeArea!
                    }
                    else{
                        self.jobAddressLabel.text = placename + pm.locality! + ", " + pm.administrativeArea!
                    }
                }
                else if (fulladdress != "") {
                    self.jobAddressLabel.text = placename + ", " + fulladdress
                }
                else{
                    self.jobAddressLabel.text = "Address not found"
                }
                
            }
        }
    }
    
    func daysCalculation(date: String){
        if date.contains("/"){
            let days = date.components(separatedBy: " / ")
            finalNoOfDays = days.count
            print("\n[/]NO OF DAYS: \(days.count)")

            if finalNoOfDays >= 28 {
                isMonthAvailable = true
            }else{
                isMonthAvailable = false
            }
            
        }else if date.contains("to"){
            let days            = date.components(separatedBy: " to ")
            let startDateString = days[0]
            let endDateString   = days[1]
            
            print("Start Date: \(startDateString)")
            print("End Date: \(endDateString)")
            
            let dateFormatter   = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy"
            
            let startDate   = dateFormatter.date(from: startDateString)!
            let endDate     = dateFormatter.date(from: endDateString)!
            let cal         = NSCalendar.current
            
            if rateTF.text == "per month"{
                let unit : Set<Calendar.Component> =  [.month]
                
                let monthBetween = (cal.dateComponents(unit, from: startDate, to: endDate).month)! + 1
                
                print("\nNO OF MONTH: \(monthBetween)")
                finalNoOfDays = monthBetween
            }else{
                let unit : Set<Calendar.Component> =  [.day]
                
                let daysBetween = (cal.dateComponents(unit, from: startDate, to: endDate).day)! + 1
                
                print("\nNO OF DAYS: \(daysBetween)")
                
                if finalNoOfDays >= 28 {
                    isMonthAvailable = true
                }else{
                    isMonthAvailable = false
                }
                
                finalNoOfDays = daysBetween
            }
            
        }else{
            //Single Date
            finalNoOfDays = 1
        }

        numOfDaysTF.text = String(finalNoOfDays)
        ratePickerView.reloadAllComponents()
    }

    func wagesCalculation(){
        
        var days        = Double()
        var hours       = Double()
        var basics      = Double()
        var totalBasic  = Double()
        var totalPay    = Double()
        
        //per Hour Calculation
        if !(numOfDaysTF.text?.isEmpty)! &&
            !(numOfHourTF.text?.isEmpty)! &&
            !(basicPayTF.text?.isEmpty)! &&
            (rateTF.text == "per hour"){
            
            days    = Double(numOfDaysTF.text!)!
            hours   = Double(numOfHourTF.text!)!
            basics  = Double(basicPayTF.text!)!
            
            totalBasic = (basics * hours) * days
            
        }else if(!(numOfDaysTF.text?.isEmpty)! &&       //per Day/Month Calculation
            !(basicPayTF.text?.isEmpty)! ){
            
            days    = Double(numOfDaysTF.text!)!
            basics  = Double(basicPayTF.text!)!
            
            totalBasic = basics * days

        }
        print("Total Basic: \(totalBasic)")

        if tipTF.text != ""{
            totalPay = totalBasic + Double(tipTF.text!)!
        }else{
            totalPay = totalBasic
        }
        
        print("Total Pay: \(totalPay)")
    
        totalBasicPayLabel.text = String(format: "%.2f",totalBasic)
        totalPayLabel.text      = String(format: "%.2f",totalPay)
    }
    
    func increamentHiredApplicants(){
        
        userPosted.child(ownerUID).child(postKey).child("totalhiredcount").runTransactionBlock { (currentData) -> TransactionResult in
            if var data = currentData.value as? [String:Any]{
                if var previousCount = data["totalhiredcount"] as? Int{
                    data["totalhiredcount"] = previousCount+=1
                    currentData.value = data
                }else{
                    data["totalhiredcount"] = 1
                    currentData.value = data
                }
            }
            return TransactionResult.success(withValue: currentData)
        }

    }
    
    func wagesSeperator(wages: String){
        
        let seperated   = wages.components(separatedBy: " per ") //[MYR 100.00], [day]
        let seperated2  = seperated[0].components(separatedBy: " ")//[MYR] [100.00]
        let rate        = seperated[1]
        
        currencyTF.text = seperated2[0]
        basicPayTF.text = seperated2[1]
        rateTF.text     = "per \(rate)"
        
        if rate != "hour"{
            numOfHourTF.backgroundColor = UIColor.lightGray
            numOfHourTF.isUserInteractionEnabled = false
            
        }
        
        DispatchQueue.main.async {
            self.wagesCalculation()
            
        }
        
    }
    
    
    func hireFunction(){
        
        if rateTF.text == "per hour"{
            if numOfDaysTF.text == ""{
                DispatchQueue.main.async {
                    
                    self.stopAnimating()
                    self.showAlertBox(title: "Please enter number of days for this job.", msg: "", buttonString: "Ok")
                }
                return
            }else if numOfHourTF.text == ""{
                DispatchQueue.main.async {
                    
                    self.stopAnimating()
                    self.showAlertBox(title: "Please enter number of working hours per day for this job.", msg: "", buttonString: "Ok")
                }
                return
            }
        }
        
        if (jobDateLabel.text       != "" &&
            jobAddressLabel.text    != "" &&
            numOfDaysTF.text        != "" &&
            basicPayTF.text         != "" &&
            rateTF.text             != "" &&
            currencyTF.text         != "" &&
            paymentDateTF.text      != "" &&
            totalPayLabel.text      != "" &&
            totalBasicPayLabel.text != ""
            ){

            self.startAnimating(CGSize(width: 40, height: 40),
                                type: NVActivityIndicatorType(rawValue: 17),
                                color: UIColor.init(red: 103/255, green: 184/255, blue: 237/255, alpha: 1.0),
                                backgroundColor: UIColor.black.withAlphaComponent(0.8),
                                textColor: .white)
            
            let finalJobDate        = jobDateLabel.text!
            let finalJobAddress     = jobAddressLabel.text!
            let finalTotalPay       = totalPayLabel.text!
            let finalBasicTotalPay  = totalBasicPayLabel.text!
            let finalBasicPay       = basicPayTF.text!
            let finalNumDates       = numOfDaysTF.text!
            let finalRate           = rateTF.text!
            let finalCurrency       = currencyTF.text!
            let finalNumOfHours     = numOfHourTF.text!
            
            var lastDate            = ""
            var finalPaymentDate    = ""
            
            if paymentDateTF.text == "Custom Payment Date"{
                finalPaymentDate = "\(customPaymentDateTF.text!) After Event Finishes"
            }else{
                finalPaymentDate = paymentDateTF.text!
            }
            
            if (finalJobDate.contains(" / ")){
                let seperated = finalJobDate.components(separatedBy: " / ")
                lastDate = seperated[seperated.count - 1]
            }else if (finalJobDate.contains(" to ")){
                let seperated = finalJobDate.components(separatedBy: " to ")
                lastDate = seperated[1]
            }else{
                lastDate = finalJobDate
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yy"
            let enddate = formatter.date(from: lastDate)
            let datenow = Date()
            
            if(!isUpdate && enddate! < datenow){
                showAlertBox(title: "Invalid Dates", msg: "Hiring Dates must be from today onwards.", buttonString: "Ok")
                DispatchQueue.main.async {
                    self.stopAnimating()
                    
                }
            }else{
            
            userActivitiesRef.child(applicantUID).child("Applied").child(postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    self.userActivitiesRef.child(self.applicantUID).child("NewMainNotification").setValue("true")
                    self.userActivitiesRef.child(self.applicantUID).child("NewApplied").setValue("true")
                    self.userActivitiesRef.child(self.applicantUID).child("Applied").child(self.postKey).child("pressed").setValue("false")
                    self.userActivitiesRef.child(self.applicantUID).child("Applied").child(self.postKey).child("date").setValue(finalJobDate)
                    
                    if self.isUpdate{
                        self.userActivitiesRef.child(self.applicantUID).child("Applied").child(self.postKey).child("status").setValue("changedoffer")
                    }else{
                        self.userActivitiesRef.child(self.applicantUID).child("Applied").child(self.postKey).child("status").setValue("pendingoffer");
                        let newHireNotification = self.userHireNotificationRef.child("Hire").childByAutoId()
                        let hireNotificationKey = newHireNotification.key
                        
                        var notificationData = [String:Any]()
                        notificationData["ownerUid"]        = self.ownerUID
                        notificationData["receiverUid"]     = self.applicantUID
                        notificationData["ownerName"]       = self.ownerName
                        
                        newHireNotification.setValue(notificationData)
                        
                        self.userActivitiesRef.child(self.applicantUID).child("HiredNotification").child(hireNotificationKey).setValue(hireNotificationKey)
                        
                    }
                }
            }) { (error) in
                
                    if error.localizedDescription != ""{
                        self.showAlertBox(title: "Error", msg: "System encountered some error while Hiring.", buttonString: "Ok")
                    }
                }
                
                
            
            var hiredData = [String:Any]()
            
                if self.applicantImage != "" {
                    hiredData["image"]          =   self.applicantImage
                }
                
                if self.applicantName != "" {
                    hiredData["name"]           =   self.applicantName
                }
            
            
            hiredData["location"]       =   finalJobAddress
            hiredData["paymentdate"]    =   finalPaymentDate
            hiredData["totalallpay"]    =   finalTotalPay
            hiredData["basictotalpay"]  =   finalBasicTotalPay
            hiredData["basicpay"]       =   finalBasicPay
            hiredData["numdates"]       =   finalNumDates
            hiredData["date"]           =   finalJobDate
            hiredData["spinnerrate"]    =   finalRate
            hiredData["spinnercurrency"]   = finalCurrency
            hiredData["offerstatus"]    =   "pending"
            
            if finalRate == "per hour"{
                hiredData["numhours"] = finalNumOfHours
            }else{
                userPostedHiredApplicants.child((self.ownerUID)).child(self.postKey).child(self.applicantUID).child("numhours").removeValue()
            }
            
            if tipTF.text != "" {
                hiredData["tipspay"] = tipTF.text!
            }
            
            if additionalNoteTV.text != textViewPlaceHolder{
                hiredData["additionalnote"] = additionalNoteTV.text!
            }
                
            if isUpdate{
                hiredData["time"]           =   ServerValue.timestamp()

                userPostedHiredApplicants.child((self.ownerUID)).child(self.postKey).child(self.applicantUID).updateChildValues(hiredData) { (error, ref) in
                    if error == nil{
                        self.stopAnimating()
                        DispatchQueue.main.async {
                            
                            
                            // create the alert
                            let alert = UIAlertController(title: "Update Successful", message: "", preferredStyle: .alert)
                            
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { action in
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                       
                    }
                }
            }else{
                
                let tsLong: Int64 = Int64(Utilities.getCurrentMillis())
                hiredData["negatedtime"] = -1 * tsLong
                hiredData["time"]           =   ServerValue.timestamp()
                
                //increament hired applicants
                self.increamentHiredApplicants()
                self.userPostedHiredApplicants.child((self.ownerUID)).child(self.postKey).child(self.applicantUID).setValue(hiredData) { (error, ref) in
                    if error == nil{
                        
                        //Remove user from UserPostedShortlistedApplicants List
                        self.userPostedShortlistedApplicants.child((self.ownerUID)).child(self.postKey).child(self.applicantUID).removeValue(completionBlock: { (error, ref) in
                            if error != nil{
                                
                                //Retry One More Time
                                self.userPostedShortlistedApplicants.child((self.ownerUID)).child(self.postKey).child(self.applicantUID).removeValue()
                                self.stopAnimating()
                                if self.isUpdate{
                                    // create the alert
                                    let alert = UIAlertController(title: "Update Successful", message: "", preferredStyle: .alert)
                                    
                                    
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { action in
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    }))
                                    
                                    // show the alert
                                    self.present(alert, animated: true, completion: {
                                        NotificationCenter.default.post(name: Notification.Name("EditPost"), object: nil, userInfo: nil)
                                    })
                                    
                                }else{
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }else{
                                if self.isUpdate{
                                    self.stopAnimating()
                                    DispatchQueue.main.async {
                                        // create the alert
                                        let alert = UIAlertController(title: "Update Successful", message: "", preferredStyle: .alert)
                                        
                                        
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { action in
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            
                                        }))
                                        
                                        // show the alert
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }else{
                                    self.stopAnimating()
                                    self.navigationController?.popViewController(animated: true)
                                    NotificationCenter.default.post(name: Notification.Name("updateStatus"), object: nil, userInfo: nil)
                                }
                                
                            }
                        })
                    }else{
                        self.stopAnimating()
                        
                        DispatchQueue.main.async {
                            self.showAlertBox(title: "Error", msg: "Hired failed.\nPlease try again", buttonString: "Ok")
                        }
                    }
                    
                    let ownerChat = self.chatRoom.child(self.ownerUID)
                    let receiverChat = self.chatRoom.child(self.applicantUID)
                    let newReceiverChat = receiverChat.child("\(self.applicantUID)_\(self.ownerUID)").child("ChatList").childByAutoId()
                    let newChatListKey = newReceiverChat.key
                    let newOwnerChat = ownerChat.child("\(self.ownerUID)_\(self.applicantUID)").child("ChatList").child(newChatListKey)
                    
                    var actionChatData = [String:Any]()
                    
                    actionChatData["negatedtime"] = -1 * tsLong
                    actionChatData["time"]        = ServerValue.timestamp()
                    actionChatData["actiontitle"] = "hired"
                    actionChatData["ownerid"]     = self.ownerUID
                    actionChatData["jobtitle"]    = self.jobTitle
                    actionChatData["jobdescrip"]  = self.jobDesc
                    actionChatData["city"]        = self.jobCity
                    actionChatData["postkey"]     = self.postKey
                    
                    self.userChatListRef.child(self.ownerUID).child("UserList").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            if snapshot.hasChild(self.applicantUID){
                                actionChatData["oldtime"] = snapshot.childSnapshot(forPath: self.applicantUID).childSnapshot(forPath: "time").value
                                
                                newOwnerChat.setValue(actionChatData)
                                newReceiverChat.setValue(actionChatData)
                            }else{
                                actionChatData["oldtime"] = 0
                                newOwnerChat.setValue(actionChatData)
                                newReceiverChat.setValue(actionChatData)
                            }
                        }else{
                            newOwnerChat.setValue(actionChatData)
                            newReceiverChat.setValue(actionChatData)
                        }
                        
                    }, withCancel: { (error) in
                        if error.localizedDescription != ""{
                            print("[ActionChatData] : \(error.localizedDescription)")
                        }
                    })
                }
            }
            }
        }else{
            //Found field empty
            if jobDateLabel.text == ""{
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.showAlertBox(title: "Please select job dates", msg: "", buttonString: "Ok")
                }
            }
            else if jobAddressLabel.text == ""{
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.showAlertBox(title: "Please select job location", msg: "", buttonString: "Ok")
                }
            }
            else if basicPayTF.text == ""{
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.showAlertBox(title: "Please enter basic pay amount", msg: "", buttonString: "Ok")
                }
            }
            else if paymentDateTF.text == ""{
                DispatchQueue.main.async {

                    self.stopAnimating()
                    self.showAlertBox(title: "Please select payment date", msg: "", buttonString: "Ok")
                }
            }
            
            else if rateTF.text == "per day"{
                if numOfDaysTF.text == ""{
                    DispatchQueue.main.async {

                        self.stopAnimating()
                        self.showAlertBox(title: "Please enter number of days for this job.", msg: "", buttonString: "Ok")
                    }
                }
            }else if rateTF.text == "per hour"{
                if numOfDaysTF.text == ""{
                    DispatchQueue.main.async {

                        self.stopAnimating()
                        self.showAlertBox(title: "Please enter number of days for this job.", msg: "", buttonString: "Ok")
                    }
                }else if numOfHourTF.text == ""{
                    DispatchQueue.main.async {

                        self.stopAnimating()
                        self.showAlertBox(title: "Please enter number of working hours per day for this job.", msg: "", buttonString: "Ok")
                    }
                }
            }else if rateTF.text == "per month"{
                if numOfDaysTF.text == ""{
                    DispatchQueue.main.async {
                        self.stopAnimating()
                        self.showAlertBox(title: "Please enter number of month for this job.", msg: "", buttonString: "Ok")
                    }
                }
            }
            
//            stopAnimating()
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
