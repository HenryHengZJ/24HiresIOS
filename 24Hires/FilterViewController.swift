//
//  FilterViewController.swift
//  JobIn24
//
//  Created by MacUser on 25/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import BEMCheckBox
import FirebaseAuth
import FirebaseDatabase

class FilterViewController: UIViewController, BEMCheckBoxDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var showAllChkBox: BEMCheckBox!
    
    @IBOutlet weak var wagesrangeChkBox: BEMCheckBox!
    
    @IBOutlet weak var specificRangeView1: UIView!
    
    @IBOutlet weak var specificRangeView2: UIView!
    
    @IBOutlet weak var startDateTxtField: UITextField!
    
    @IBOutlet weak var endDateTxtField: UITextField!
    
    @IBOutlet weak var ratetxtField: UITextField!
    
    @IBOutlet weak var currencytxtField: UITextField!
    
    @IBOutlet weak var wagesrangeLabel: UILabel!
    
    @IBOutlet weak var enddateremoveBtn: UIButton!
    
    @IBOutlet weak var startdateremoveBtn: UIButton!
    
    var mydatePicker: UIDatePicker! = UIDatePicker()
    
    var selectedCurrency = "MYR"
    var selectedRate = "per hour"
    
    var selectedCurrencyRow = 0
    var selectedRateRow = 0
    
    var wagesIndex = 0
    var filterbywages = 1111
    var filterbystart = ""
    var filterbyend = ""
    var oldfilterbywages = "true"
    var wagescategory = 0
    
    var scenario = 0
    
    var startdateFromString: Date!
    var enddateFromString: Date!
    var enddateAsString: String!
    var startdateAsString: String!

    let picker_values = ["MYR", "SGD", "CHY", "USD","GBP", "EUR", "NTD", "HKD","INR", "IDR"]
    let rate_values = ["per hour", "per day", "per month"]
    var myPicker: UIPickerView! = UIPickerView()
    var myPicker2: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var wagesrangeSlider: UISlider!
    
    
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
            selectedCurrencyRow = row
            
        }else{
            self.selectedRate = rate_values[row]
            selectedRateRow = row
           
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startDateTxtField.inputAccessoryView = UIView()
        self.endDateTxtField.inputAccessoryView = UIView()
        
        self.currencytxtField.inputAccessoryView = UIView()
        self.ratetxtField.inputAccessoryView = UIView()
        
        self.startDateTxtField.delegate = self
        self.endDateTxtField.delegate = self
        
        self.currencytxtField.delegate = self
        self.ratetxtField.delegate = self
        
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        self.myPicker.tag = 1
        
        self.myPicker2.delegate = self
        self.myPicker2.dataSource = self
        self.myPicker2.tag = 2

        self.mydatePicker = UIDatePicker(frame: CGRect(x:0, y:40, width:0, height:0))
        
        self.mydatePicker.datePickerMode = .date
        
        startdateFromString = Date()
        enddateFromString = Date()
      
        showAllChkBox.delegate = self
        showAllChkBox.tag = 1
        
        wagesrangeChkBox.tag = 2
        wagesrangeChkBox.delegate = self

        wagesrangeSlider.addTarget(self, action: #selector(FilterViewController.updateSliderLabel(sender:)), for: .allEvents)
        
        if (oldfilterbywages == "true") {
            specificRangeView2.alpha = 0.5
            specificRangeView2.isUserInteractionEnabled = false
            wagesrangeChkBox.setOn(false, animated: true)
            showAllChkBox.setOn(true, animated: true)
        }
        else {
            specificRangeView2.alpha = 1
            specificRangeView2.isUserInteractionEnabled = true
            wagesrangeChkBox.setOn(true, animated: true)
            showAllChkBox.setOn(false, animated: true)
        }
        
        print("xxfilterbywages = \(filterbywages)")
        print("xxfilterbystart = \(filterbystart)")
        print("xxfilterbyend = \(filterbyend)")
        print("xxoldfilterbywages = \(oldfilterbywages)")
        
        if (filterbywages != 0) {
            
            // get rate
            
            let newwagescategory = filterbywages % 100
            
            if (newwagescategory == 11) {
                setRateValue(rateRow:0, wagesText:"Less than 5", sliderVal: 0.0, wagescategoryVal:11)
            }
            else if (newwagescategory == 12) {
                setRateValue(rateRow:0, wagesText:"5 to 10", sliderVal: 1.0, wagescategoryVal:12)
            }
            else if (newwagescategory == 13) {
                setRateValue(rateRow:0, wagesText:"11 to 20", sliderVal: 2.0, wagescategoryVal:13)
            }
            else if (newwagescategory == 14) {
                setRateValue(rateRow:0, wagesText:"21 to 50", sliderVal: 3.0, wagescategoryVal:14)
            }
            else if (newwagescategory == 15) {
                setRateValue(rateRow:0, wagesText:"More than 50", sliderVal: 4.0, wagescategoryVal:15)
            }
            else if (newwagescategory == 21) {
                setRateValue(rateRow:1, wagesText:"Less than 70", sliderVal: 0.0, wagescategoryVal:21)
            }
            else if (newwagescategory == 22) {
                setRateValue(rateRow:1, wagesText:"70 to 100", sliderVal: 1.0, wagescategoryVal:22)
            }
            else if (newwagescategory == 23) {
                setRateValue(rateRow:1, wagesText:"101 to 200", sliderVal: 2.0, wagescategoryVal:23)
            }
            else if (newwagescategory == 24) {
                setRateValue(rateRow:1, wagesText:"201 to 500", sliderVal: 3.0, wagescategoryVal:24)
            }
            else if (newwagescategory == 25) {
                setRateValue(rateRow:1, wagesText:"More than 500", sliderVal: 4.0, wagescategoryVal:25)
            }
            else if (newwagescategory == 31) {
                setRateValue(rateRow:2, wagesText:"Less than 1000", sliderVal: 0.0, wagescategoryVal:31)
            }
            else if (newwagescategory == 32) {
                setRateValue(rateRow:2, wagesText:"1000 to 1500", sliderVal: 1.0, wagescategoryVal:32)
            }
            else if (newwagescategory == 33) {
                setRateValue(rateRow:2, wagesText:"1500 to 2000", sliderVal: 2.0, wagescategoryVal:33)
            }
            else if (newwagescategory == 34) {
                setRateValue(rateRow:2, wagesText:"2000 to 5000", sliderVal: 3.0, wagescategoryVal:34)
            }
            else if (newwagescategory == 12) {
                setRateValue(rateRow:2, wagesText:"More than 5000", sliderVal: 4.0, wagescategoryVal:35)
            }
            
            //get currency
            let intwages = Int(filterbywages % 100000)
            let stringintwages = String(intwages)
            let index = stringintwages.index(stringintwages.startIndex, offsetBy: 2)
            let currencyint = Int(stringintwages.substring(to: index))!
            let finalcurrencyint = currencyint - 11
            
            print("finalcurrencyint = \(finalcurrencyint)")
            
            myPicker.selectRow(finalcurrencyint, inComponent: 0, animated: true)
            self.currencytxtField.text = picker_values[finalcurrencyint]

        }

        if (filterbystart != "") {
           
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyMMdd"
            startdateFromString = formatter1.date(from: filterbystart)
            formatter1.dateFormat = "MMM dd, yyyy"
            startdateAsString = formatter1.string(from: startdateFromString)
            self.startDateTxtField.text = startdateAsString
            
            print("filterbystart = \(filterbystart)")
            print("startdateAsString = \(startdateAsString)")
        }
        
        if (filterbyend != "") {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyMMdd"
            enddateFromString = formatter1.date(from: filterbyend)
            formatter1.dateFormat = "MMM dd, yyyy"
            enddateAsString = formatter1.string(from: enddateFromString)
            self.endDateTxtField.text = enddateAsString
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setRateValue(rateRow:Int, wagesText:String, sliderVal: Float, wagescategoryVal:Int) {
        myPicker2.selectRow(rateRow, inComponent: 0, animated: true)
        self.wagesrangeLabel.text = wagesText
        wagesrangeSlider.setValue(sliderVal, animated: true)
        wagescategory = wagescategoryVal
        if (rateRow == 0){
            self.ratetxtField.text = "per hour"
            self.selectedRate = "per hour"
        }
        else if (rateRow == 1){
            self.ratetxtField.text = "per day"
            self.selectedRate = "per day"
        }
        else {
            self.ratetxtField.text = "per month"
            self.selectedRate = "per month"
        }
    }
    
    @objc func updateSliderLabel(sender: UISlider!) {
        wagesIndex = Int(sender.value)
        DispatchQueue.main.async {
            
            self.updatewagesLabel(value: self.wagesIndex)
        }
    }
    
    func updatewagesLabel(value: Int) {
        if (self.selectedRate == "per hour") {
            if (value == 0) {
                self.wagesrangeLabel.text = "Less than 5"
                wagescategory = 11
            }
            else if (value == 1) {
                self.wagesrangeLabel.text = "5 to 10"
                wagescategory = 12
            }
            else if (value == 2) {
                self.wagesrangeLabel.text = "11 to 20"
                wagescategory = 13
            }
            else if (value == 3) {
                self.wagesrangeLabel.text = "21 to 50"
                wagescategory = 14
            }
            else if (value == 4) {
                self.wagesrangeLabel.text = "More than 50"
                wagescategory = 15
            }
        }
        else if (self.selectedRate == "per day") {
            if (value == 0) {
                self.wagesrangeLabel.text = "Less than 70"
                wagescategory = 21
            }
            else if (value == 1) {
                self.wagesrangeLabel.text = "70 to 100"
                wagescategory = 22
            }
            else if (value == 2) {
                self.wagesrangeLabel.text = "101 to 200"
                wagescategory = 23
            }
            else if (value == 3) {
                self.wagesrangeLabel.text = "201 to 500"
                wagescategory = 24
            }
            else if (value == 4) {
                self.wagesrangeLabel.text = "More than 500"
                wagescategory = 25
            }
        }
        else {
            if (value == 0) {
                self.wagesrangeLabel.text = "Less than 1000"
                wagescategory = 31
            }
            else if (value == 1) {
                self.wagesrangeLabel.text = "1000 to 1500"
                wagescategory = 32
            }
            else if (value == 2) {
                self.wagesrangeLabel.text = "1500 to 2000"
                wagescategory = 33
            }
            else if (value == 3) {
                self.wagesrangeLabel.text = "2000 to 5000"
                wagescategory = 34
            }
            else if (value == 4) {
                self.wagesrangeLabel.text = "More than 5000"
                wagescategory = 35
            }
        }
    }
    
    
    func didTap(_ checkBox: BEMCheckBox) {
        print("tapped")
        if (checkBox.tag == 2) {
            specificRangeView2.alpha = 1
            specificRangeView2.isUserInteractionEnabled = true
            wagesrangeChkBox.setOn(true, animated: true)
            showAllChkBox.setOn(false, animated: true)
            oldfilterbywages = "false"
        }
        else {
            specificRangeView2.alpha = 0.5
            specificRangeView2.isUserInteractionEnabled = false
            wagesrangeChkBox.setOn(false, animated: true)
            showAllChkBox.setOn(true, animated: true)
            oldfilterbywages = "true"
        }
    }
    
    @IBAction func startdatePressed(_ sender: UIButton) {
       
        self.startDateTxtField.becomeFirstResponder()
        
    }
    
    @IBAction func startdateEditBegin(_ sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        mydatePicker.setDate(startdateFromString, animated: true)
        mydatePicker.tintColor = tintColor
        mydatePicker.center.x = inputView.center.x
        inputView.addSubview(mydatePicker) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(FilterViewController.doneStartButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(FilterViewController.cancelStartPicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @objc func cancelStartPicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.startDateTxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneStartButton(_ sender: UIButton) {
        //Remove view when select cancel
        let dateFormatterx = DateFormatter()
        dateFormatterx.dateStyle = .medium
        dateFormatterx.timeStyle = .none
        
        self.startDateTxtField.text = dateFormatterx.string(from: mydatePicker.date)
        self.startDateTxtField.resignFirstResponder() // To resign the inputView on clicking done.
        
        dateFormatterx.dateFormat = "yyMMdd"
        filterbystart = dateFormatterx.string(from: mydatePicker.date)
    }
    
    
    @IBAction func enddatePressed(_ sender: UIButton) {
        self.endDateTxtField.becomeFirstResponder()
        
    }
    
    @IBAction func enddateEditBegin(_ sender: UITextField) {
        
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:240))
        mydatePicker.setDate(enddateFromString, animated: true)
        mydatePicker.tintColor = tintColor
        mydatePicker.center.x = inputView.center.x
        inputView.addSubview(mydatePicker) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x:(self.view.frame.size.width - 3*(100/2)), y:0, width:100, height:50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControlState.normal)
        doneButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(FilterViewController.doneEndButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(FilterViewController.cancelEndPicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
        
    }
    
    @objc func cancelEndPicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.endDateTxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneEndButton(_ sender: UIButton) {
        //Remove view when select cancel
        let dateFormatterx = DateFormatter()
        dateFormatterx.dateStyle = .medium
        dateFormatterx.timeStyle = .none
        
        self.endDateTxtField.text = dateFormatterx.string(from: mydatePicker.date)
        self.endDateTxtField.resignFirstResponder() // To resign the inputView on clicking done.
        
        dateFormatterx.dateFormat = "yyMMdd"
        filterbyend = dateFormatterx.string(from: mydatePicker.date)
        print("filterbyend = \(filterbyend)")
        
    }
    
    
    @IBAction func ratePressed(_ sender: UIButton) {
        self.ratetxtField.becomeFirstResponder()
    }
    
    @IBAction func rateEditBegin(_ sender: UITextField) {
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
        doneButton.addTarget(self, action: #selector(FilterViewController.doneRateButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(FilterViewController.cancelRatePicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @objc func cancelRatePicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.ratetxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneRateButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.ratetxtField.text = self.selectedRate
        self.updatewagesLabel(value: self.wagesIndex)
        self.ratetxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    
    @IBAction func currencyPressed(_ sender: UIButton) {
        self.currencytxtField.becomeFirstResponder()
    }
    
    @IBAction func currencyEditBegin(_ sender: UITextField) {
        
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
        doneButton.addTarget(self, action: #selector(FilterViewController.doneButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x:100/2, y:0, width:100, height:50))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitle("Cancel", for: UIControlState.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControlState.normal)
        cancelButton.setTitleColor(tintColor, for: UIControlState.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(FilterViewController.cancelPicker(_:)), for: UIControlEvents.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
    @objc func cancelPicker(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencytxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @objc func doneButton(_ sender: UIButton) {
        //Remove view when select cancel
        self.currencytxtField.text = self.selectedCurrency
        self.currencytxtField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    @IBAction func startDateRemove(_ sender: UIButton) {
        self.startDateTxtField.text = ""
        filterbystart = ""
    }
    
    @IBAction func endDateRemove(_ sender: UIButton) {
        self.endDateTxtField.text = ""
        filterbyend = ""
    }
    
    @IBAction func applyFilterPressed(_ sender: UIButton) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            AppDelegate.instance().showActivityIndicator()
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            let newSortFilter = ref.child("SortFilter").child(uid!)
            
            //Got START DATE
            if (startDateTxtField.text != "") {
                
                //GOT END DATE
                if (endDateTxtField.text != "") {
                    
                    let startingdatelong = Int(filterbystart)
                    let endingdatelong = Int(filterbyend)
                    
                    print("startingdatelong = \(String(describing: startingdatelong))")
                    print("endingdatelong = \(String(describing: endingdatelong))")
                    
                    // If start date larger than end date
                    if (startingdatelong! > endingdatelong!) {
                        notComplete(title:"Invalid Start Date", message: "Start Date has to be earlier than End Date")
                         AppDelegate.instance().dismissActivityIndicator()
                        return
                    }
                    else {
                        scenario = 22
                        newSortFilter.child("StartDate").setValue(filterbystart)
                        newSortFilter.child("EndDate").setValue(filterbyend)
                    }
                }
                    
                // GOT START NO END
                else {
                    scenario = 11
                    newSortFilter.child("StartDate").setValue(filterbystart)
                    newSortFilter.child("EndDate").removeValue()
                }
            }
                
                //NO START DATE
            else {
                
                //GOT END DATE
                if (endDateTxtField.text != "") {
                    notComplete(title:"Empty Start Date", message: "Please select a start date")
                    AppDelegate.instance().dismissActivityIndicator()
                    return
                }
                    // NO START NO END
                else {
                    scenario = 33
                    newSortFilter.child("StartDate").removeValue()
                    newSortFilter.child("EndDate").removeValue()
                }
            }
            
            print("oldfilterbywages =\(oldfilterbywages)")
            
            //Check for Wages Filter
            if (oldfilterbywages == "true") {
                
                //If Show All is selected
                selectedCurrencyRow = (selectedCurrencyRow + 11) * 100
                let WagesFilter = selectedCurrencyRow + wagescategory
                
                newSortFilter.child("WagesFilter").removeValue(completionBlock: { (error, dataref) in
                    if error == nil {
                      
                        newSortFilter.child("OldWagesFilter").setValue(WagesFilter,  withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in

                            if (error != nil) {
                                print("error saving wages filter")
                                AppDelegate.instance().dismissActivityIndicator()
                            }
                            else {
                                
                                AppDelegate.instance().dismissActivityIndicator()
                                
                                let filterDict = ["scenario": self.scenario, "filterbywages":WagesFilter,  "filterbystart":self.filterbystart, "filterbyend":self.filterbyend, "oldfilterbywages":self.oldfilterbywages] as [String : Any]
                                
                                NotificationCenter.default.post(name: Notification.Name("updateFilter"), object: nil, userInfo: filterDict)
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setFilterPage"), object: nil)

                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                    else {
                        AppDelegate.instance().dismissActivityIndicator()
                    }
                })
                
            }
            
            else if (oldfilterbywages == "false") {
                
                //If Show All is selected
                selectedCurrencyRow = (selectedCurrencyRow + 11) * 100
                let WagesFilter = selectedCurrencyRow + wagescategory
                
                print("selectedCurrencyRow = \(selectedCurrencyRow)")
                print("WagesFilter = \(WagesFilter)")
                
                newSortFilter.child("WagesFilter").setValue(WagesFilter,  withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
                    if error == nil {

                        newSortFilter.child("OldWagesFilter").removeValue(completionBlock: { (error, dataref) in
                            
                            if (error != nil) {
                                print("error remove wages filter")
                                AppDelegate.instance().dismissActivityIndicator()
                            }
                            else {
                               print("self.scenario = \(self.scenario)")
                                if (self.scenario == 11) {
                                    self.scenario = 1
                                }
                                else if (self.scenario == 22) {
                                    self.scenario = 2
                                }
                                else if (self.scenario == 33) {
                                    self.scenario = 3
                                }
                                AppDelegate.instance().dismissActivityIndicator()
                                
                                let filterDict = ["scenario": self.scenario, "filterbywages":WagesFilter, "filterbystart":self.filterbystart, "filterbyend":self.filterbyend, "oldfilterbywages":self.oldfilterbywages] as [String : Any]
                                
                                NotificationCenter.default.post(name: Notification.Name("updateFilter"), object: nil, userInfo: filterDict)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setFilterPage"), object: nil)

                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                    else{
                        print("keluar sini")
                        AppDelegate.instance().dismissActivityIndicator()
                    }
                })
            }
        }

    }
    
    func notComplete(title:String, message: String) {
        // create the alert
        let alert = UIAlertController(title: "Invalid input", message: message, preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        
        self.startDateTxtField.text = ""
        filterbystart = ""
        
        self.endDateTxtField.text = ""
        filterbyend = ""
        
        specificRangeView2.alpha = 0.5
        specificRangeView2.isUserInteractionEnabled = false
        wagesrangeChkBox.setOn(false, animated: true)
        showAllChkBox.setOn(true, animated: true)
        
        oldfilterbywages = "true"
    }
    
}
