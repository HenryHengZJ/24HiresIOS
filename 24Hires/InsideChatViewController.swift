//
//  InsideChatViewController.swift
//  JobIn24
//
//  Created by MacUser on 17/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import IQKeyboardManagerSwift

class InsideChatViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{

    @IBOutlet weak var insidechatTableView: UITableView!
    
    @IBOutlet weak var messageArea: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var constTextViewHeight: NSLayoutConstraint!
    
    // we set a variable to hold the contentOffSet before scroll view scrolls
    var lastContentOffset: CGFloat = 0
    
    var messagelist = [InsideChatList]()
    
    var ownerID         : String!
    var ownerName       : String!
    var ownerImage      : String!
    var receiverID      : String!
    var receiverImage   : String!
    var receiverName    : String!
    var lastpostKey     : String!
    var lastonlinetime  : String!
    var uid             : String!
    var firstpostTime       : TimeInterval!
    var placeholderLabel    : MessageLabelPadding!

    
    var loadlimit           = 12
    var firstloadcount      = 0
    var loadingData         = false
    var canStartDetectTop   = false
    var atBottom            = true
    var userBlocked         = false
   
    var pagingindicator     = UIActivityIndicatorView()

    let messageTextViewMaxHeight: CGFloat = 100
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            self.uid = currentUser?.uid
            let ref = Database.database().reference()
            ref.child("UserChatList").child(self.uid).child("UserList").child(self.receiverID).observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    ref.child("UserChatList").child(self.uid).child("Pressed").setValue("true")
                    ref.child("UserChatList").child(self.uid).child("UserList").child(self.receiverID).child("newmessage").setValue("true")
                    
                }
            })
            
            ref.child("ChatRoom").child(self.uid).child(self.uid+"_"+self.receiverID).observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    ref.child("ChatRoom").child(self.uid).child(self.uid+"_"+self.receiverID).child("UnreadMessagePressed").setValue("false")
                    
                }
            })
        }
     }
     
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagelist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        let ref = Database.database().reference()
        
        if (self.uid != nil) {
            
            if(messagelist[indexPath.row].ownerId == self.uid){
                
                var insidetablecell: UITableViewCell!
                
                print("OWN actionTitle \(messagelist[indexPath.row].actionTitle)")
                
                if(messagelist[indexPath.row].actionTitle != nil){
                    
                    let actioncell = tableView.dequeueReusableCell(withIdentifier: "InsideMessageOwnerActionCell", for: indexPath) as! InsideChat_OwnerAction_TableViewCell
                    
                    actioncell.ownerImage.sd_setImage(with: URL(string: self.ownerImage), placeholderImage: UIImage(named: "userprofile_default"))
                    
                    actioncell.ownerMessage.text = messagelist[indexPath.row].actionTitle
                    
                    actioncell.ownerMessage.text = actioncell.ownerMessage.text?.uppercased()
                    
                    if (messagelist[indexPath.row].actionTitle == "booking accepted" || messagelist[indexPath.row].actionTitle == "hired") {
                        actioncell.ownerMessage.backgroundColor = UIColor(red: 69/255, green: 208/255, blue: 37/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "booked talent" || messagelist[indexPath.row].actionTitle == "applied") {
                        actioncell.ownerMessage.backgroundColor = UIColor(red: 253/255, green: 173/255, blue: 34/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "shortlisted" ) {
                        actioncell.ownerMessage.backgroundColor = UIColor(red: 53/255, green: 110/255, blue: 204/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "rejected" || messagelist[indexPath.row].actionTitle == "booking rejected") {
                        actioncell.ownerMessage.backgroundColor = UIColor(red: 255/255, green: 26/255, blue: 39/255, alpha: 1.0)
                    }
                    
                    actioncell.ownerTime.text = messagelist[indexPath.row].chatTime
                    
                    actioncell.titleLabel.text = messagelist[indexPath.row].jobTitle
                    
                    actioncell.descripLabel.text = messagelist[indexPath.row].jobDesc
                    
                    if(messagelist[indexPath.row].postTime != messagelist[indexPath.row].postOldTime){
                        actioncell.pastTimeLabel.text = messagelist[indexPath.row].pastTime
                        actioncell.pastTimeHeight.constant = 15
                        actioncell.pastTimeStackView.isHidden = false
                    }
                    else{
                        actioncell.pastTimeLabel.text = ""
                        actioncell.pastTimeHeight.constant = 0
                        actioncell.pastTimeStackView.isHidden = true
                    }
                    
                    actioncell.tapBtn = {
                        
                        if (self.messagelist[indexPath.row].mainCategory == nil && self.messagelist[indexPath.row].subCategory == nil) {
                            
                            ref.child("Job").child(self.messagelist[indexPath.row].city).child(self.messagelist[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if !snapshot.exists() {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                    
                                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedJob") as! RemovedJob
                                    
                                    self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                }
                                else {
                                    
                                    self.hidesBottomBarWhenPushed = true

                                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                    
                                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
                                    
                                    destinationVC.postid = self.messagelist[indexPath.row].postKey
                                    destinationVC.city = self.messagelist[indexPath.row].city
                                    
                                    self.navigationController?.pushViewController(destinationVC, animated: true)
                                    
                                }
                                
                            })
                            
                        }
                            
                        else {
                            ref.child("Talent").child(self.messagelist[indexPath.row].city).child(self.messagelist[indexPath.row].mainCategory).child(self.messagelist[indexPath.row].subCategory).child(self.messagelist[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if !snapshot.exists() {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                     
                                     let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedTalent") as! RemovedTalent
                                     
                                     self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                }
                                else {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                     
                                     let destinationVC = storyboard.instantiateViewController(withIdentifier: "TalentDetail") as! TalentDetail
                                     
                                     destinationVC.postid = messagelist[indexPath.row].postKey
                                     destinationVC.city = messagelist[indexPath.row].city
                                     destinationVC.mainCategory = messagelist[indexPath.row].mainCategory
                                     destinationVC.subCategory = messagelist[indexPath.row].subCategory
                                     
                                     self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                    
                                }
                                
                            })
                            
                        }
  
                    }

                    insidetablecell = actioncell
                }
                else {
                    let messagecell = tableView.dequeueReusableCell(withIdentifier: "InsideMessageOwnerCell", for: indexPath) as! InsideChat_OwnerMessage_TableViewCell
                    
                    messagecell.ownerImage.sd_setImage(with: URL(string: self.ownerImage), placeholderImage: UIImage(named: "userprofile_default"))
                    
                    messagecell.ownerMessage.text = messagelist[indexPath.row].Message
                    
                    messagecell.ownerTime.text = messagelist[indexPath.row].chatTime
                    
                    if(messagelist[indexPath.row].postTime != messagelist[indexPath.row].postOldTime){
                        messagecell.pastTimeLabel.text = messagelist[indexPath.row].pastTime
                        messagecell.pasTimeHeight.constant = 15
                        messagecell.pastTimeStackView.isHidden = false
                    }
                    else{
                        messagecell.pastTimeLabel.text = ""
                        messagecell.pasTimeHeight.constant = 0
                        messagecell.pastTimeStackView.isHidden = true
                    }
                    
                    insidetablecell = messagecell
                }
                
                tablecell = insidetablecell

            }
            else {
                
                var insidetablecell: UITableViewCell!

                if(messagelist[indexPath.row].actionTitle != nil){
                    
                    let actioncell = tableView.dequeueReusableCell(withIdentifier: "InsideMessageReceiverActionCell", for: indexPath) as! InsideChat_ReceiverAction_TableViewCell
                    
                    actioncell.receiverImage.sd_setImage(with: URL(string: self.receiverImage), placeholderImage: UIImage(named: "userprofile_default"))
                    
                    actioncell.receiverMessage.text = messagelist[indexPath.row].actionTitle
                    
                    actioncell.receiverMessage.text = actioncell.receiverMessage.text?.uppercased()
                    
                    if (messagelist[indexPath.row].actionTitle == "booking accepted" || messagelist[indexPath.row].actionTitle == "hired") {
                        actioncell.receiverMessage.backgroundColor = UIColor(red: 69/255, green: 208/255, blue: 37/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "booked talent" || messagelist[indexPath.row].actionTitle == "applied") {
                        actioncell.receiverMessage.backgroundColor = UIColor(red: 253/255, green: 173/255, blue: 34/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "shortlisted" ) {
                        actioncell.receiverMessage.backgroundColor = UIColor(red: 53/255, green: 110/255, blue: 204/255, alpha: 1.0)
                    }
                    else if (messagelist[indexPath.row].actionTitle == "rejected" || messagelist[indexPath.row].actionTitle == "booking rejected") {
                        actioncell.receiverMessage.backgroundColor = UIColor(red: 255/255, green: 26/255, blue: 39/255, alpha: 1.0)
                    }
                    
                    actioncell.receiverTime.text = messagelist[indexPath.row].chatTime
                    
                    actioncell.titleLabel.text = messagelist[indexPath.row].jobTitle
                    
                    actioncell.descripLabel.text = messagelist[indexPath.row].jobDesc
                    
                    print("RECEIVER postTime \(messagelist[indexPath.row].postTime)")
                    print("RECEIVER postOldTime \(messagelist[indexPath.row].postOldTime)")
                    
                    if(messagelist[indexPath.row].postTime != messagelist[indexPath.row].postOldTime){
                        actioncell.pastTimeLabel.text = messagelist[indexPath.row].pastTime
                        actioncell.pastTimeHeight.constant = 15
                        actioncell.pastTimeStackView.isHidden = false
                    }
                    else{
                        actioncell.pastTimeLabel.text = ""
                        actioncell.pastTimeHeight.constant = 0
                        actioncell.pastTimeStackView.isHidden = true
                    }
                    
                    actioncell.tapBtn = {
                        
                        if (self.messagelist[indexPath.row].mainCategory == nil && self.messagelist[indexPath.row].subCategory == nil) {
                            
                            ref.child("Job").child(self.messagelist[indexPath.row].city).child(self.messagelist[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if !snapshot.exists() {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                     
                                     let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedJob") as! RemovedJob
                                     
                                     self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                }
                                else {
                                    
                                    self.hidesBottomBarWhenPushed = true
                                    
                                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                    
                                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
                                    
                                    destinationVC.postid = self.messagelist[indexPath.row].postKey
                                    destinationVC.city = self.messagelist[indexPath.row].city
                                    
                                    self.navigationController?.pushViewController(destinationVC, animated: true)
                                    
                                }
                                
                            })
                            
                        }
                            
                        else {
                            ref.child("Talent").child(self.messagelist[indexPath.row].city).child(self.messagelist[indexPath.row].mainCategory).child(self.messagelist[indexPath.row].subCategory).child(self.messagelist[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if !snapshot.exists() {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                     
                                     let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedTalent") as! RemovedTalent
                                     
                                     self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                }
                                else {
                                    /*let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                     
                                     let destinationVC = storyboard.instantiateViewController(withIdentifier: "TalentDetail") as! TalentDetail
                                     
                                     destinationVC.postid = messagelist[indexPath.row].postKey
                                     destinationVC.city = messagelist[indexPath.row].city
                                     destinationVC.mainCategory = messagelist[indexPath.row].mainCategory
                                     destinationVC.subCategory = messagelist[indexPath.row].subCategory
                                     
                                     self.navigationController?.pushViewController(destinationVC, animated: true)*/
                                    
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                    insidetablecell = actioncell
                }
                else {
                    
                    let messagecell = tableView.dequeueReusableCell(withIdentifier: "InsideMessageReceiverCell", for: indexPath) as! InsideChat_ReceiverMessage_TableViewCell
                    
                    
                    messagecell.receiverImage.sd_setImage(with: URL(string: self.receiverImage), placeholderImage: UIImage(named: "userprofile_default"))
                    
                    messagecell.receiverMessage.text = messagelist[indexPath.row].Message
                    
                    messagecell.receiverTime.text = messagelist[indexPath.row].chatTime
                    
                    if(messagelist[indexPath.row].postTime != messagelist[indexPath.row].postOldTime){
                        messagecell.pastTimeLabel.text = messagelist[indexPath.row].pastTime
                        messagecell.pasTimeHeight.constant = 15
                        messagecell.pastTimeStackView.isHidden = false
                    }
                    else{
                        messagecell.pastTimeLabel.text = ""
                        messagecell.pasTimeHeight.constant = 0
                        messagecell.pastTimeStackView.isHidden = true
                    }
                    
                    insidetablecell = messagecell
                }
                
                tablecell = insidetablecell
            }

        }
 
        return tablecell
    }
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }

    
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        print("lastSectionIndex \(lastSectionIndex)")
        print("lastRowIndex \(lastRowIndex)")
        print("indexPath.row \(indexPath.row)")
        print("indexPath.row \(self.messagelist.count)")
     
        if indexPath.section ==  lastSectionIndex && indexPath.row == 0 && !loadingData {
            print("this is the first cell")
            loadingData = true
            setHeaderIndicator()
        }
    }*/
    
  
    /*func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let firstVisibleIndexPath = self.insidechatTableView.indexPathsForVisibleRows?[0]
        print("First visible cell section=\(firstVisibleIndexPath?.section), and row=\(firstVisibleIndexPath?.row)")
        if(firstVisibleIndexPath?.row == 0 || firstVisibleIndexPath?.row == 1){
            if(!loadingData){
                print("this is the first cell")
                loadingData = true
                setHeaderIndicator()
            }
        }
    }*/
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == insidechatTableView {
            if insidechatTableView.contentOffset.y < 50 {
                if(canStartDetectTop){
                    if(loadingData){
                        print("this is the top2 cell")
                        //atBottom = false
                        loadingData = false
                        canStartDetectTop = false
                        setHeaderIndicator()
                    }
                }
            }
            let  height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            
            if distanceFromBottom <= height {
                atBottom = true
                //print("atBottom = true")
            }
            else{
                atBottom = false
                //print("atBottom = false")

            }
        }

    }
    

 
    /*func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.insidechatTableView.frame = CGRect(x: self.insidechatTableView.frame.origin.x, y: self.insidechatTableView.frame.origin.y, width: self.insidechatTableView.frame.size.width, height: self.insidechatTableView.frame.size.height - 190);
    
        insidechatTableView.setContentOffset(CGPoint(x:0, y:textView.center.y-60), animated: true)
    }*/
    
    
    /*func textFieldShouldBeginEditing(textField: UITextField) -> bool {
        let txtFieldPosition = textField.convertPoint(textField.bounds.origin, toView: yourTableViewHere)
        let indexPath = yourTablViewHere.indexPathForRowAtPoint(txtFieldPosition)
        if indexPath != nil {
            yourTablViewHere.scrollToRowAtIndexPath(indexPath!, atScrollPosition: .Top, animated: true)
        }
        return true
    }*/
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 )
    }
    
    func getCurrentMillis_000()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            self.uid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserBlock").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.userBlocked = false
                    self.startchatting()
                    return
                }
                
                if snapshot.hasChild(self.receiverID){
                    if snapshot.hasChild(self.uid){
                        self.userBlocked = true
                        self.startchatting()
                    }
                    else{
                        self.userBlocked = false
                        self.startchatting()
                    }
                }
                else{
                    self.userBlocked = false
                    self.startchatting()
                }
                
                
            })

        }
        
    }
    
    
    func startchatting(){
        
        let inputText = messageArea.text
        
        if (inputText == ""){return}
        
        let ref = Database.database().reference()
        
        let newNotification = ref.child("Notification").child("Messages").childByAutoId()
        let notificationKey = newNotification.key
        
        let OwnerChat = ref.child("ChatRoom").child(uid!)
        let ReceiverChat = ref.child("ChatRoom").child(self.receiverID)
        let newReceiverChat = ReceiverChat.child(receiverID+"_"+uid).child("ChatList").childByAutoId()
        let newChatListKey = newReceiverChat.key
        let newOwnerChat = OwnerChat.child(uid+"_"+receiverID).child("ChatList").child(newChatListKey)
        
        let ReceiverChatList = ref.child("UserChatList").child(receiverID).child("UserList")
        let OwnerChatList = ref.child("UserChatList").child(uid!).child("UserList")
        let newReceiverChatList = ReceiverChatList.child(uid!)
        let newUserListKey = newReceiverChatList.key
        let newOwnerChatList = OwnerChatList.child(receiverID)
        
        //let negatedtime = -1*(NSDate().timeIntervalSince1970 * 1000)
        let negatedtime  = -1*(getCurrentMillis())
        let negatedtime_1000  = -1*(getCurrentMillis_000())
        
        var messagedetails = ["negatedtime": negatedtime,
                              "time": ServerValue.timestamp(),
                              "message": inputText!,
                              "ownername": ownerName,
                              "ownerid": ownerID,
                              "receivername": receiverName,
                              "receiverid": receiverID
            ] as [String : Any]
        
        let notificationdetails = ["ownerUid": ownerID,
                                   "receiverUid": receiverID,
                                   "lastmessage": inputText!,
                                   "ownerName": ownerName,
                                   "key": notificationKey
            ] as [String : Any]
        
        //Set notification and red dots
        ref.child("ChatRoom").child(receiverID).child(receiverID+"_"+uid!).child("UnreadMessagePressed").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                
                //If user is first time chat
                ref.child("ChatRoom").child(self.receiverID).child(self.receiverID+"_"+self.uid!).child("UnreadMessagePressed").setValue("false")
                
                //Main red dot at message Tab
                ref.child("UserChatList").child(self.receiverID).child("Pressed").setValue("false")
                
                //Red dot at message list inside message Tab
                ref.child("UserChatList").child(self.receiverID).child("UserList").child(newUserListKey).child("newmessage").setValue("false")
                
                newNotification.setValue(notificationdetails)
                
                //Save notificaitonKeys to receiver account, so when user open apps, these receiverKeys will be retrieved and be deleted
                ref.child("ChatRoom").child(self.receiverID).child(self.receiverID+"_"+self.uid!).child("UnpressedNotification").child(notificationKey).setValue(notificationKey)
            }
                
            else {
                
                //Check if user is opening chat at the same time
                let unreadval = snapshot.value as? String
                
                //If receiver is NOT opening chat window
                if unreadval == "false" {
                    ref.child("ChatRoom").child(self.receiverID).child(self.receiverID+"_"+self.uid!).child("UnreadMessagePressed").setValue("false")
                    
                    //Main red dot at message Tab
                    ref.child("UserChatList").child(self.receiverID).child("Pressed").setValue("false")
                    
                    //Red dot at message list inside message Tab
                    ref.child("UserChatList").child(self.receiverID).child("UserList").child(newUserListKey).child("newmessage").setValue("false")
                    
                    newNotification.setValue(notificationdetails)
                    
                    //Save notificaitonKeys to receiver account, so when user open apps, these receiverKeys will be retrieved and be deleted
                    ref.child("ChatRoom").child(self.receiverID).child(self.receiverID+"_"+self.uid!).child("UnpressedNotification").child(notificationKey).setValue(notificationKey)
                    
                }
                    
                    //If receiver is OPENING chat window
                else if unreadval == "true" {
                    ref.child("ChatRoom").child(self.receiverID).child(self.receiverID+"_"+self.uid!).child("UnreadMessagePressed").setValue("true")
                    
                    ref.child("UserChatList").child(self.receiverID).child("Pressed").setValue("true")
                    
                    ref.child("UserChatList").child(self.receiverID).child("UserList").child(newUserListKey).child("newmessage").setValue("true")
                    
                }
                
            }
            
        })
        
        
        //Set chat box
        ref.child("UserChatList").child(uid!).child("UserList").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                //If user has NO chat conversations before
                messagedetails["oldtime"] = 0
            }
                
            else {
                //Check if user chatlist has receiver conversation or not
                if snapshot.childSnapshot(forPath: self.receiverID).exists(){
                    
                    //Retrieve previous message time
                    let oldtime = snapshot.childSnapshot(forPath: self.receiverID).childSnapshot(forPath: "time").value as? TimeInterval
                    
                    messagedetails["oldtime"] = oldtime
                    
                }
                    
                    //If user has no previous conversation with receiver
                else{
                    
                    messagedetails["oldtime"] = 0
                    
                }
            }
            
            
            //Set new message to ChatRoom
            if(self.userBlocked){
                
                newOwnerChat.setValue(messagedetails, withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
                    
                    if (error != nil) {
                        // handle an error
                    }
                    else{
                        //Update Owner ChatList
                        
                        let ownerchatlistdetails = ["negatedtime": negatedtime_1000,
                                                    "time": ServerValue.timestamp(),
                                                    "lastmessage": inputText!,
                                                    "ownername": self.receiverName,
                                                    "ownerimage": self.receiverImage,
                                                    "ownerid": self.receiverID
                            ] as [String : Any]
                        newOwnerChatList.updateChildValues(ownerchatlistdetails)
                    }
                    
                })
                
            }
            else{
                print(messagedetails)
                newOwnerChat.setValue(messagedetails)
                
                newReceiverChat.setValue(messagedetails,  withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
                    
                    if (error != nil) {
                        // handle an error
                    }
                    else{
                        //Update ChatList
                        let receiverchatlistdetails = ["negatedtime": negatedtime_1000,
                                                       "time": ServerValue.timestamp(),
                                                       "lastmessage": inputText!,
                                                       "ownername": self.ownerName,
                                                       "ownerimage": self.ownerImage,
                                                       "ownerid": self.ownerID
                            ] as [String : Any]
                        newReceiverChatList.updateChildValues(receiverchatlistdetails)
                        
                        let ownerchatlistdetails = ["negatedtime": negatedtime_1000,
                                                    "time": ServerValue.timestamp(),
                                                    "lastmessage": inputText!,
                                                    "ownername": self.receiverName,
                                                    "ownerimage": self.receiverImage,
                                                    "ownerid": self.receiverID
                            ] as [String : Any]
                        newOwnerChatList.updateChildValues(ownerchatlistdetails)
                    }
                    
                })
            }
            
        })
        
        messageArea.text = ""
        self.scrollToBottom()
        
        placeholderLabel.isHidden = !messageArea.text.isEmpty
        
        self.constTextViewHeight.constant = min(125, messageArea.contentSize.height);
        
        let btnImage = UIImage(named: "unpressed_send")
        sendButton.setImage(btnImage , for: .normal)
        sendButton.isEnabled = false
        
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
    
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
        {
            self.view.frame.origin.y = -1*(keyboardSize.height) // Move view 150 points upward
            
        }
        
        scrollToBottom()
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func hideKeyboardWhenTappedTableView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InsideChatViewController.dismisstheKeyboard))
        //tap.cancelsTouchesInView = false
        self.insidechatTableView.addGestureRecognizer(tap)
    }
    
    @objc func dismisstheKeyboard() {
        
        self.messageArea.resignFirstResponder()
        //view.endEditing(true)
    }
 
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let negatedtime  = -1*(getCurrentMillis())
        print("negatedtime = \(negatedtime)")
        
        self.hideKeyboardWhenTappedTableView()
        
        IQKeyboardManager.shared.disabledToolbarClasses.append(InsideChatViewController.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(InsideChatViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(InsideChatViewController.self)
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(InsideChatViewController.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InsideChatViewController.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
     
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let testUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "info.png"), style: .plain, target: self, action: #selector(InsideChatViewController.clickButton))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
 
        messageArea.delegate = self
        insidechatTableView.dataSource = self
        insidechatTableView.delegate = self
        
        // dynamic table view cell height
        insidechatTableView.estimatedRowHeight = insidechatTableView.rowHeight
        insidechatTableView.rowHeight = UITableViewAutomaticDimension
        
        //this is needed to keep label padding in place
        insidechatTableView.setNeedsLayout()
        insidechatTableView.layoutIfNeeded()
        
        //insidechatTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));

        placeholderLabel = MessageLabelPadding()
        placeholderLabel.text = "Type message here.."
        placeholderLabel.font = UIFont.systemFont(ofSize: (messageArea.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        messageArea.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (messageArea.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !messageArea.text.isEmpty
        
        messageArea.layer.cornerRadius = 15
        messageArea.layer.borderWidth = 1
        messageArea.layer.borderColor = UIColor.lightGray.cgColor
        messageArea.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        sendButton.isEnabled = false
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            self.uid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").observe(.value, with: { (snapshot) in
               
                if !snapshot.exists() {
                    self.lastonlinetime = ""
                    self.setupTitleView()
                    return
                }
                
                if snapshot.childSnapshot(forPath: self.receiverID).exists() {
                    
                    if snapshot.childSnapshot(forPath: self.receiverID).childSnapshot(forPath: "Lastonline").exists() {
                        
                        if let getTime = snapshot.childSnapshot(forPath: self.receiverID).childSnapshot(forPath: "Lastonline").value as? TimeInterval {
                           
                            let postonlinedate = NSDate(timeIntervalSince1970: getTime/1000)
                            
                            var stringonlinedate:String! = TimeAgoHelper.timeAgoSinceDate(postonlinedate as Date, currentDate: Date(), numericDates: true)
                         
                            self.lastonlinetime = "Last online \(stringonlinedate!)"
                            self.setupTitleView()
                        }
                        
                    }
                        
                    else if snapshot.childSnapshot(forPath: self.receiverID).childSnapshot(forPath: "Connections").exists() {
                        
                        self.lastonlinetime = "Online"
                        self.setupTitleView()
                    }
                        
                    else{
                        
                        self.lastonlinetime = ""
                        self.setupTitleView()
                    }
                }
                else{
                    self.lastonlinetime = ""
                    self.setupTitleView()
                }
                
            })
            
            var firstload = true
            var firstload2 = true
            
            ref.child("ChatRoom").child(uid).child(uid+"_"+receiverID).child("ChatList").queryLimited(toLast: UInt(self.loadlimit)).observe(.childAdded, with: { (snapshot) in
              
                if !snapshot.exists() {return}
                
                self.firstloadcount = self.firstloadcount + 1

                guard let restDict = snapshot.value as? [String:Any] else
                {
                    print("Snapshot is nil hence no data returned")
                    return
                }
                let messagelistlist = InsideChatList()
                
                if  let Message = restDict["message"] as? String {
                    print(Message)
                    messagelistlist.Message = Message
                }
                
                if  let ownerid = restDict["ownerid"] as? String {
                     messagelistlist.ownerId = ownerid
                }
                
                if  let postNegatedTime = restDict["negatedtime"] as? TimeInterval {
                    if(firstload){
                        firstload = false
                        self.firstpostTime = postNegatedTime
                       
                    }
                }
                
                if  let postTime = restDict["time"] as? TimeInterval {
                    
                    let postDate = Date(timeIntervalSince1970: postTime/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "dd MMM HH:mm" //Specify your format that you want
                    let strPastDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
                    let nowChatTime = dateFormatter.string(from: postDate)
                    
                    messagelistlist.postTime = strDate
                    messagelistlist.pastTime = strPastDate
                    messagelistlist.chatTime = nowChatTime
                }
                
                if  let postOldTime = restDict["oldtime"] as? TimeInterval {
                    
                    let postOldDate = Date(timeIntervalSince1970: postOldTime/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strOldDate = dateFormatter.string(from: postOldDate)
                   
                    messagelistlist.postOldTime = strOldDate
                }
                
                if  let actionTitle = restDict["actionTitle"] as? String {
                    messagelistlist.actionTitle = actionTitle
                }
                
                if  let jobTitle = restDict["jobTitle"] as? String {
                    messagelistlist.jobTitle = jobTitle
                }
                
                if  let jobDesc = restDict["jobDesc"] as? String {
                    messagelistlist.jobDesc = jobDesc
                }
                
                if  let city = restDict["city"] as? String {
                    messagelistlist.city = city
                }
                
                if  let postKey = restDict["postKey"] as? String {
                    messagelistlist.postKey = postKey
                }
                
                if  let mainCategory = restDict["mainCategory"] as? String {
                    messagelistlist.mainCategory = mainCategory
                }
                
                if  let subCategory = restDict["subCategory"] as? String {
                    messagelistlist.subCategory = subCategory
                }
                /*if  let Message = restDict["message"] as? String,
                    let ownerid = restDict["ownerid"] as? String,
                    let postNegatedTime = restDict["negatedtime"] as? TimeInterval,
                    let postTime = restDict["time"] as? TimeInterval,
                    let postOldTime = restDict["oldtime"] as? TimeInterval
                    
                {
                    print("LatestMessage: \(Message)")
                    
                    let postDate = Date(timeIntervalSince1970: postTime/1000)
                    let postOldDate = Date(timeIntervalSince1970: postOldTime/1000)
                    let postNegatedDate = Date(timeIntervalSince1970: postNegatedTime/1000)
                    
                    let dateFormatter = DateFormatter()
                    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strDate = dateFormatter.string(from: postDate)
                    let strOldDate = dateFormatter.string(from: postOldDate)
                    
                    dateFormatter.dateFormat = "dd MMM HH:mm" //Specify your format that you want
                    let strPastDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
                    let nowChatTime = dateFormatter.string(from: postDate)
        
                    messagelistlist.Message = Message
                    messagelistlist.ownerId = ownerid
                    messagelistlist.postTime = strDate
                    messagelistlist.postOldTime = strOldDate
                    messagelistlist.chatTime = nowChatTime
                    messagelistlist.pastTime = strPastDate
                    
                    if(firstload){
                        firstload = false
                        self.firstpostTime = postNegatedTime
                    }
                    
                    self.messagelist.append(messagelistlist)
                    
                }*/

                self.messagelist.append(messagelistlist)
            
                self.insidechatTableView.reloadData()
                
                if(self.atBottom){
                    
                    if self.messagelist.count > 0 {
                      
                        self.scrollToBottom()
                        
                    }
                }
                
                if(self.firstloadcount == self.loadlimit){
                    
                    self.loadingData = true
                    self.canStartDetectTop = true
                    self.scrollToBottom()
                    
                }
               
            })
            
            /*ref.child("ChatRoom").child(uid).child(uid+"_"+receiverID).child("ChatList").queryLimited(toLast: UInt(loadlimit)).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
               
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let messagelistlist = InsideChatList()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if  let Message = restDict["message"] as? String,
                        let ownerid = restDict["ownerid"] as? String,
                        let postNegatedTime = restDict["negatedtime"] as? TimeInterval,
                        let postTime = restDict["time"] as? TimeInterval,
                        let postOldTime = restDict["oldtime"] as? TimeInterval
                   
                     {
                        let postDate = Date(timeIntervalSince1970: postTime/1000)
                        let postOldDate = Date(timeIntervalSince1970: postOldTime/1000)
                        let postNegatedDate = Date(timeIntervalSince1970: postNegatedTime/1000)
                        
                        let dateFormatter = DateFormatter()
                        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                        let strDate = dateFormatter.string(from: postDate)
                        let strOldDate = dateFormatter.string(from: postOldDate)
                        
                        dateFormatter.dateFormat = "dd MMM HH:mm" //Specify your format that you want
                        let strPastDate = dateFormatter.string(from: postDate)
                        
                        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
                        let nowChatTime = dateFormatter.string(from: postDate)
                        
                        
                        messagelistlist.Message = Message
                        messagelistlist.ownerId = ownerid
                        messagelistlist.postTime = strDate
                        messagelistlist.postOldTime = strOldDate
                        messagelistlist.chatTime = nowChatTime
                        messagelistlist.pastTime = strPastDate
                        
                        if(firstload2){
                            firstload2 = false
                            self.firstpostTime = postNegatedTime
                        }
                        
                        self.messagelist.append(messagelistlist)

                    }
                }
                
                self.insidechatTableView.reloadData()
                
                if self.messagelist.count > 0 {
                    self.insidechatTableView.scrollToRow(at: IndexPath(item:self.messagelist.count-1, section: 0), at: .bottom, animated: false)
                    self.canStartDetectTop = true
                }
                //let bottomOffset = CGPoint(x: 0, y: self.insidechatTableView.contentSize.height - self.insidechatTableView.frame.size.height)
                //self.insidechatTableView.setContentOffset(bottomOffset, animated: false)
                //self.scrollToBottom()
                
            })*/
            
            
            ref.child("ChatRoom").child(uid).child(uid+"_"+receiverID).child("UnpressedNotification").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if  let notifykey = rest.key as? String{
                        ref.child("Notification").child("Messages").child(notifykey).removeValue(completionBlock: { (error:Error?, ref:DatabaseReference!) in
                            if (error != nil) {
                                // handle an error
                            }
                            else{
                                ref.child("ChatRoom").child(self.uid).child(self.uid+"_"+self.receiverID).child("UnpressedNotification").child(notifykey).removeValue()
                            }
                        })
                        
                    }
                }
                
            })
            
        }
    
    }
    
    @objc func clickButton(){
        
       
        // create the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Clear Chat History", style: UIAlertActionStyle.default, handler: { action in
            
            self.ClearChat()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Block User", style: UIAlertActionStyle.destructive, handler: { action in
            
            self.BlockUser()
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func BlockUser(){
        // create the alert
        let alert = UIAlertController(title: "Block User", message: "Block \(receiverName!) ? Blocked contact will no longer be able to send you messages", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Block", style: UIAlertActionStyle.default, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                self.uid = currentUser?.uid
                let ref = Database.database().reference()
                
                ref.child("UserBlock").child(self.uid).child(self.receiverID).setValue("true")
                ref.child("ChatRoom").child(self.uid).child(self.uid+"_"+self.receiverID).removeValue()
                ref.child("UserChatList").child(self.uid).child("UserList").child(self.receiverID).removeValue()
                
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
       
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func ClearChat(){
        
        // create the alert
        let alert = UIAlertController(title: "Clear Chat", message: "Are you sure you want to clear this chat conversation?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Clear", style: UIAlertActionStyle.default, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                self.uid = currentUser?.uid
                let ref = Database.database().reference()
               
                ref.child("ChatRoom").child(self.uid).child(self.uid+"_"+self.receiverID).removeValue()
            ref.child("UserChatList").child(self.uid).child("UserList").child(self.receiverID).child("lastmessage").removeValue()
                
                ref.child("UserChatList").child(self.uid).child("UserList").child(self.receiverID).child("time").setValue(0)

                self.messagelist.removeAll()
                self.insidechatTableView.reloadData()
    
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        
        placeholderLabel.isHidden = !messageArea.text.isEmpty
   
        self.constTextViewHeight.constant = min(125, textView.contentSize.height);
        
        if(textView.text == ""){
            let btnImage = UIImage(named: "unpressed_send")
            sendButton.setImage(btnImage , for: .normal)
            sendButton.isEnabled = false
        }
        else{
            let btnImage = UIImage(named: "pressed_send")
            sendButton.setImage(btnImage , for: .normal)
            sendButton.isEnabled = true
        }
        
        
    }
    
    func scrollToBottom(){
        
        if (self.messagelist.count > 0) {
            let indexPath = IndexPath(row: self.messagelist.count - 1, section:0)
            self.insidechatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        /*DispatchQueue.global(qos: .background).async {
            let indexPath = IndexPath(row: self.messagelist.count - 1, section:0)
            self.insidechatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMoreData(){
       
        let ref = Database.database().reference()
        
        var beforeContentSize: CGSize!
        var afterContentSize: CGSize!
        var afterContentOffset: CGPoint!
        var newContentOffset: CGPoint!
        
   
        var firstkey = true
        var counttime = 1
        var postoldTime: TimeInterval!
        var postoldKey: String!
        
        ref.child("ChatRoom").child(uid).child(uid+"_"+receiverID).child("ChatList").queryOrdered(byChild: "negatedtime").queryStarting(atValue: self.firstpostTime).queryLimited(toFirst: UInt(loadlimit)).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                counttime += 1
                
                let messagelistlist = InsideChatList()
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                if  let Message = restDict["message"] as? String {
                    messagelistlist.Message = Message
                    print("load More Message \(Message)")
                }
                
                if  let ownerid = restDict["ownerid"] as? String {
                    messagelistlist.ownerId = ownerid
                }
                
                if  let postNegatedTime = restDict["negatedtime"] as? TimeInterval {
                   
                    self.firstpostTime = postNegatedTime
                    
                }
                
                if  let postTime = restDict["time"] as? TimeInterval {
                    
                    let postDate = Date(timeIntervalSince1970: postTime/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "dd MMM HH:mm" //Specify your format that you want
                    let strPastDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
                    let nowChatTime = dateFormatter.string(from: postDate)
                    
                    messagelistlist.postTime = strDate
                    messagelistlist.pastTime = strPastDate
                    messagelistlist.chatTime = nowChatTime
                }
                
                if  let postOldTime = restDict["oldtime"] as? TimeInterval {
                    
                    let postOldDate = Date(timeIntervalSince1970: postOldTime/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strOldDate = dateFormatter.string(from: postOldDate)
                    
                    messagelistlist.postOldTime = strOldDate
                }
                
                if  let actionTitle = restDict["actionTitle"] as? String {
                    messagelistlist.actionTitle = actionTitle
                }
                
                if  let jobTitle = restDict["jobTitle"] as? String {
                    messagelistlist.jobTitle = jobTitle
                    print("load More jobTitle \(jobTitle)")
                }
                
                if  let jobDesc = restDict["jobDesc"] as? String {
                    messagelistlist.jobDesc = jobDesc
                }
                
                if  let city = restDict["city"] as? String {
                    messagelistlist.city = city
                }
                
                if  let postKey = restDict["postKey"] as? String {
                    messagelistlist.postKey = postKey
                }
                
                if  let mainCategory = restDict["mainCategory"] as? String {
                    messagelistlist.mainCategory = mainCategory
                }
                
                if  let subCategory = restDict["subCategory"] as? String {
                    messagelistlist.subCategory = subCategory
                }

                if(firstkey){
                    firstkey = false
                }
                else{
                    
                    self.messagelist.insert(messagelistlist, at: 0)
                    
                    let messagekey = rest.key as? String
                    self.lastpostKey = messagekey
                    
                   
                    if(counttime >= self.loadlimit){
                        if(messagekey == postoldKey){
                            print("loadfalse")
                            self.loadingData = false
                        }
                        else{
                            print("loadtrue")
                            self.loadingData = true
                        }
                    }
                    
                    postoldKey = messagekey

                }
                
                /*if  let Message = restDict["message"] as? String,
                    let postNegatedTime = restDict["negatedtime"] as? TimeInterval,
                    let postTime = restDict["time"] as? TimeInterval,
                    let postOldTime = restDict["oldtime"] as? TimeInterval,
                    let ownerid = restDict["ownerid"] as? String,
                    let messagekey = rest.key as? String
                    
                {
                    
                    let postDate = Date(timeIntervalSince1970: postTime/1000)
                    let postOldDate = Date(timeIntervalSince1970: postOldTime/1000)
                    let postNegatedDate = Date(timeIntervalSince1970: postNegatedTime/1000)
                   
                    let dateFormatter = DateFormatter()
                    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "yyyyMMdd" //Specify your format that you want
                    let strDate = dateFormatter.string(from: postDate)
                    let strOldDate = dateFormatter.string(from: postOldDate)
                    
                    dateFormatter.dateFormat = "dd MMM HH:mm" //Specify your format that you want
                    let strPastDate = dateFormatter.string(from: postDate)
                    
                    dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
                    let nowChatTime = dateFormatter.string(from: postDate)
                    
                    
                    messagelistlist.Message = Message
                    messagelistlist.ownerId = ownerid
                    messagelistlist.postTime = strDate
                    messagelistlist.postOldTime = strOldDate
                    messagelistlist.chatTime = nowChatTime
                    messagelistlist.pastTime = strPastDate
                  
                    
                    if(firstkey){
                        firstkey = false
                    }
                    else{
                      
                        self.messagelist.insert(messagelistlist, at: 0)
                        //self.messagelist.append(messagelistlist)
                        //self.firstpostTime = postNegatedTime
                        self.lastpostKey = messagekey
                        
                        print("messagekey \(messagekey)")
                        print("postoldKey \(postoldKey)")
                        
                        if(counttime >= self.loadlimit){
                            if(messagekey == postoldKey){
                                print("loadtrue")
                                self.loadingData = true
                            }
                            else{
                                print("loadfalse")
                                self.loadingData = false
                            }
                        }
                        
                        postoldKey = messagekey
                        
                        /*if(counttime >= self.loadlimit){
                            if(postTime == postoldTime){
                                print("loadtrue")
                                self.loadingData = true
                            }
                            else{
                                print("loadfalse")
                                self.loadingData = false
                            }
                        }
                        
                        postoldTime = postTime*/
                        
                    }
                    
                }*/
            
            }
            
            
            beforeContentSize = self.insidechatTableView.contentSize
            self.insidechatTableView.reloadData()
            afterContentSize = self.insidechatTableView.contentSize
            afterContentOffset = self.insidechatTableView.contentOffset
            newContentOffset = CGPoint(x:afterContentOffset.x, y:afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
            self.insidechatTableView.contentOffset = newContentOffset
            self.pagingindicator.stopAnimating()
            self.insidechatTableView.tableHeaderView = nil
            self.insidechatTableView.tableHeaderView?.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.canStartDetectTop = true
            }
            
            
        })
        
        ref.removeAllObservers()
        
    }
    
    private func setHeaderIndicator(){
        
        pagingindicator.activityIndicatorViewStyle = .gray
        pagingindicator.startAnimating()
        pagingindicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: insidechatTableView.bounds.width, height: CGFloat(44))
        
        self.insidechatTableView.tableHeaderView = pagingindicator
        self.insidechatTableView.tableHeaderView?.isHidden = false
        
        loadMoreData()
        
    }
    
    private func setupTitleView() {
        let centerWidth = UIScreen.main.bounds.width/2
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: centerWidth, height: 44))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: centerWidth, height: 44))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.textAlignment = .center
        
        label.textColor = .white
        if(self.lastonlinetime == ""){
            label.text = self.receiverName
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
        }
        else{
            label.text = self.receiverName + "\n\(self.lastonlinetime!)"
            label.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
        wrapperView.addSubview(label)
        self.navigationItem.titleView = wrapperView
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
