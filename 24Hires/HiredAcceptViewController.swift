//
//  HiredAcceptViewController.swift
//  JobIn24
//
//  Created by Jeekson on 22/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HiredAcceptViewController: UIViewController {

    //MARK:- IBOutlet & IBAction
    @IBOutlet weak var hirerNameLabel       : UILabel!
    @IBOutlet weak var jobDateLabel         : UILabel!
    @IBOutlet weak var jobVenueLabel        : UILabel!
    @IBOutlet weak var noOfDaysLabel        : UILabel!
    @IBOutlet weak var payPerDayLabel       : UILabel!
    @IBOutlet weak var totalBasicPayLabel   : UILabel!
    @IBOutlet weak var tipsAmountLabel      : UILabel!
    @IBOutlet weak var totalPayLabel        : UILabel!
    @IBOutlet weak var hirerImageView       : UIImageView!
    
    @IBAction func acceptButtonPressed(_ sender: Any) {

        let acceptAction = UIAlertAction(title: "ACCEPT", style: .default) { (action) in
            self.acceptOffer()
        }
        showAlertBoxWithAction(title: "Accept Offer", msg: "Are you sure you want to accept the offer?", buttonString: "CANCEL", buttonAction: acceptAction)
    }
    @IBAction func rejectButtonPressed(_ sender: Any) {
        
        let rejectAction = UIAlertAction(title: "REJECT", style: .destructive) { (action) in
            self.rejectOffer()
        }
        showAlertBoxWithAction(title: "Reject Offer", msg: "Are you sure you want to reject the offer?", buttonString: "CANCEL", buttonAction: rejectAction)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Variable Declaration
    let currentUser = Auth.auth().currentUser
    let ref         = Database.database().reference()
    
    var postKey : String?
    var hirerID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        jobVenueLabel.adjustsFontSizeToFitWidth = true
        jobDateLabel.adjustsFontSizeToFitWidth  = true
        
        
        print("\n================== Hired Accept View Controller ================")
        print("PostKey: \(postKey!)")
        print("HirerID: \(hirerID!)")
        
        
        if (postKey != "" && hirerID != ""){
            getPostDetails(hirerID: hirerID!, postKey: postKey!)
        }else{
            let closeView = UIAlertAction(title: "Close", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            DispatchQueue.main.async {
                self.showAlertBoxWithOneAction(title: "", msg: "System encountered some error.", buttonAction: closeView)
            }
        }
    }
    
    //MARK:- Functions
    
    func getPostDetails(hirerID: String, postKey: String){
        
        print("=======================\n Get Posted Job Details\n======================")
        
        let ownUID = currentUser?.uid
        print("Own UID: \(String(describing: ownUID))\n")
        let userPostedHiredApplicatsRef = ref.child("UserPostedHiredApplicants")
        
        userPostedHiredApplicatsRef.child(hirerID).child(postKey).child(ownUID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("\n============\nJob Details\n============")
                print(snapshot)
                
                self.hirerNameLabel.text = snapshot.childSnapshot(forPath: "name").value as? String
                self.jobDateLabel.text   = snapshot.childSnapshot(forPath: "date").value as? String
                self.jobVenueLabel.text  = snapshot.childSnapshot(forPath: "location").value as? String
                self.noOfDaysLabel.text  = snapshot.childSnapshot(forPath: "numdates").value as? String
                self.payPerDayLabel.text = snapshot.childSnapshot(forPath: "basicpay").value as? String
                self.totalBasicPayLabel.text = snapshot.childSnapshot(forPath: "basictotalpay").value as? String
                self.totalPayLabel.text      = snapshot.childSnapshot(forPath: "totalallpay").value as? String

            }
        }
        
        //Get Hirer Profile Image
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
    
    func acceptOffer(){
        
        let ownUID = currentUser?.uid
        
        ref.child("UserActivities").child(hirerID!).child("NewMainNotification").setValue("true")
        ref.child("UserActivities").child(ownUID!).child("Applied").child(postKey!).child("status").setValue("acceptedoffer")
        ref.child("UserActivities").child(hirerID!).child("NewPosted").setValue("true")
        ref.child("UserActivities").child(hirerID!).child("NewApplicant").setValue("true")
        
        ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownUID!).child("offerstatus").setValue("accepted")
        ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownUID!).child("pressed").setValue("false")
        
        ref.child("UserPosted").child(hirerID!).child(postKey!).child("pressed").setValue("false")
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    func rejectOffer(){
        
        let ownUID = currentUser?.uid
        
        ref.child("UserActivities").child(hirerID!).child("NewMainNotification").setValue("true")
        ref.child("UserActivities").child(ownUID!).child("Applied").child(postKey!).child("status").setValue("rejectedoffer")
        ref.child("UserActivities").child(hirerID!).child("NewPosted").setValue("true")
        ref.child("UserActivities").child(hirerID!).child("NewApplicant").setValue("true")
        
        ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownUID!).child("offerstatus").setValue("rejected")
        ref.child("UserPostedHiredApplicants").child(hirerID!).child(postKey!).child(ownUID!).child("pressed").setValue("false")
        
        ref.child("UserPosted").child(hirerID!).child(postKey!).child("pressed").setValue("false")
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
