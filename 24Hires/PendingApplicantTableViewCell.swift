//
//  PendingApplicantTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 26/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FirebaseDatabase
import FirebaseAuth

class PendingApplicantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var applicantImage: UIImageView!
    
    @IBOutlet weak var applicantName: UILabel!
    
    @IBOutlet weak var applicantLocation: UILabel!
    
    @IBOutlet weak var workTitle1: UILabel!
    
    @IBOutlet weak var workPlace1: UILabel!
    
    @IBOutlet weak var workTitle2: UILabel!
    
    @IBOutlet weak var workPlace2: UILabel!
    
    @IBOutlet weak var timerleftlbl: UILabel!
 
    var endDate: Date!
    
    var nowDate: Date!
    
    var WaitingOver: Bool!
    
    var applieduserUid: String!
    
    var postKey: String!
    
    var pressed: String!
    
    func decrementnewapplicant(userid:String!, postKey:String!){
        
        let ref = Database.database().reference()
        let refDecrement = ref.child("UserPosted").child(userid).child(postKey)
        
        refDecrement.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            if var data = currentData.value as? [String: Any] {
                var count = data["newapplicantscount"] as? Int ?? 0
                if count > 0 {
                    count -= 1
                    data["newapplicantscount"] = count
                    currentData.value = data
                }
                else if count == 0 {
                    data["newapplicantscount"] = 0
                    currentData.value = data
                }
            }
            
            return TransactionResult.success(withValue: currentData)
        }

    }
    
    func decrementapplicant(userid:String!, postKey:String!){
        
        let ref = Database.database().reference()
        let refDecrement = ref.child("UserPosted").child(userid).child(postKey)
        
        refDecrement.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            if var data = currentData.value as? [String: Any] {
                var count = data["applicantscount"] as? Int ?? 0
                
                if count > 0 {
                    count -= 1
                    data["applicantscount"] = count
                    currentData.value = data
                }
                else if count == 0 {
                    data["newapplicantscount"] = 0
                    currentData.value = data
                }
                
            }
            
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    @objc func updateUI(){
        
        if(WaitingOver == false){
            
            self.nowDate = Date()
            
            let diffDateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: nowDate, to: endDate)
            
            let hours = Int(diffDateComponents.hour!)
            let cgfloathours = CGFloat(hours)
            
            let minutes = Int(diffDateComponents.minute!)
            
            let seconds = Int(diffDateComponents.second!)
            
            if(endDate > nowDate){
                
                let xstrTimeLeft = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
                
                timerleftlbl.text = xstrTimeLeft
            }
            else{
                
                if(WaitingOver == false){
                    
                    // delete applicants, then set WaitingOver to true
                    
                    self.WaitingOver = true
                    
                    let currentUser = Auth.auth().currentUser
                    
                    if(currentUser != nil){
                        
                        let uid = currentUser?.uid
                        
                        let ref = Database.database().reference()
                        
                        if self.pressed == "false" {
                            self.decrementnewapplicant(userid: uid!, postKey: self.postKey)
                        }
                        ref.child("UserPostedPendingApplicants").child(uid!).child(self.postKey).child(self.applieduserUid).removeValue()
                        
                        self.decrementapplicant(userid: uid!, postKey: self.postKey)
                        
                        
                        //notified applicants that you are rejected if applicant is not shortlisted yet
                        
                        ref.child("UserActivities").child(self.applieduserUid).child("Applied").child(self.postKey).observeSingleEvent(of: .value, with: { snapshot in
                            
                            if !snapshot.exists() {return}
                            
                            if !snapshot.childSnapshot(forPath: self.postKey).hasChild("status") {return}
                            
                            if let statusval = snapshot.childSnapshot(forPath: "status").value as? String{
 
                                if(statusval == "applied"){
                                    
                                    ref.child("UserActivities").child(self.applieduserUid).child("NewMainNotification").setValue("true")
                                    ref.child("UserActivities").child(self.applieduserUid).child("NewApplied").setValue("true")
                                    ref.child("UserActivities").child(self.applieduserUid).child("Applied").child(self.postKey).child("status").setValue("appliedrejected")
                                    
                                    
                                }
                                
                            }
                            
                        })
                        
                    }
                    
                }
 
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(PendingApplicantTableViewCell.updateUI), name: Notification.Name("ApplicantCellUpdate"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.applicantImage.layer.cornerRadius = self.applicantImage.bounds.size.width/2
        self.applicantImage.layer.masksToBounds = false
        self.applicantImage.layer.shouldRasterize = true
        self.applicantImage.layer.rasterizationScale = UIScreen .main.scale
        self.applicantImage.backgroundColor = UIColor.clear
        self.applicantImage.layer.borderWidth = 0
        self.applicantImage.clipsToBounds = true
        
    }
    
}
