//
//  VerificationAlert.swift
//  JobIn24
//
//  Created by MacUser on 29/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase

class VerificationAlert: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
 

    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var phonenumbertxtField: UITextField!
    
    @IBOutlet weak var countrycodetxtField: UITextField!
    
    var delegate: VerificationAlertDelegate?
    
    let picker_values = ["MYR (+60)", "SGD (+64)", "IRE (+353)"]
    
    var selectedCodeString: String!
    var selectedCode: String!
   
    var myPicker: UIPickerView! = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        return picker_values.count

    }
    
    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
        return picker_values[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Your Function

        self.selectedCodeString = picker_values[row]
        
        if row == 0{
            self.selectedCode = "+60"
        }
        else if row == 1{
            self.selectedCode = "+64"
        }
        else if row == 2{
            self.selectedCode = "+353"
        }

    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countrycodetxtField.inputAccessoryView = UIView()
       
        self.myPicker = UIPickerView(frame: CGRect(x:0, y:40, width:0, height:0))
        
        self.countrycodetxtField.delegate = self
       
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
      

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        phonenumbertxtField.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextTap(_ sender: Any) {
        
        if countrycodetxtField.text == nil || countrycodetxtField.text == "" {
            self.view.makeToast("Country Code cannot be left empty", duration: 2.0, position: .center)
        }
        else if phonenumbertxtField.text == nil || phonenumbertxtField.text == "" {
            self.view.makeToast("Phone number cannot be left empty", duration: 2.0, position: .center)
        }
        else {
            let userphonenum = self.selectedCode + phonenumbertxtField.text!
            phonenumbertxtField.resignFirstResponder()
            delegate?.okButtonTapped(textFieldValue: userphonenum)
            self.dismiss(animated: true, completion: nil)
        }
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deanimateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func deanimateView() {
        alertView.alpha = 1.0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        })
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func countrycodeTap(_ sender: UITextField) {
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
        doneButton.addTarget(self, action: #selector(doneRateButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(cancelRatePicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    
    @objc func cancelRatePicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.countrycodetxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneRateButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.countrycodetxtField.text = self.selectedCodeString
        self.countrycodetxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }

}


