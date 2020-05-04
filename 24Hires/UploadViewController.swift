//
//  UploadViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/27/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Koyomi

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var selectImage: UIButton!
    
    @IBOutlet weak var uploadBtn: UIBarButtonItem!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBOutlet weak var deleteDateBtn: UIButton!
    
    @IBOutlet weak var titleTextField: UITextView!
    
    @IBOutlet weak var descripTextField: UITextView!
    
    @IBOutlet weak var categoryTextField: UITextView!
    
    @IBOutlet weak var companyTextField: UITextView!
    
    @IBOutlet weak var locationTextField: UITextView!
  
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var currencyTextField: UITextField!
    
    @IBOutlet weak var WagesTextField: UITextField!
    
    @IBOutlet weak var CoinsTextField: UITextField!
    
    @IBOutlet weak var rateTextField: UITextField!
    
    var selectedCurrency: String!
    var selectedRate: String!
    
    let picker_values = ["MYR", "SGD", "CHY", "USD","GBP", "EUR", "NTD", "HKD","INR", "IDR"]
    let rate_values = ["per hour", "per day", "per month"]
    var myPicker: UIPickerView! = UIPickerView()
    var myPicker2: UIPickerView! = UIPickerView()
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.hideKeyboardWhenTappedAround()
        
        self.currencyTextField.inputAccessoryView = UIView()
        self.rateTextField.inputAccessoryView = UIView()
        
        picker.delegate = self
        
        self.myPicker = UIPickerView(frame: CGRect(x:0, y:40, width:0, height:0))
        self.currencyTextField.delegate = self
        self.rateTextField.delegate = self
        self.dateTextField.delegate = self
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        self.myPicker.tag = 1
        self.myPicker2.delegate = self
        self.myPicker2.dataSource = self
        self.myPicker2.tag = 2
        
        deleteDateBtn.imageEdgeInsets = UIEdgeInsets(top:10,left:10, bottom:10, right:10)
        
        selectImage.imageEdgeInsets = UIEdgeInsets(top:13,left:13, bottom:13, right:13)
        selectImage.backgroundColor = .clear
        selectImage.layer.cornerRadius = selectImage.layer.bounds.size.width/2
        selectImage.layer.borderWidth = 2
        selectImage.layer.borderColor = UIColor.white.cgColor
        
        titleTextField.layer.cornerRadius = 7
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        descripTextField.layer.cornerRadius = 7
        descripTextField.layer.borderWidth = 1
        descripTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        categoryTextField.layer.cornerRadius = 7
        categoryTextField.layer.borderWidth = 1
        categoryTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        companyTextField.layer.cornerRadius = 7
        companyTextField.layer.borderWidth = 1
        companyTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        locationTextField.layer.cornerRadius = 7
        locationTextField.layer.borderWidth = 1
        locationTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        WagesTextField.layer.cornerRadius = 7
        WagesTextField.layer.borderWidth = 1
        WagesTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        CoinsTextField.layer.cornerRadius = 7
        CoinsTextField.layer.borderWidth = 1
        CoinsTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        rateTextField.layer.cornerRadius = 7
        rateTextField.layer.borderWidth = 1
        rateTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        currencyTextField.layer.cornerRadius = 7
        currencyTextField.layer.borderWidth = 1
        currencyTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        dateTextField.layer.cornerRadius = 7
        dateTextField.layer.borderWidth = 1
        dateTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
    }
    
    //MARK: - Delegates and data sources
    
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
        print("Hello")
        
        
        if (pickerView.tag == 1){
            self.selectedCurrency = picker_values[row]
        }else{
            self.selectedRate = rate_values[row]
        }
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            self.previewImage.image = image
            selectImage.isHidden = true
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func dismiss_onClick(_ sender: Any) {
        
        //navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func selectPressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
      
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        
        print("insided")
        
        AppDelegate.instance().showActivityIndicator()
        
        let jobref = Database.database().reference()
        
        let uid = Auth.auth().currentUser!.uid
        
        let storage = Storage.storage().reference()
        
        let postkey = jobref.child("Job").childByAutoId().key
        let imageRef = storage.child("JobPhotos").child("\(postkey).jpg")
        
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil{
                print(error!.localizedDescription)
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
                
            
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url{
                    let feed = ["userID" : uid,
                                "postImage" : url.absoluteString,
                                "postID" : postkey] as[String : Any]
                    
                    print("downloadurl")
                    
                    let postFeed = ["\(postkey)" : feed]
                    
                    jobref.child("Job").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicator()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            })
            
        }
        
       uploadTask.resume()
        
    }
    
    @IBAction func currencyPressed(_ sender: Any) {
        self.currencyTextField.becomeFirstResponder()
    }
    
    func cancelPicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencyTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    func doneButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencyTextField.text = self.selectedCurrency
        self.currencyTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    
    @IBAction func currencyTxtFieldPressed(_ sender: UITextField) {
        
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
        doneButton.addTarget(self, action: Selector(("doneButton:")), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: Selector(("cancelPicker:")), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
      
    }
    
    @IBAction func ratePressed(_ sender: UIButton) {
        self.rateTextField.becomeFirstResponder()
    }
    
    func cancelRatePicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.rateTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    func doneRateButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.rateTextField.text = self.selectedRate
        self.rateTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    
    @IBAction func rateTxtFieldPressed(_ sender: UITextField) {
        
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        myPicker2.tintColor = tintColor
        myPicker2.center.x = inputView.center.x
        inputView.addSubview(myPicker2) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: Selector(("doneRateButton:")), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: Selector(("cancelRatePicker:")), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
        
    }
    
    @IBAction func datePressed(_ sender: UIButton) {
        let destinationVC = CalendarViewController()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        
        self.present(nextViewController, animated:true, completion:nil)
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
