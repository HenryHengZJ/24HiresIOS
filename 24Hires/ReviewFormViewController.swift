//
//  ReviewFormViewController.swift
//  24Hires
//
//  Created by Jeekson Choong on 28/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class ReviewFormViewController: UIViewController,UITextViewDelegate, NVActivityIndicatorViewable {
    
    //MARK:- IBAction & IBOutlet & Declaration
    @IBOutlet weak var reviewFormStackView  : UIStackView!
    @IBOutlet weak var ratingStarView       : CosmosView!
    @IBOutlet weak var commentTextView      : UITextView!
    @IBOutlet weak var bottomConstraints    : NSLayoutConstraint!
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if ReachabilityTest.isConnectedToNetwork(){
            submitFeedback()
        }else{
            noInternetAlert()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var editFeedback        = false
    var reviewReceipientUID = ""
    var postKey             = ""
    var fromwhichVC         = ""
    var oldRating           = ""
    var defaultComment      = "Leave your comment here..."
    
    var userComment     = String()
    
    let userReviewRef   = Database.database().reference().child("UserReview")
    let userActivityRef = Database.database().reference().child("UserActivities")
    let userAccountRef  = Database.database().reference().child("UserAccount")
    let userPostedHiredApplicants  = Database.database().reference().child("UserPostedHiredApplicants")
    
    //MARK:- Override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimating(CGSize(width: 40, height: 40),
                       type: NVActivityIndicatorType(rawValue: 17),
                       color: UIColor.init(red: 103/255, green: 184/255, blue: 237/255, alpha: 1.0),
                       backgroundColor: UIColor.black.withAlphaComponent(0.8),
                       textColor: .white)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("===== Review Form ======")
        print("[Hirer ID]   : \(reviewReceipientUID)")
        print("[post Key]   : \(postKey)\n")
        
        ratingStarView.settings.fillMode = .full
        
        checkInternet()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- Delegates
    @objc func keyboardWillShow(notification:NSNotification) {
        //        adjustingHeight(show: true, notification: notification)
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= (keyboardSize.height-100)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        //        adjustingHeight(show: false, notification: notification)
        
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print(textView.text)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        userComment = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text       = defaultComment
            textView.textColor  = UIColor.lightGray
            if editFeedback{
                userComment     = defaultComment
            }else{
                userComment     = ""
            }
            
        }else{
            userComment = textView.text
        }
        
        print(userComment)
    }
    
    //MARK:- Functions
    func setupLoadingIndicator(visible: Bool){
        let loadingBall     = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 40, height: 40))
        loadingBall.type    = .ballPulseSync
        
        if visible{
            loadingBall.startAnimating()
        }else{
            loadingBall.stopAnimating()
        }
    }
    
    func checkInternet(){
        if ReachabilityTest.isConnectedToNetwork(){
            pageSetup()
        }else{
            let closeAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
                self.stopAnimating()
            }
            DispatchQueue.main.async {
                self.noInternetAlertForceRetry(buttonAction: closeAction)
                
            }
        }
    }
    
    
    
    func pageSetup(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        commentTextView.delegate            = self
        commentTextView.layer.borderWidth   = 1.0
        commentTextView.layer.borderColor   = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
        commentTextView.textColor           = UIColor.lightGray
        commentTextView.text                = "Leave your comment here..."
        
        getOldReviewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getOldReviewData(){
        let ownUID = Auth.auth().currentUser?.uid
        
        print("\n=====Geting Previous Review Data=====\n")
        userReviewRef.child(reviewReceipientUID).child("Review").child(ownUID!).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists(){
                let previousRating = snapshot.childSnapshot(forPath: "rating").value as? Double
                let previousComment = snapshot.childSnapshot(forPath: "reviewmessage").value as? String
                
                print("[Rating] : \(previousRating!)")
                print("[Comment]: \(previousComment!)\n")
                
                self.ratingStarView.rating  = previousRating!
                self.commentTextView.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                
                if previousComment != "none"{
                    self.defaultComment         = previousComment!
                    self.commentTextView.text   = previousComment
                }
                
                switch Int(previousRating!){
                case 2:
                    self.oldRating = "Rate2"
                    break
                case 3:
                    self.oldRating = "Rate3"
                    break
                case 4:
                    self.oldRating = "Rate4"
                    break
                case 5:
                    self.oldRating = "Rate5"
                    break
                default:
                    self.oldRating = "Rate1"
                    
                }
                self.editFeedback = true
            }else{
                print("[Previous Review Data]: No Previous Review Data Obtained.\n=====\n")
                self.editFeedback = false
            }
            //            self.setupLoadingIndicator(visible: false)
            self.stopAnimating()
        }
    }
    
    func increaseRating(newRating: String){
        let ownUID = Auth.auth().currentUser?.uid
        let newReviewRef = userReviewRef.child(reviewReceipientUID).child("Review")
        
        userReviewRef.child(reviewReceipientUID).child(newRating).runTransactionBlock({ (currentData) -> TransactionResult in
            
            let newValue: Int
            
            if let existingValue = (currentData.value as? NSNumber)?.intValue {
                newValue = existingValue + 1
                print("data1 =\(newValue)")
            } else {
                newValue = 1
                print("data2 =\(newValue)")
            }
            
            currentData.value = NSNumber(value: newValue)
            
            
            /*if var data = currentData.value as? [String:Any]{
             
             if var previousCount = data[newRating] as? Int {
             data[newRating] = previousCount += 1
             //  currentData.value = data
             print("data1 =\(data)")
             }else{
             data[newRating] = 1
             //  currentData.value = data
             print("data2 =\(data)")
             }
             }
             else {
             var data = [:] as [String : Any]
             data[newRating] = 1
             // currentData.value = data
             print("data3 =\(data)")
             }*/
            
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, status, snapshot) in
            if error == nil && status == true{
                
                self.userReviewRef.child(self.reviewReceipientUID).child("Notification").setValue("true")
                
                if self.fromwhichVC == "Applied" {
                    self.userActivityRef.child(ownUID!).child("Applied").child(self.postKey).child("reviewed").setValue("true")
                }
                else if self.fromwhichVC == "Hirer" {
                    self.userPostedHiredApplicants.child(ownUID!).child(self.postKey).child(self.reviewReceipientUID).child("reviewed").setValue("true")
                }
                
                self.userAccountRef.child(ownUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    
                    if snapshot.exists() && snapshot.value != nil{
                        var reviewData = [String : Any]()
                        
                        reviewData["time"]      = ServerValue.timestamp()
                        reviewData["userimage"] = snapshot.childSnapshot(forPath: "image").value as? String
                        reviewData["username"]  = snapshot.childSnapshot(forPath: "name").value as? String
                        reviewData["rating"]    = Int(self.ratingStarView.rating)
                        
                        print(self.userComment)
                        if self.userComment == ""{
                            reviewData["reviewmessage"] = ""
                        }else{
                            reviewData["reviewmessage"] = self.userComment
                        }
                        
                        print("[Submit Review Data]: \(reviewData)")
                        newReviewRef.child(ownUID!).setValue(reviewData, withCompletionBlock: { (error, ref) in
                            
                            self.stopAnimating()
                            
                            if error == nil {
                                DispatchQueue.main.async {
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    self.showAlertBoxWithOneAction(title: "Review Submitted", msg: "", buttonAction: okAction)
                                    
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    self.showAlertBoxWithOneAction(title: "Review Failed to Submit", msg: "", buttonAction: okAction)
                                    
                                }
                            }
                        })
                    }
                })
            }
            else {
                self.stopAnimating()
                DispatchQueue.main.async {
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.showAlertBoxWithOneAction(title: "Review Failed to Submit", msg: "", buttonAction: okAction)
                    
                }
            }
        }
    }
    
    func deleteRating(oldRating: String, newRating: String){
        
        userReviewRef.child(reviewReceipientUID).child(oldRating).runTransactionBlock({ (currentData) -> TransactionResult in
            
            let newValue: Int
            
            if let existingValue = (currentData.value as? NSNumber)?.intValue {
                newValue = existingValue - 1
                print("delete data1 =\(newValue)")
                
                currentData.value = NSNumber(value: newValue)
            }
            
            
            /*if var data = currentData.value as? [String: Any] {
             var reduceCount     = data[oldRating] as? Int ?? 0
             reduceCount         -= 1
             data[oldRating]     = reduceCount
             print("deletedata1 =\(data)")
             // currentData.value   = data
             }*/
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, status, snapshot) in
            if error == nil && status == true {
                //perform increase for new rating
                self.increaseRating(newRating: newRating)
            }
        }
    }
    
    func submitFeedback(){
        
        //Get Review
        let userRating      = ratingStarView.rating
        var userRatingStr   = ""
        if userRating<0 {
            showAlertBox(title: "Invalid star rating", msg: "Star rating has be at least one", buttonString: "Ok")
        }else{
            startAnimating(CGSize(width: 40, height: 40),
                           message: "Submitting...",
                           type: NVActivityIndicatorType(rawValue: 17),
                           color: UIColor.init(red: 103/255, green: 184/255, blue: 237/255, alpha: 1.0),
                           backgroundColor: UIColor.black.withAlphaComponent(0.8),
                           textColor: .white)
            
            switch userRating {
            case 2 :
                userRatingStr = "Rate2"
                break
            case 3 :
                userRatingStr = "Rate3"
                break
            case 4 :
                userRatingStr = "Rate4"
                break
            case 5 :
                userRatingStr = "Rate5"
                break
            default:
                userRatingStr = "Rate1"
                break
            }
            
            if editFeedback{
                //Delete Previous rating and update new
                deleteRating(oldRating: oldRating, newRating: userRatingStr)
            }else{
                //Submit New Feedback
                increaseRating(newRating: userRatingStr)
            }
            
        }
    }
    
}


//Unused
//    func adjustingHeight(show:Bool, notification:NSNotification) {
//        // 1
//        var userInfo = notification.userInfo!
//        // 2
//        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        // 3
//        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
//        // 4
//        let changeInHeight = (keyboardFrame.height + 40) * (show ? 1 : -1)
//        //5
//        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
//            self.bottomConstraints.constant += changeInHeight
//        })
//
//    }



