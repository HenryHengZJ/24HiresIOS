//
//  AppliedReviewViewController.swift
//  JobIn24
//
//  Created by Jeekson Choong on 23/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class AppliedReviewViewController: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var offerStatusView      : UIView!
    @IBOutlet weak var hirerNameLabel       : UILabel!
    @IBOutlet weak var jobDateLabel         : UILabel!
    @IBOutlet weak var jobVenueLabel        : UILabel!
    @IBOutlet weak var noOfDaysLabel        : UILabel!
    @IBOutlet weak var noOfHourLabel        : UILabel!
    @IBOutlet weak var basicPayUnitLabel    : UILabel!
    @IBOutlet weak var basicPayLabel        : UILabel!
    @IBOutlet weak var basicPayTotalLabel   : UILabel!
    @IBOutlet weak var tipsAmountLabel      : UILabel!
    @IBOutlet weak var totalPayLabel        : UILabel!
    @IBOutlet weak var offerStatusLabel     : UILabel!
    @IBOutlet weak var hirerImageView       : UIImageView!
    @IBOutlet weak var feedbackButton       : UIButton!
    @IBOutlet weak var additionalNoteLabel  : UILabel!
    @IBOutlet weak var paymenDateLabel      : UILabel!
   
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var pendingView: UIView!
    
    @IBAction func acceptJobPressed(_ sender: Any) {
        
        // create the alert
        let alert = UIAlertController(title: "Accept Job Offer", message: "Are you sure you want to accept the job offer?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { action in
            
            self.acceptjoboffer()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            //self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func rejectJobPressed(_ sender: Any) {
        
        // create the alert
        let alert = UIAlertController(title: "Reject Job Offer", message: "Are you sure you want to reject the job offer?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.default, handler: { action in
            
            self.rejectjoboffer()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            //self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
       
    }
    
    func rejectjoboffer() {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil && hirerID != nil && postKey != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(hirerID!).child("NewMainNotification").setValue("true")
            ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownuid!).child("offerstatus").setValue("rejected")
            ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownuid!).child("pressed").setValue("false")
            ref.child("UserActivities").child(hirerID!).child("NewPosted").setValue("true")
            ref.child("UserActivities").child(hirerID!).child("NewApplicant").setValue("true")
            ref.child("UserPosted").child(hirerID!).child(postKey!).child("pressed").setValue("false")
            ref.child("UserActivities").child(ownuid!).child("Applied").child(postKey!).child("status").setValue("rejectedoffer")
            
            
            self.pendingView.isHidden = true
            self.offerStatusView.isHidden = false
            self.offerStatusView.backgroundColor = UIColor.init(red: 248/255, green: 62/255, blue: 34/255, alpha: 1.0)
            self.offerStatusLabel.text  = "OFFER REJECTED"
            
            deleteHiredNotifications()
            
        }
    }
    
    func acceptjoboffer() {
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil && hirerID != nil && postKey != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(hirerID!).child("NewMainNotification").setValue("true")
            ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownuid!).child("offerstatus").setValue("accepted")
            ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownuid!).child("pressed").setValue("false")
            ref.child("UserActivities").child(hirerID!).child("NewPosted").setValue("true")
            ref.child("UserActivities").child(hirerID!).child("NewApplicant").setValue("true")
            ref.child("UserPosted").child(hirerID!).child(postKey!).child("pressed").setValue("false")
            ref.child("UserActivities").child(ownuid!).child("Applied").child(postKey!).child("status").setValue("acceptedoffer")
            
            
            self.pendingView.isHidden = true
            self.offerStatusView.isHidden = false
            self.offerStatusView.backgroundColor = UIColor.init(red: 98/255, green: 213/255, blue: 87/255, alpha: 1.0)
            self.offerStatusLabel.text = "OFFER ACCEPTED"
            
            deleteHiredNotifications()
        }
    }
    
    func deleteHiredNotifications() {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(ownuid!).child("HiredNotification").observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let notiKey = rest.key as? String {
                            ref.child("HireNotification").child("Hire").child(notiKey).removeValue(completionBlock: { (error:Error?, ref:DatabaseReference!) in
                                
                                if (error != nil) {
                                }
                                else {
                                    ref.child("UserActivities").child(ownuid!).child("HiredNotification").child(notiKey).removeValue()
                                }
                            })
                        }
                    }
                }
                
            })
            
        }
    }
    
    @IBAction func feedbackPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_appliedToFeedback, sender: self)
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    let currentUser = Auth.auth().currentUser
    let ref         = Database.database().reference()
    
    var hirerID     : String?
    var postKey     : String?
    var jobStatus   = Bool()
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        print("\n================== Applied Review View Controller ================")
        print("PostKey: \(postKey!)")
        print("HirerID: \(hirerID!)\n")
        
        self.rejectButton.layer.masksToBounds = false
        self.rejectButton.layer.shadowRadius = 3.0
        self.rejectButton.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.rejectButton.layer.shadowOffset = CGSize(width: 0, height:3)
        self.rejectButton.layer.shadowOpacity = 1.0
        
        self.acceptButton.layer.masksToBounds = false
        self.acceptButton.layer.shadowRadius = 3.0
        self.acceptButton.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.acceptButton.layer.shadowOffset = CGSize(width: 0, height:3)
        self.acceptButton.layer.shadowOpacity = 1.0
        
        jobVenueLabel.adjustsFontSizeToFitWidth = true
        
        additionalNoteLabel.sizeToFit()
        
        getPostDetails(hirerID: hirerID!, postKey: postKey!)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueIdentifier_appliedToFeedback{
           let dest = segue.destination as! ReviewFormViewController
            dest.reviewReceipientUID    = hirerID!
            dest.postKey                = postKey!
            let whichVC = "Applied"
            dest.fromwhichVC            = whichVC
        }
    }

    func getPostDetails(hirerID: String, postKey: String){
        
        print("=======================\n Get Posted Job Details\n======================")
        
        let ownUID = currentUser?.uid
        print("Own UID: \(String(describing: ownUID))\n")
        let userPostedHiredApplicatsRef = ref.child("UserPostedHiredApplicants")
        let userAccountRef = ref.child("UserAccount")
        
        userAccountRef.child(hirerID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                
                if snapshot.hasChild("name"){
                   let name = (snapshot.childSnapshot(forPath: "name").value as? String)!
                    self.hirerNameLabel.text = name
                    
                }else{
                    let name = ""
                    self.hirerNameLabel.text = name
                }
            }else{
                let name = ""
                self.hirerNameLabel.text = name
            }
        }) { (error) in
            if error.localizedDescription != ""{
                let name = ""
                self.hirerNameLabel.text = name                                
            }
        }
        userPostedHiredApplicatsRef.child(hirerID).child(postKey).child(ownUID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("\n============\nJob Details\n============")
                print(snapshot)
                
                if snapshot.hasChild("date"){
                    self.jobDateLabel.text          = snapshot.childSnapshot(forPath: "date").value as? String
                }
                if snapshot.hasChild("location"){
                    self.jobVenueLabel.text         = snapshot.childSnapshot(forPath: "location").value as? String
                }
                if snapshot.hasChild("numdates"){
                    self.noOfDaysLabel.text          = snapshot.childSnapshot(forPath: "numdates").value as? String
                }
                if snapshot.hasChild("basicpay"){
                    self.basicPayLabel.text         = snapshot.childSnapshot(forPath: "basicpay").value as? String
                }
                if snapshot.hasChild("basictotalpay"){
                    self.basicPayTotalLabel.text    = snapshot.childSnapshot(forPath: "basictotalpay").value as? String
                }
                if snapshot.hasChild("totalallpay"){
                    self.totalPayLabel.text         = snapshot.childSnapshot(forPath: "totalallpay").value as? String
                }
                if snapshot.hasChild("paymentdate"){
                    self.paymenDateLabel.text      = snapshot.childSnapshot(forPath: "paymentdate").value as? String
                }
                if snapshot.hasChild("numhours"){
                    self.noOfHourLabel.text         = snapshot.childSnapshot(forPath: "numhours").value as? String
                }else{
                    self.noOfHourLabel.text = "-"
                    self.noOfHourLabel.backgroundColor = UIColor.lightGray
                }
                
                if snapshot.childSnapshot(forPath: "spinnercurrency").value as? String != "MYR" ||
                    snapshot.childSnapshot(forPath: "spinnerrate").value as? String != "per day"{
                    
                    let unit = snapshot.childSnapshot(forPath: "spinnercurrency").value as? String
                    let rate = snapshot.childSnapshot(forPath: "spinnerrate").value as? String
                    
                    self.basicPayUnitLabel.text = "Basic Pay \(rate!) (\(unit!))"
                }
                
                if snapshot.hasChild("tipspay"){
                    self.tipsAmountLabel.text = snapshot.childSnapshot(forPath: "tipspay").value as? String
                }
                
                if snapshot.hasChild("additionalnote"){
                    self.additionalNoteLabel.text = snapshot.childSnapshot(forPath: "additionalnote").value as? String
                }
                
                let status = snapshot.childSnapshot(forPath: "offerstatus").value as? String
                
                //SET THE STATUS VIEW
                if status == "accepted"{
                    self.jobStatus = true
                    self.pendingView.isHidden = true
                    self.offerStatusView.isHidden = false
                    self.offerStatusView.backgroundColor = UIColor.init(red: 98/255, green: 213/255, blue: 87/255, alpha: 1.0)
                    self.offerStatusLabel.text = "OFFER ACCEPTED"
                    
                    //Date Checking
                    
                    let jobDate = snapshot.childSnapshot(forPath: "date").value as? String
                    var lastdate = ""
                    
                    if (jobDate?.contains("/"))! {
                        let items = jobDate?.components(separatedBy: "/")
                        lastdate = items![(items?.count)! - 1]
                        
                    }
                    else if (jobDate?.contains("to"))!  {
                        let items = jobDate?.components(separatedBy: "to")
                        lastdate = items![1]
                    }
                    else {
                        lastdate = jobDate!
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd MMM yy"
                    let enddate = formatter.date(from: lastdate)
                    let datenow = Date()
                    print("[Date Formatter] Job End date: \(enddate!)")
                    print("[Date Formatter] datenow date: \(datenow)")
                    if(enddate! > datenow) && enddate != nil{
                        print("Job Not End Yet")
                        self.feedbackButton.isHidden = true
                    }
                    else {
                        print("Job Ended")
                        self.feedbackButton.isHidden = false
                    }
                   
                    
                }else if status == "rejected"{
                    self.jobStatus = false
                    self.pendingView.isHidden = true
                    self.offerStatusView.isHidden = false
                    self.offerStatusView.backgroundColor = UIColor.init(red: 248/255, green: 62/255, blue: 34/255, alpha: 1.0)
                    self.offerStatusLabel.text  = "OFFER REJECTED"
                    self.feedbackButton.isHidden = true
                  
                }
                else {
                    self.jobStatus = false
                    self.pendingView.isHidden = false
                    self.offerStatusView.isHidden = true
                    self.feedbackButton.isHidden = true
                }
      
                
            }
            
        }
        
        ref.child("UserAccount").child(hirerID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() && snapshot.hasChild("image"){
                //set image
                let hirerImage = snapshot.childSnapshot(forPath: "image").value as? String
                
                if hirerImage != "default" || hirerImage != ""{
                    self.hirerImageView.sd_setImage(with: URL(string: hirerImage!) , completed: nil)
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
