//
//  ApplicantTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 09/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FirebaseDatabase
import FirebaseAuth

class ApplicantTableViewCell: UITableViewCell {

    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var applicantImage: UIImageView!
    
    @IBOutlet weak var applicantName: UILabel!
    
    @IBOutlet weak var applicantLocation: UILabel!
    
    @IBOutlet weak var workTitle1: UILabel!
    
    @IBOutlet weak var workPlace1: UILabel!
    
    @IBOutlet weak var workTitle2: UILabel!

    @IBOutlet weak var workPlace2: UILabel!
  
    @IBOutlet weak var timerleftlbl: UILabel!
    
    @IBOutlet weak var shortlistedView: UIView!
    
    var endDate: Date!
    
    var nowDate: Date!
    
    var WaitingOver: Bool!
    
    var applieduserUid: String!
    
    var postKey: String!
    
    func decrementnewapplicant(userid:String!, postKey:String!){
        
        let ref = Database.database().reference()
        let refDecrement = ref.child(userid).child("Posted").child(postKey)
        
        refDecrement.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            if var data = currentData.value as? [String: Any] {
                var count = data["newapplicantscount"] as? Int ?? 0
                count -= 1
                data["newapplicantscount"] = count
                
                currentData.value = data
            }
            
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func decrementapplicant(userid:String!, postKey:String!){
        
        let ref = Database.database().reference()
        let refDecrement = ref.child(userid).child("Posted").child(postKey)
        
        refDecrement.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            if var data = currentData.value as? [String: Any] {
                var count = data["applicantscount"] as? Int ?? 0
                count -= 1
                data["applicantscount"] = count
                
                currentData.value = data
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
                
                let xstrTimeLeft = String(format: "%02i:%02i:%02i", cgfloathours, minutes, seconds)
                
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
                        
                        //delete applicant and -1 applicantscount
                    ref.child("UserActivities").child(uid!).child("Posted").child(self.postKey).child("applicants").child(self.applieduserUid).removeValue()
                        
                        self.decrementapplicant(userid: uid!, postKey: self.postKey)
                        
                        //check if applicant is in new applicant list, if yes, delete and -1 newapplicantscount
                        
                        ref.child("UserActivities").child(uid!).child("Posted").child(self.postKey).observeSingleEvent(of: .value, with: { snapshot in
                        
                            if !snapshot.hasChild("newapplicants") {return}
                        
                            if !snapshot.childSnapshot(forPath: "newapplicants").hasChild(self.applieduserUid) {return}
                        
                            self.decrementnewapplicant(userid: uid!, postKey: self.postKey)
                        ref.child("UserActivities").child(uid!).child("Posted").child(self.postKey).child("newapplicants").child(self.applieduserUid).removeValue()
                            
                        })
                        
                        //notified applicants that you are rejected if applicant is not shortlisted yet
                        
                        ref.child("UserActivities").child(self.applieduserUid).child("Applied").observeSingleEvent(of: .value, with: { snapshot in
                            
                            if !snapshot.hasChild(self.postKey) {return}
                            
                            if !snapshot.childSnapshot(forPath: self.postKey).hasChild("rejected") {return}
                            
                            if let rejectedval = snapshot.childSnapshot(forPath: self.postKey).childSnapshot(forPath: "rejected").value as? String{
                                
                            
                                if(rejectedval == "false"){
                                    
                                    ref.child("UserActivities").child(self.applieduserUid).child("NewMainNotification").setValue("true")
                                    ref.child("UserActivities").child(self.applieduserUid).child("NewApplied").setValue("true")
                                ref.child("UserActivities").child(self.applieduserUid).child("Applied").child(self.postKey).child("rejected").setValue("true")
                                    
                                    
                                }
                            
                            }
                            
                        })
                        
                    }
                    
                }
                
                
                
            }
        }
        else {
            
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(ApplicantTableViewCell.updateUI), name: Notification.Name("ApplicantCellUpdate"), object: nil)
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
