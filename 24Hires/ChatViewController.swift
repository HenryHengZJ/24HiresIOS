//
//  ChatViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/26/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var noChatView: UIView!
    
    var messagelist = [MessageList]()
    
    var postkey: String!
    
    var receiverID: String!
    var receiverImage: String!
    var receiverName: String!
    
    var ownerID: String!
    var ownerImage: String!
    var ownerName: String!
    
    var lastFirstTime: TimeInterval!
    var firstload = false

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagelist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let messagecell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        
        messagecell.profileImage.sd_setImage(with: URL(string: self.messagelist[indexPath.row].profileImage), placeholderImage: UIImage(named: "userprofile_default"))
        
        //messagecell.profileImage.downloadprofileImage(from: self.messagelist[indexPath.row].profileImage)
    
        messagecell.profileName.text = messagelist[indexPath.row].profileName
        
        let newMessage = messagelist[indexPath.row].newMessage
        
        if (messagelist[indexPath.row].lastMessage == nil){
            messagecell.lastMessage.text = ""
        }
        else{
            messagecell.lastMessage.text = messagelist[indexPath.row].lastMessage
        }

        
        if (newMessage != nil){
            if (messagelist[indexPath.row].newMessage == "true" ){
                // no new message
                messagecell.notificationView.isHidden = true
                messagecell.lastMessage.textColor = UIColor.darkGray
                messagecell.lastTime.textColor = UIColor.darkGray
                
            }
            else if (messagelist[indexPath.row].newMessage == "false") {
                messagecell.notificationView.isHidden = false
                messagecell.lastMessage.textColor = UIColor.black
                messagecell.lastTime.textColor = UIColor.red
                
            }
        }else{
            messagecell.notificationView.isHidden = true
            messagecell.lastMessage.textColor = UIColor.darkGray
            messagecell.lastTime.textColor = UIColor.darkGray
            print("New Message = Nil")
        }
        
        messagecell.lastTime.text = messagelist[indexPath.row].lastTime
        
        tablecell = messagecell

        return tablecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.receiverID = messagelist[indexPath.row].profileId
        self.receiverImage = messagelist[indexPath.row].profileImage
        self.receiverName = messagelist[indexPath.row].profileName
        
        if(self.receiverID != nil && self.receiverImage != nil && self.ownerID != nil && self.ownerImage != nil && self.receiverName != nil){
            
            // Post a notification
            let ref = Database.database().reference()
            ref.child("UserChatList").child(self.ownerID).child("Pressed").observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    ref.child("UserChatList").child(self.ownerID).child("Pressed").setValue("true")
                    
                }
            })
            
            ref.child("ChatRoom").child(self.ownerID).child(self.ownerID+"_"+self.receiverID).observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    ref.child("ChatRoom").child(self.ownerID).child(self.ownerID+"_"+self.receiverID).child("UnreadMessagePressed").setValue("true")
                    
                }
            })
            
            self.hidesBottomBarWhenPushed = true
            NotificationCenter.default.post(name: Notification.Name("hidebutton"), object: nil, userInfo: nil)
            self.performSegue(withIdentifier: "chatToChatRoom", sender: self)
            self.hidesBottomBarWhenPushed = false
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            
            
            self.receiverID = messagelist[indexPath.row].profileId
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                let ref = Database.database().reference()
                
                ref.child("ChatRoom").child(uid!).child(uid!+"_"+self.receiverID).removeValue()
                ref.child("UserChatList").child(uid!).child("UserList").child(self.receiverID).removeValue(completionBlock: { (error:Error?, ref:DatabaseReference!) in
                    if (error != nil) {
                        // handle an error
                    }
                    else{
                        self.messagelist.remove(at: indexPath.row)
                        tableView.reloadData()
                    }
                })
                
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "chatToChatRoom"){
            let destinationVC = segue.destination as! InsideChatViewController2
            Database.database().reference().removeAllObservers()
            
            destinationVC.receiverID    = receiverID
            destinationVC.receiverImage = receiverImage
            destinationVC.receiverName  = receiverName
            destinationVC.ownerID       = ownerID
            destinationVC.ownerName     = ownerName
            destinationVC.ownerImage    = ownerImage
        }
    }
    
    //disable storyboard segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagelist.removeAll()
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Chat Anonymouse User")
                self.noChatView.isHidden = false
            }
            else {
                getChatList()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n==========================\nChat Page\n===========================")
        messageTableView.dataSource = self
        messageTableView.delegate   = self
        
        // dynamic table view cell height
        messageTableView.estimatedRowHeight = messageTableView.rowHeight
        messageTableView.rowHeight          = UITableViewAutomaticDimension

    }
    
    func getChatList(){
        print("Getting Chat List")
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            self.ownerID = uid
            let ref = Database.database().reference()
            
            ref.child("UserChatList").child(uid!).child("UserList").observe(.childChanged, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                let ID = snapshot.key
                
                if let index = self.messagelist.index(where: {$0.key == ID}) {
                    
                    let value = snapshot.value as? NSDictionary
                    
                    if  let lastMessage = value?["lastmessage"] as? String {
                        self.messagelist[index].lastMessage = lastMessage
                    }
                    else {
                        self.messagelist[index].lastMessage = " "
                    }
                    
                    self.messagelist[index].newMessage = value?["newmessage"] as? String
                    
                    let postlasttime = self.messagelist[index].timeintervallastTime
                    let t = value?["time"] as? TimeInterval
                    let poststartdate = Date(timeIntervalSince1970: t!/1000)
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "dd MMM HH:mm"
                    let strDate = dateFormatter.string(from: poststartdate)
                    self.messagelist[index].lastTime = strDate
                    self.messagelist[index].timeintervallastTime = value?["time"] as? TimeInterval
                    
                    let fromindexPath = IndexPath(item: index, section: 0)
                    let toindexPath = IndexPath(row: 0, section: 0)
                    
                    self.messageTableView.reloadRows(at: [fromindexPath], with: .top)
                    
                    let newMessage = self.messagelist[index].newMessage
                    
                    if (newMessage != nil){
                        if (self.messagelist[index].newMessage == "true" && t == postlasttime) {
                            print("condiiton1")
                            
                        }
                        else if (self.messagelist[index].newMessage == "true" && t != postlasttime) {
                            print("condiiton2 t: \(String(describing: t)) and postlasttime: \(String(describing: postlasttime))")
                            self.messageTableView.beginUpdates()
                            self.messageTableView.moveRow(at: fromindexPath, to: toindexPath)
                            self.messagelist.insert(self.messagelist.remove(at: fromindexPath.row), at: 0)
                            self.messageTableView.endUpdates()
                        }
                        else if (self.messagelist[index].newMessage == "false" && t != postlasttime) {
                            print("condiiton3 t: \(String(describing: t)) and postlasttime: \(String(describing: postlasttime))")
                            self.messageTableView.beginUpdates()
                            self.messageTableView.moveRow(at: fromindexPath, to: toindexPath)
                            self.messagelist.insert(self.messagelist.remove(at: fromindexPath.row), at: 0)
                            self.messageTableView.endUpdates()
                        }
                        
                        self.messageTableView.reloadData()
                        
                    }
                    
                }
            })
            
            ref.child("UserChatList").child(uid!).child("UserList").queryOrdered(byChild: "negatedtime").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.firstload = false
                    self.noChatView.isHidden = false
                    return
                    
                }
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    print(rest)
                    let messagelistlist = MessageList()
                    
                    guard let restDict = rest.value as? [String: Any] else {
                        print("Guard Let Rest Dict failed")
                        continue }
                    
                        let profileId       = restDict["ownerid"] as? String
                        let profileImage    = restDict["ownerimage"] as? String
                        let profileName     = restDict["ownername"] as? String
                        let newMessage      = restDict["newmessage"] as? String
                        let key             = rest.key as? String
                        let timeintv        = restDict["time"] as? TimeInterval
                        
                        print("Get Details:\n=====================================")
                        print(profileId ?? "")
                        print(profileImage ?? "")
                        print(profileName ?? "")
                        print(newMessage ?? "")
                        print(key ?? "")
                        print(timeintv ?? "")
                        print("=====================================\n")

                    
                        let poststartdate           = Date(timeIntervalSince1970: timeintv!/1000)
                        let dateFormatter           = DateFormatter()
                        dateFormatter.locale        = NSLocale.current
                        dateFormatter.dateFormat    = "dd MMM HH:mm"
                        let strDate = dateFormatter.string(from: poststartdate)
                        
                        messagelistlist.profileId       = profileId
                        messagelistlist.profileImage    = profileImage
                        messagelistlist.key             = key
                        messagelistlist.profileName     = profileName
                        messagelistlist.newMessage      = newMessage
                        messagelistlist.lastTime        = strDate
                        messagelistlist.timeintervallastTime = timeintv
                        self.lastFirstTime = timeintv
                        
                        if  let lastMessage = restDict["lastmessage"] as? String {
                            messagelistlist.lastMessage = lastMessage
                        }
                        
                        self.firstload = true
                        self.messagelist.append(messagelistlist)
                        print(self.messagelist)

                    
                        
//                    else {
//                        self.firstload = false
//                        self.noChatView.isHidden = false
//                        return
//                    }
                }
                self.noChatView.isHidden = true
                self.messageTableView.reloadData()
                
            })
            
            
            ref.child("UserChatList").child(uid!).child("UserList").queryOrdered(byChild: "negatedtime").observe(.childAdded, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                guard let restDict = snapshot.value as? [String:Any] else
                {
                    print("Snapshot is nil hence no data returned")
                    return
                }
                
                let messagelistlist = MessageList()
                
                  let lastMessage = restDict["lastmessage"] as? String
                    let profileId = restDict["ownerid"] as? String
                    let profileImage = restDict["ownerimage"] as? String
                    let profileName = restDict["ownername"] as? String
                    let newMessage = restDict["newmessage"] as? String
                    let key = snapshot.key as? String
                    let time = restDict["time"] as? TimeInterval
                    
                    
                    let poststartdate = Date(timeIntervalSince1970: time!/1000)
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "dd MMM HH:mm"
                    let strDate = dateFormatter.string(from: poststartdate)
                    
                    messagelistlist.lastMessage = lastMessage
                    messagelistlist.profileId = profileId
                    messagelistlist.profileImage = profileImage
                    messagelistlist.key = key
                    messagelistlist.profileName = profileName
                    messagelistlist.newMessage = newMessage
                    messagelistlist.lastTime = strDate
                    messagelistlist.timeintervallastTime = time
                    
                    if(!self.firstload){
                        self.messagelist.insert(messagelistlist, at: 0)
                    }
                    
                    if (time == self.lastFirstTime) {
                        self.firstload = false
                    }
                
                self.messageTableView.reloadData()
                
                if (!self.noChatView.isHidden) {
                    self.noChatView.isHidden = true
                }
                
            })
            
            
            ref.child("UserAccount").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                
                if let getData = snapshot.value as? [String:Any]{
                    
                    if let userImage = getData["image"] as? String
                    {
                        self.ownerImage = userImage
                        
                    }
                    
                    if let userName = getData["name"] as? String
                    {
                        self.ownerName = userName
                        
                    }
                }
                
            })
            
        }
//        self.messageTableView.reloadData()

    }
    
}
