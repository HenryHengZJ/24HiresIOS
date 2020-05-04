
//
//  EditWorkExpViewController.swift
//  JobIn24
//
//  Created by MacUser on 30/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Toast_Swift

class EditWorkExpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
   
    @IBOutlet weak var workCompany1: UITextView!
    @IBOutlet weak var workPosition1: UITextView!
    @IBOutlet weak var workPeriodtxtField1: UITextField!
    @IBOutlet weak var workView1: UIStackView!
    @IBOutlet weak var remove1: UIButton!
    
    
    @IBOutlet weak var workCompany2: UITextView!
    @IBOutlet weak var workPosition2: UITextView!
    @IBOutlet weak var workPeriodtxtField2: UITextField!
    @IBOutlet weak var workView2: UIStackView!
    @IBOutlet weak var remove2: UIButton!
    
    @IBOutlet weak var workCompany3: UITextView!
    @IBOutlet weak var workPosition3: UITextView!
    @IBOutlet weak var workPeriodtxtField3: UITextField!
    @IBOutlet weak var workView3: UIStackView!
    @IBOutlet weak var remove3: UIButton!
    
    @IBOutlet weak var workCompany4: UITextView!
    @IBOutlet weak var workPosition4: UITextView!
    @IBOutlet weak var workPeriodtxtField4: UITextField!
    @IBOutlet weak var workView4: UIStackView!
    
    @IBOutlet weak var remove4: UIButton!
    
    @IBOutlet weak var workCompany5: UITextView!
    @IBOutlet weak var workPosition5: UITextView!
    @IBOutlet weak var workPeriodtxtField5: UITextField!
    @IBOutlet weak var workView5: UIStackView!
    @IBOutlet weak var remove5: UIButton!
    
    @IBOutlet weak var workscrollView: UIScrollView!
   
    @IBOutlet weak var addNewStackView: UIStackView!
    
    @IBOutlet weak var addNewBtn: UIButton!
   
    var workcompanytext1:String!
    var workpositiontext1:String!
    var worklengthtext1:String!
    
    var workcompanytext2:String!
    var workpositiontext2:String!
    var worklengthtext2:String!
    
    var workcompanytext3:String!
    var workpositiontext3:String!
    var worklengthtext3:String!
    
    var workcompanytext4:String!
    var workpositiontext4:String!
    var worklengthtext4:String!
    
    var workcompanytext5:String!
    var workpositiontext5:String!
    var worklengthtext5:String!
   
    var selectedPeriod = ""
    var selectedtxtField = ""
    var userid:String!
    
    let picker_values = ["","Less than a month", "Less than 3 months", "Less than 6 months", "Less than 1 year", "2 years +", "5 years +", "10 years +", "20 years +"]
    var myPicker: UIPickerView! = UIPickerView()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Work Experience"
   
        self.workPeriodtxtField1.inputAccessoryView = UIView()
        self.workPeriodtxtField2.inputAccessoryView = UIView()
        self.workPeriodtxtField3.inputAccessoryView = UIView()
        self.workPeriodtxtField4.inputAccessoryView = UIView()
        self.workPeriodtxtField5.inputAccessoryView = UIView()
        
        self.myPicker = UIPickerView(frame: CGRect(x:0, y:40, width:0, height:0))
        
        self.workPeriodtxtField1.delegate = self
        self.workPeriodtxtField2.delegate = self
        self.workPeriodtxtField3.delegate = self
        self.workPeriodtxtField4.delegate = self
        self.workPeriodtxtField5.delegate = self
       
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        self.myPicker.tag = 1
        
       
        if (workcompanytext1 != nil && workpositiontext1 != nil && worklengthtext1 != nil) {
           
            workView1.isHidden = false
            remove1.isHidden = false
           
            workCompany1.text = workcompanytext1
            workPosition1.text = workpositiontext1
            workPeriodtxtField1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .text = worklengthtext1
        }
        
        if (workcompanytext2 != nil && workpositiontext2 != nil && worklengthtext2 != nil) {
            
            if (workcompanytext2 != "" && workpositiontext2 != "" && worklengthtext2 != "") {
                workView2.isHidden = false
                remove1.isHidden = true
                remove2.isHidden = false
            }
            else {
                workView2.isHidden = true
            }
            
            workCompany2.text = workcompanytext2
            workPosition2.text = workpositiontext2
            workPeriodtxtField2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .text = worklengthtext2
        }
        
        if (workcompanytext3 != nil && workpositiontext3 != nil && worklengthtext3 != nil) {
            
            if (workcompanytext3 != "" && workpositiontext3 != "" && worklengthtext3 != "") {
                workView3.isHidden = false
                remove1.isHidden = true
                remove2.isHidden = true
                remove3.isHidden = false
            }
            else {
                workView3.isHidden = true
            }
            
            workCompany3.text = workcompanytext3
            workPosition3.text = workpositiontext3
            workPeriodtxtField3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    .text = worklengthtext3
        }
        
        if (workcompanytext4 != nil && workpositiontext4 != nil && worklengthtext4 != nil) {
            
            if (workcompanytext4 != "" && workpositiontext4 != "" && worklengthtext4 != "") {
                workView4.isHidden = false
                remove1.isHidden = true
                remove2.isHidden = true
                remove3.isHidden = true
                remove4.isHidden = false
            }
            else {
                workView4.isHidden = true
            }
            
            workCompany4.text = workcompanytext4
            workPosition4.text = workpositiontext4
            workPeriodtxtField4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .text = worklengthtext4
        }
        
        if (workcompanytext5 != nil && workpositiontext5 != nil && worklengthtext5 != nil) {
            
            if (workcompanytext5 != "" && workpositiontext5 != "" && worklengthtext5 != "") {
                workView5.isHidden = false
                remove1.isHidden = true
                remove2.isHidden = true
                remove3.isHidden = true
                remove4.isHidden = true
                remove5.isHidden = false
            }
            else {
                workView5.isHidden = true
            }
            
            workCompany5.text = workcompanytext5
            workPosition5.text = workpositiontext5
            workPeriodtxtField5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .text = worklengthtext5
        }
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            userid = currentUser?.uid
          
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return picker_values.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return picker_values[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        self.selectedPeriod = picker_values[row]
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.resignFirstResponder()
        return false
    }
    
    @IBAction func addnew(_ sender: Any) {
        
        if (!workView1.isHidden && workView2.isHidden) {
            workView2.isHidden = false
            remove1.isHidden = true
        }
        else if (!workView1.isHidden && !workView2.isHidden && workView3.isHidden) {
            workView3.isHidden = false
            remove2.isHidden = true
        }
        else if (!workView1.isHidden && !workView2.isHidden && !workView3.isHidden && workView4.isHidden) {
            workView4.isHidden = false
            remove3.isHidden = true
        }
        else if (!workView1.isHidden && !workView2.isHidden && !workView3.isHidden && !workView4.isHidden && workView5.isHidden) {
            workView5.isHidden = false
            remove4.isHidden = true
            addNewBtn.alpha = 0.45
            addNewBtn.isEnabled = false
        }
        else if (workView1.isHidden && workView2.isHidden && workView3.isHidden && workView4.isHidden && workView5.isHidden) {
            workView1.isHidden = false
        }
        
        let bottomOffset = CGPoint(x:0, y: max(workscrollView.contentSize.height - workscrollView.bounds.size.height + workscrollView.contentInset.bottom + 200, 0))
    
        workscrollView.setContentOffset(bottomOffset, animated: true)
        
        
    }
 
    @IBAction func periodEditBegin(_ sender: UITextField) {
        
        createView(sender: sender)
        selectedtxtField = "1"
    }
    
    @IBAction func period2EditBegin(_ sender: UITextField) {
        
        createView(sender: sender)
        selectedtxtField = "2"
    }
    
    @IBAction func period3EditBegin(_ sender: UITextField) {
        
        createView(sender: sender)
        selectedtxtField = "3"
    }
    
    @IBAction func period4EditBegin(_ sender: UITextField) {
        
        createView(sender: sender)
        selectedtxtField = "4"
    }
    
    @IBAction func period5EditBegin(_ sender: UITextField) {
        
        createView(sender: sender)
        selectedtxtField = "5"
    }
    
    
    
    
    @IBAction func periodPressed(_ sender: UIButton){
        self.workPeriodtxtField1.becomeFirstResponder()
        selectedtxtField = "1"
    }
    
    @IBAction func period2Pressed(_ sender: UIButton) {
        self.workPeriodtxtField2.becomeFirstResponder()
        selectedtxtField = "2"
    }
    
    @IBAction func period3Pressed(_ sender: UIButton) {
        self.workPeriodtxtField3.becomeFirstResponder()
        selectedtxtField = "3"
    }
    
    @IBAction func period4Pressed(_ sender: UIButton) {
        self.workPeriodtxtField4.becomeFirstResponder()
        selectedtxtField = "4"
    }
    
    @IBAction func period5Pressed(_ sender: UIButton) {
        self.workPeriodtxtField5.becomeFirstResponder()
        selectedtxtField = "5"
    }

    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {

        // IF WORKEXP1 IS VISIBLE
        if (!workView1.isHidden) {
            
            let companytext1 = workCompany1.text
            let positiontext1 = workPosition1.text
            let periodtext1 = workPeriodtxtField1.text
            
            if (companytext1 != "" && positiontext1 != "" && periodtext1 != "") {
                setWorkExp1(companytext:companytext1!, positiontext:positiontext1!, periodtext:periodtext1!)
            }
            else {
                notComplete()
                return
            }
        
            sendNotification1(removal: "false", companytext:companytext1!, positiontext:positiontext1!, periodtext:periodtext1!)
        }
        else {
            let ref = Database.database().reference()
            ref.child("UserInfo").child(userid).child("WorkExp1").removeValue()
            
            sendNotification1(removal: "true", companytext:"", positiontext:"", periodtext:"")
        }
        
        // IF WORKEXP2 IS VISIBLE
        if (!workView2.isHidden) {
            
            let companytext2 = workCompany2.text
            let positiontext2 = workPosition2.text
            let periodtext2 = workPeriodtxtField2.text
            
            if (companytext2 != "" && positiontext2 != "" && periodtext2 != "") {
                setWorkExp2(companytext:companytext2!, positiontext:positiontext2!, periodtext:periodtext2!)
            }
            else {
                notComplete()
                return
            }
            
            sendNotification2(removal: "false", companytext:companytext2!, positiontext:positiontext2!, periodtext:periodtext2!)
        }
        else {
            let ref = Database.database().reference()
            ref.child("UserInfo").child(userid).child("WorkExp2").removeValue()
            
            sendNotification2(removal: "true", companytext:"", positiontext:"", periodtext:"")
        }
        
        // IF WORKEXP3 IS VISIBLE
        if (!workView3.isHidden) {
            
            let companytext3 = workCompany3.text
            let positiontext3 = workPosition3.text
            let periodtext3 = workPeriodtxtField3.text
            
            if (companytext3 != "" && positiontext3 != "" && periodtext3 != "") {
                setWorkExp3(companytext:companytext3!, positiontext:positiontext3!, periodtext:periodtext3!)
            }
            else {
                notComplete()
                return
            }
            
            sendNotification3(removal: "false", companytext:companytext3!, positiontext:positiontext3!, periodtext:periodtext3!)
        }
        else {
            let ref = Database.database().reference()
            ref.child("UserInfo").child(userid).child("WorkExp3").removeValue()
            
            sendNotification3(removal: "true", companytext:"", positiontext:"", periodtext:"")
        }
        
        
        // IF WORKEXP4 IS VISIBLE
        if (!workView4.isHidden) {
            
            let companytext4 = workCompany4.text
            let positiontext4 = workPosition4.text
            let periodtext4 = workPeriodtxtField4.text
            
            if (companytext4 != "" && positiontext4 != "" && periodtext4 != "") {
                setWorkExp4(companytext:companytext4!, positiontext:positiontext4!, periodtext:periodtext4!)
            }
            else {
                notComplete()
                return
            }
            
            sendNotification4(removal: "false", companytext:companytext4!, positiontext:positiontext4!, periodtext:periodtext4!)
        }
        else {
            let ref = Database.database().reference()
            ref.child("UserInfo").child(userid).child("WorkExp4").removeValue()
            
            sendNotification4(removal: "true", companytext:"", positiontext:"", periodtext:"")
        }
        
        
        // IF WORKEXP5 IS VISIBLE
        if (!workView5.isHidden) {
            
            let companytext5 = workCompany5.text
            let positiontext5 = workPosition5.text
            let periodtext5 = workPeriodtxtField5.text
            
            if (companytext5 != "" && positiontext5 != "" && periodtext5 != "") {
                setWorkExp5(companytext:companytext5!, positiontext:positiontext5!, periodtext:periodtext5!)
            }
            else {
                notComplete()
                return
            }
            
            sendNotification5(removal: "false", companytext:companytext5!, positiontext:positiontext5!, periodtext:periodtext5!)
        }
        else {
            let ref = Database.database().reference()
            ref.child("UserInfo").child(userid).child("WorkExp5").removeValue()
            
            sendNotification5(removal: "true", companytext:"", positiontext:"", periodtext:"")
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func setWorkExp1(companytext:String, positiontext:String, periodtext:String) {
        
        if(userid != nil){
            
            let ref = Database.database().reference()
           
            let newWorkPost = ref.child("UserInfo").child(userid).child("WorkExp1")
            
            let newWorkDetails = ["worktitle": positiontext,
                                  "workcompany": companytext,
                                  "worktime": periodtext
                
                ] as [String : Any]
            
            newWorkPost.setValue(newWorkDetails)
        }
    }
    
    func setWorkExp2(companytext:String, positiontext:String, periodtext:String) {
        
        if(userid != nil){
            
            let ref = Database.database().reference()
            
            let newWorkPost = ref.child("UserInfo").child(userid).child("WorkExp2")
            
            let newWorkDetails = ["worktitle": positiontext,
                                  "workcompany": companytext,
                                  "worktime": periodtext
                
                ] as [String : Any]
            
            newWorkPost.setValue(newWorkDetails)
        }
    }
    
    func setWorkExp3(companytext:String, positiontext:String, periodtext:String) {
        
        if(userid != nil){
            
            let ref = Database.database().reference()
            
            let newWorkPost = ref.child("UserInfo").child(userid).child("WorkExp3")
            
            let newWorkDetails = ["worktitle": positiontext,
                                  "workcompany": companytext,
                                  "worktime": periodtext
                
                ] as [String : Any]
            
            newWorkPost.setValue(newWorkDetails)
        }
    }
    
    func setWorkExp4(companytext:String, positiontext:String, periodtext:String) {
        
        if(userid != nil){
            
            let ref = Database.database().reference()
            
            let newWorkPost = ref.child("UserInfo").child(userid).child("WorkExp4")
            
            let newWorkDetails = ["worktitle": positiontext,
                                  "workcompany": companytext,
                                  "worktime": periodtext
                
                ] as [String : Any]
            
            newWorkPost.setValue(newWorkDetails)
        }
    }
    
    func setWorkExp5(companytext:String, positiontext:String, periodtext:String) {
        
        if(userid != nil){
            
            let ref = Database.database().reference()
            
            let newWorkPost = ref.child("UserInfo").child(userid).child("WorkExp5")
            
            let newWorkDetails = ["worktitle": positiontext,
                                  "workcompany": companytext,
                                  "worktime": periodtext
                
                ] as [String : Any]
            
            newWorkPost.setValue(newWorkDetails)
        }
    }

    func notComplete() {
        // create the alert
        let alert = UIAlertController(title: "Invalid input", message: "Please fill in the remaining blank spaces", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in

            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func createView(sender: UITextField) {
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
        if (selectedtxtField == "1") {
            self.workPeriodtxtField1.resignFirstResponder()
        }
        else if (selectedtxtField == "2") {
            self.workPeriodtxtField2.resignFirstResponder()
        }
        else if (selectedtxtField == "3") {
            self.workPeriodtxtField3.resignFirstResponder()
        }
        else if (selectedtxtField == "4") {
            self.workPeriodtxtField4.resignFirstResponder()
        }
        else if (selectedtxtField == "5") {
            self.workPeriodtxtField5.resignFirstResponder()
        }
    }
    
    @objc func doneRateButton(_ sender: UIButton) {
        //Remove view when select cancel
        if (selectedtxtField == "1") {
            self.workPeriodtxtField1.text = self.selectedPeriod
            self.workPeriodtxtField1.resignFirstResponder()
        }
        else if (selectedtxtField == "2") {
            self.workPeriodtxtField2.text = self.selectedPeriod
            self.workPeriodtxtField2.resignFirstResponder()
        }
        else if (selectedtxtField == "3") {
            self.workPeriodtxtField3.text = self.selectedPeriod
            self.workPeriodtxtField3.resignFirstResponder()
        }
        else if (selectedtxtField == "4") {
            self.workPeriodtxtField4.text = self.selectedPeriod
            self.workPeriodtxtField4.resignFirstResponder()
        }
        else if (selectedtxtField == "5") {
            self.workPeriodtxtField5.text = self.selectedPeriod
            self.workPeriodtxtField5.resignFirstResponder()
        }
        
    }
    
    func sendNotification1(removal:String, companytext:String, positiontext:String, periodtext:String) {
        let workexpDict: [String: String] = ["removal": removal, "worktitle": positiontext, "workcompany": companytext, "worktime": periodtext]
        
        NotificationCenter.default.post(name: Notification.Name("updateWorkExp1"), object: nil, userInfo: workexpDict)
        
    }
    
    func sendNotification2(removal:String, companytext:String, positiontext:String, periodtext:String) {
        let workexpDict: [String: String] = ["removal": removal, "worktitle": positiontext, "workcompany": companytext, "worktime": periodtext]
        
        NotificationCenter.default.post(name: Notification.Name("updateWorkExp2"), object: nil, userInfo: workexpDict)
        
    }
    
    func sendNotification3(removal:String, companytext:String, positiontext:String, periodtext:String) {
        let workexpDict: [String: String] = ["removal": removal, "worktitle": positiontext, "workcompany": companytext, "worktime": periodtext]
        
        NotificationCenter.default.post(name: Notification.Name("updateWorkExp3"), object: nil, userInfo: workexpDict)
       
    }
    
    func sendNotification4(removal:String, companytext:String, positiontext:String, periodtext:String) {
        let workexpDict: [String: String] = ["removal": removal, "worktitle": positiontext, "workcompany": companytext, "worktime": periodtext]
        
        NotificationCenter.default.post(name: Notification.Name("updateWorkExp4"), object: nil, userInfo: workexpDict)
        
    }
    
    func sendNotification5(removal:String, companytext:String, positiontext:String, periodtext:String) {
        let workexpDict: [String: String] = ["removal": removal, "worktitle": positiontext, "workcompany": companytext, "worktime": periodtext]
        
        NotificationCenter.default.post(name: Notification.Name("updateWorkExp5"), object: nil, userInfo: workexpDict)
        
    }
    
    
    @IBAction func remove5Pressed(_ sender: UIButton) {
        workView5.isHidden = true
        workCompany5.text = ""
        workPosition5.text = ""
        workPeriodtxtField5.text = ""
        remove4.isHidden = false
        addNewBtn.alpha = 1.0
        addNewBtn.isEnabled = true
    }
  
    @IBAction func remove4Pressed(_ sender: Any) {
        workView4.isHidden = true
        workCompany4.text = ""
        workPosition4.text = ""
        workPeriodtxtField4.text = ""
        remove3.isHidden = false
    }
    
    @IBAction func remove3Pressed(_ sender: Any) {
        workView3.isHidden = true
        workCompany3.text = ""
        workPosition3.text = ""
        workPeriodtxtField3.text = ""
        remove2.isHidden = false
    }
    
    @IBAction func remove2Pressed(_ sender: Any) {
        workView2.isHidden = true
        workCompany2.text = ""
        workPosition2.text = ""
        workPeriodtxtField2.text = ""
        remove1.isHidden = false
    }
    
    @IBAction func remove1Pressed(_ sender: Any) {
        workView1.isHidden = true
        workCompany1.text = ""
        workPosition1.text = ""
        workPeriodtxtField1.text = ""
        remove1.isHidden = false
    }
    
}
