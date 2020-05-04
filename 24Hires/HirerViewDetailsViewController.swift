//
//  HirerViewDetailsViewController.swift
//  24Hires
//
//  Created by Jeekson Choong on 29/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HirerViewDetailsViewController: UIViewController {

    
    @IBOutlet weak var statusView               : UIView!
    @IBOutlet weak var statusLabel              : UILabel!
    @IBOutlet weak var applicantName            : UILabel!
    @IBOutlet weak var jobDateLabel             : UILabel!
    @IBOutlet weak var jobVenueLabel            : UILabel!
    @IBOutlet weak var noOfDaysLabel            : UILabel!
    @IBOutlet weak var noOfHourPerDay           : UILabel!
    @IBOutlet weak var basicPayPerDayLabel      : UILabel!
    @IBOutlet weak var basicPayCurrencyLabel    : UILabel!
    @IBOutlet weak var totalBasicPay            : UILabel!
    @IBOutlet weak var tipsAndCommissionLabel   : UILabel!
    @IBOutlet weak var totalPayLabel            : UILabel!
  
    @IBOutlet weak var applicantImageView       : UIImageView!
    @IBOutlet weak var congratsView             : UIView!
    
    @IBOutlet weak var leaveFeedbackButton      : UIButton!
    @IBOutlet weak var additionalNoteLabel      : UILabel!
    @IBOutlet weak var paymentDate          : UILabel!
  
    
    @IBAction func feedbackBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_hirerToReviewForm, sender: self)
    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewAndEditBtnPressed(_ sender: Any) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDetails), name: NSNotification.Name(rawValue: "EditPost"), object: nil)
        
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_hirerViewDetailsToHireForm, sender: self)
    }

    //prepare Segue data
    var prepareApplicantName    = String()
    var prepareApplicantImage    = String()
    var preparePostKey          = String()
    var prepareJobCity          = String()
    
    var ownUID      = String()
    var offerStatus = String()
    //Passed In Data
    var jobCity         = String()
    var postKey         = String()
    var applicantsUID   = String()
    
    let userPostedHiredApplicantsRef = Database.database().reference().child("UserPostedHiredApplicants")
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueIdentifier_hirerToReviewForm{
            let dest = segue.destination as! ReviewFormViewController
            dest.reviewReceipientUID    = applicantsUID
            dest.postKey                = postKey
            let whichVC = "Hirer"
            dest.fromwhichVC            = whichVC
        }
        else if segue.identifier == AppConstant.segueIdentifier_hirerViewDetailsToHireForm{
            let dest = segue.destination as! HireFormViewController
            dest.applicantName  = prepareApplicantName
            dest.applicantImage  = prepareApplicantImage
            dest.applicantUID   = applicantsUID
            dest.postKey        = postKey
            dest.jobCity        = jobCity
            dest.isUpdate = true
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congratsView.isHidden = true
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        print("\n================== Applied Review View Controller ================")
        print("PostKey          : \(postKey)")
        print("Applicants UID   : \(applicantsUID)\n")
        
        jobVenueLabel.adjustsFontSizeToFitWidth = true

        ownUID = (Auth.auth().currentUser?.uid)!
        
        additionalNoteLabel.sizeToFit()

        getPostDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadDetails(){
        print("reload")
        getPostDetails()
    }

    func getPostDetails(){
        userPostedHiredApplicantsRef.child(ownUID).child(postKey).child(applicantsUID).observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                print("\n============\nJob Details\n============")
                print(snapshot)
                
                if snapshot.hasChild("name"){
                    self.applicantName.text     = snapshot.childSnapshot(forPath: "name").value as? String
                }
                
                if snapshot.hasChild("date"){
                    self.jobDateLabel.text = snapshot.childSnapshot(forPath: "date").value as? String
                }
                if snapshot.hasChild("location"){
                    self.jobVenueLabel.text = snapshot.childSnapshot(forPath: "location").value as? String
                }
                if snapshot.hasChild("numdates"){
                    self.noOfDaysLabel.text = snapshot.childSnapshot(forPath: "numdates").value as? String
                }
                if snapshot.hasChild("basicpay"){
                    self.basicPayPerDayLabel.text = snapshot.childSnapshot(forPath: "basicpay").value as? String
                }
                if snapshot.hasChild("basictotalpay"){
                    self.totalBasicPay.text = snapshot.childSnapshot(forPath: "basictotalpay").value as? String
                }
                if snapshot.hasChild("totalallpay"){
                    self.totalPayLabel.text = snapshot.childSnapshot(forPath: "totalallpay").value as? String
                }
                if snapshot.hasChild("paymentdate"){
                    self.paymentDate.text = snapshot.childSnapshot(forPath: "paymentdate").value as? String
                }
                if snapshot.hasChild("numhours"){
                    self.noOfHourPerDay.text = snapshot.childSnapshot(forPath: "numhours").value as? String
                }
                if snapshot.hasChild("offerstatus"){
                    self.offerStatus = (snapshot.childSnapshot(forPath: "offerstatus").value as? String)!
                    
                    if self.offerStatus == "accepted"{
                        self.statusView.backgroundColor = UIColor.init(red: 98/255, green: 213/255, blue: 87/255, alpha: 1.0)
                        self.statusLabel.text = "OFFER ACCEPTED"
                    
                 }else if self.offerStatus == "pending"{
                        self.statusView.backgroundColor = UIColor.init(red: 245/255, green: 180/255, blue: 51/255, alpha: 1.0)
                        self.statusLabel.text = "OFFER PENDING"
                 }
                else{
                    self.statusView.backgroundColor = UIColor.init(red: 247/255, green: 213/255, blue: 87/255, alpha: 1.0)
                    self.statusLabel.text  = "OFFER REJECTED"
                    }
                }
                
                if snapshot.childSnapshot(forPath: "spinnercurrency").value as? String != "MYR" ||
                    snapshot.childSnapshot(forPath: "spinnerrate").value as? String != "per day"{
                    
                    let unit = snapshot.childSnapshot(forPath: "spinnercurrency").value as? String
                    let rate = snapshot.childSnapshot(forPath: "spinnerrate").value as? String
                    
                    self.basicPayCurrencyLabel.text = "Basic Pay \(rate!) (\(unit!))"
                }
                
                if snapshot.hasChild("tipspay"){
                    self.tipsAndCommissionLabel.text = snapshot.childSnapshot(forPath: "tipspay").value as? String
                }
                
                if snapshot.hasChild("additionalnote"){
                    self.additionalNoteLabel.text = snapshot.childSnapshot(forPath: "additionalnote").value as? String
                }
                
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
                print("[Date Now]:\(datenow)")
                print("[Date Formatter] Job End date: \(enddate!)")
                if(enddate! > datenow) && enddate != nil{
                    print("JOB NOT YET END")
                    self.leaveFeedbackButton.isHidden = true
                }else{
                    print("[Check Job End]: JOB ENDED")
                    self.leaveFeedbackButton.isHidden = false
                    
                }
            }
            
            
        }) { (error) in
            if error.localizedDescription != ""{
                print("[Get Post Data Failed.]")
            }
            
        }
        
        Database.database().reference().child("UserAccount").child(self.applicantsUID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() && snapshot.hasChild("image"){
                //set image
                let applicantImage = snapshot.childSnapshot(forPath: "image").value as? String
                print(applicantImage!)
                
                if applicantImage! != "default"{
                    self.applicantImageView.sd_setImage(with: URL(string: applicantImage!) , completed: nil)
                    self.prepareApplicantImage = applicantImage!
                }
                else{
                    self.applicantImageView.image = UIImage(named: "userprofile_default")
                }
            }
            
            if snapshot.exists() && snapshot.hasChild("name"){
                //set image
                let applicantName = snapshot.childSnapshot(forPath: "name").value as? String
                print(applicantName!)
 
                self.prepareApplicantName = applicantName!
                
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
