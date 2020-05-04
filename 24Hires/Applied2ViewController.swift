//
//  Applied2ViewController.swift
//  JobIn24
//
//  Created by MacUser on 17/01/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UICircularProgressRing
import NVActivityIndicatorView

class Applied2ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var appliedTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var noAppliedJobView: UIView!
    
    var posts = [Post]()
    
    var postkey: String!
    var startdate: Date!
    var enddate: Date!
    var nowDate: Date!
    var passedenddate: Date!
    var strTimeLeft: String!
    var timer: Timer!
    var uid:String!
    var WaitingBool: Bool!
    
    var ref:DatabaseReference!
    var preparePostKey : String?
    var preparedHirerID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setLoadingScreen()
        
        appliedTableView.dataSource = self
        appliedTableView.delegate = self
        
        // dynamic table view cell height
        appliedTableView.estimatedRowHeight = appliedTableView.rowHeight
        appliedTableView.rowHeight = UITableViewAutomaticDimension
        
        
        /*let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipedright)*/
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get AppLied Anonymouse User")
                self.removeLoadingScreen()
                self.noAppliedJobView.isHidden = false
            }
            else {
                uid = currentUser!.uid
                
                ref = Database.database().reference()
                
                ref.child("UserActivities").child(uid!).child("Applied").observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        self.removeLoadingScreen()
                        self.noAppliedJobView.isHidden = false
                        return
                        
                    }
                })
                
                ref.child("UserActivities").child(uid!).child("Applied").observe(.childChanged, with: { (snapshot) in
                    print("applied changed ID = \(snapshot.key)")
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let value = snapshot.value as? NSDictionary
                        self.posts[index].postPressed = value?["pressed"] as? String
                        
                        if  let postStatus = value?["status"] as? String,
                            let postClosed = value?["closed"] as? String {
                            
                            if(postClosed == "false" && postStatus == "applied"){
                                self.WaitingBool = true
                                if(self.WaitingBool == nil){
                                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                                    
                                    RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                                }
                            }
                            
                            self.posts[index].postClosed = postClosed
                            self.posts[index].postStatus = postStatus
                        }
                        
                        if let t = value?["time"] as? TimeInterval {
                            let poststartdate = Date(timeIntervalSince1970: t/1000)
                            self.posts[index].startDate = poststartdate
                        }
                        
                        self.posts[index].postImage = value?["postimage"] as? String
                        self.posts[index].postTitle = value?["title"] as? String
                        self.posts[index].postDesc = value?["desc"] as? String
                        self.posts[index].postCompany = value?["company"] as? String
                        self.posts[index].postCity = value?["city"] as? String
                        
                        let indexPath = IndexPath(item: index, section: 0)
                        self.appliedTableView.reloadRows(at: [indexPath], with: .top)
                    }
                })
                
                
                
                ref.child("UserActivities").child(uid!).child("Applied").queryOrdered(byChild: "time").observe(.childAdded, with: { (snapshot) in
                    
                    if !snapshot.exists() {
                        self.removeLoadingScreen()
                        self.noAppliedJobView.isHidden = false
                        return
                    }
                    
                    print("added applied ID = \(snapshot.key)")
                    
                    guard let restDict = snapshot.value as? [String:Any] else
                    {
                        print("Snapshot is nil hence no data returned")
                        return
                    }
                    
                    let postpost = Post()
                    
                    if let postCity = restDict["city"] as? String {
                        postpost.postCity = postCity
                    }
                    
                    if let postImage = restDict["postimage"] as? String {
                        postpost.postImage = postImage
                    }
                    if let postPressed = restDict["pressed"] as? String {
                        postpost.postPressed = postPressed
                    }
                    if  let postStatus = restDict["status"] as? String,
                        let postClosed = restDict["closed"] as? String {
                        
                        if(postClosed == "false" && postStatus == "applied"){
                            self.WaitingBool = true
                        }
                        
                        postpost.postClosed = postClosed
                        postpost.postStatus = postStatus
                    }
                    if let postTitle = restDict["title"] as? String {
                        postpost.postTitle = postTitle
                    }
                    if let postDesc = restDict["desc"] as? String {
                        postpost.postDesc = postDesc
                    }
                    if let postCompany = restDict["company"] as? String {
                        postpost.postCompany = postCompany
                    }
                    if let postuserID = restDict["uid"] as? String {
                        postpost.userID = postuserID
                    }
                    if let t = restDict["time"] as? TimeInterval {
                        let poststartdate = Date(timeIntervalSince1970: t/1000)
                        postpost.startDate = poststartdate
                    }
                    if let postKey = snapshot.key as? String {
                        postpost.postKey = postKey
                    }
                    if  let postDate = restDict["date"] as? String {
                        postpost.postDate = postDate
                    }
                    if  let postReviewed = restDict["reviewed"] as? String {
                        postpost.postReviewed = postReviewed
                    }
                    
                    print("postpost.postStatus = \(postpost.postStatus)")
                    
                    if postpost.postStatus != nil {
                        self.posts.insert(postpost, at: 0)
                        
                        if(self.WaitingBool != nil && self.WaitingBool == true){
                            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                            
                            RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                        }
                        
                        self.appliedTableView.reloadData()
                        
                        self.removeLoadingScreen()
                        
                        if (!self.noAppliedJobView.isHidden) {
                            self.noAppliedJobView.isHidden = true
                        }
                    }
                    
                })
                
                ref.child("UserActivities").child(uid!).child("Applied").observe(.childRemoved, with: { (snapshot) in
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.posts.remove(at: indexPath.row)
                        self.appliedTableView.beginUpdates()
                        self.appliedTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.appliedTableView.endUpdates()
                        
                        if (self.posts.count == 0) {
                            self.noAppliedJobView.isHidden = false
                        }
                    }
                })
            }
            
        }
        else {
            self.removeLoadingScreen()
            self.noAppliedJobView.isHidden = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueIdentifier_appliedToViewMoreDetails{
            let dest = segue.destination as! AppliedReviewViewController
            dest.hirerID = preparedHirerID
            dest.postKey = preparePostKey
        }else if segue.identifier == AppConstant.segueIdentifier_appliedToViewMoreWithStatus{
            let dest = segue.destination as! AppliedReviewViewController
            dest.hirerID = preparedHirerID
            dest.postKey = preparePostKey
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        if(loadingBall != nil) {
            loadingBall.type = .ballPulseSync
            loadingBall.startAnimating()
            loadingBallView.isHidden = false
            loadingBallView.alpha = 1.0
            
            loadingView.isHidden = false
        }
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
    
    @objc func countDownHour(){
        
        
        NotificationCenter.default.post(name: Notification.Name("AppliedCellUpdate"), object: nil)
        
    }
    
    /*@objc func swiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 3 { // set your total tabs here
                self.tabBarController?.selectedIndex += 1
            }
        } else if sender.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                self.tabBarController?.selectedIndex -= 1
            }
        }
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //show no job screen
        if posts.count == 0{
            self.noAppliedJobView.isHidden = false
        }else{
            self.noAppliedJobView.isHidden = true
        }
        
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        print("posts.count = \(posts.count)")
        
        if (posts.count > indexPath.row) {
            
            var table2cell: UITableViewCell!
            
            print("posts[indexPath.row].postStatus = \(posts[indexPath.row].postStatus)")
            
            if(posts[indexPath.row].postStatus == "pendingoffer"){
                
                let applied_HiredCell = tableView.dequeueReusableCell(withIdentifier: "Applied_HiredCell", for: indexPath) as! Applied_HiredTableViewCell
                
                applied_HiredCell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
                
                
                applied_HiredCell.postTitle.text = posts[indexPath.row].postTitle
                
                applied_HiredCell.postCompany.text = posts[indexPath.row].postCompany
                
                applied_HiredCell.postDescrip.text = posts[indexPath.row].postDesc
                
                applied_HiredCell.viewmoretapBtn = {
                    print("show view more tap")
                    self.preparePostKey = self.posts[indexPath.row].postKey
                    self.preparedHirerID = self.posts[indexPath.row].userID
                    
                    self.performSegue(withIdentifier: AppConstant.segueIdentifier_appliedToViewMoreDetails, sender: self)
                }
                
                
                applied_HiredCell.closetapBtn = {
                    self.DeleteJobAlert(statusval:self.posts[indexPath.row].postStatus, postkey: self.posts[indexPath.row].postKey)
                }
                
                applied_HiredCell.acceptjobtapBtn = {
                    self.AcceptJobAlert(userid: self.posts[indexPath.row].userID, postkey: self.posts[indexPath.row].postKey)
                }
                
                applied_HiredCell.rejectjobtapBtn = {
                    self.RejectJobAlert(userid: self.self.posts[indexPath.row].userID, postkey: self.posts[indexPath.row].postKey)
                }
                
                self.startdate = posts[indexPath.row].startDate
                
                applied_HiredCell.closedView.isHidden = true
                applied_HiredCell.closedText.isHidden = true
                
                table2cell = applied_HiredCell
                
            }
                
            else {
                let appliedCell = tableView.dequeueReusableCell(withIdentifier: "AppliedCell", for: indexPath) as! AppliedTableViewCell
                
                
                appliedCell.tag = indexPath.row
                
                
                appliedCell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
                
                //appliedCell.postImage.downloadpostImage(from: self.posts[indexPath.row].postImage)
                
                appliedCell.postTitle.text = posts[indexPath.row].postTitle
                
                appliedCell.postCompany.text = posts[indexPath.row].postCompany
                
                appliedCell.postDescrip.text = posts[indexPath.row].postDesc
                
                self.startdate = posts[indexPath.row].startDate
                
                appliedCell.posterUid = posts[indexPath.row].userID
                
                appliedCell.postKey = posts[indexPath.row].postKey
                
                appliedCell.shortlistlbl.isHidden = true
                appliedCell.rejectedlbl.isHidden = true
                appliedCell.timeleftlbl.isHidden = true
                appliedCell.waitingreplylbl.isHidden = true
                appliedCell.closedView.isHidden = true
                appliedCell.closedText.isHidden = true
                appliedCell.removedText.isHidden = true
                appliedCell.removedView.isHidden = true
                appliedCell.viewmoreBtn.isHidden = true
                
                appliedCell.viewmoretapBtn = {
                    print("show view more tap")
                    self.preparePostKey     = self.posts[indexPath.row].postKey
                    self.preparedHirerID    = self.posts[indexPath.row].userID
                    self.performSegue(withIdentifier: AppConstant.segueIdentifier_appliedToViewMoreWithStatus, sender: self)
                }

                
                appliedCell.closetapBtn = {
                    self.DeleteJobAlert(statusval:self.posts[indexPath.row].postStatus, postkey: self.posts[indexPath.row].postKey)
                }
                
                if(posts[indexPath.row].postStatus == "removed"){
                    appliedCell.removedText.isHidden = false
                    appliedCell.removedView.isHidden = false
                    appliedCell.shortlistlbl.isHidden = true
                    
                    self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                }
                else {
                    
                    if(posts[indexPath.row].postStatus == "shortlisted"){
                        
                        print("trueshortlist : \(posts[indexPath.row])")
                        print("trueshortlist : \(posts[indexPath.row].postTitle)")
                        
                        appliedCell.viewmoreBtn.isHidden = true
                        appliedCell.shortlistlbl.isHidden = false
                        appliedCell.rejectedlbl.isHidden = true
                        appliedCell.waitingreplylbl.isHidden = true
                        appliedCell.timeleftlbl.isHidden = true
                        
                        appliedCell.rejectedjobView.isHidden = true
                        appliedCell.acceptedjobView.isHidden = true
                        appliedCell.updatejobView.isHidden = true
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                        }
                        
                        if(posts[indexPath.row].postPressed == "false"){
                            appliedCell.notificationWidth.constant = 10
                        }
                        else{
                            appliedCell.notificationWidth.constant = 0
                        }
                        
                        self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        
                        appliedCell.closeBtn.isHidden = false
                        
                    }
                        
                    else if(posts[indexPath.row].postStatus == "appliedrejected"){
                        
                        print("truereject : \(posts[indexPath.row])")
                        print("truereject : \(posts[indexPath.row].postTitle)")
                        
                        appliedCell.viewmoreBtn.isHidden = true
                        appliedCell.rejectedlbl.isHidden = false
                        appliedCell.shortlistlbl.isHidden = true
                        appliedCell.waitingreplylbl.isHidden = true
                        appliedCell.timeleftlbl.isHidden = true
                        
                        appliedCell.rejectedjobView.isHidden = true
                        appliedCell.acceptedjobView.isHidden = true
                        appliedCell.updatejobView.isHidden = true
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                        }
                        
                        if(posts[indexPath.row].postPressed == "false"){
                            appliedCell.notificationWidth.constant = 10
                        }
                        else{
                            appliedCell.notificationWidth.constant = 0
                        }
                        
                        self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        
                        appliedCell.closeBtn.isHidden = false
                        
                    }
                        
                    else if(posts[indexPath.row].postStatus == "rejectedoffer"){
                        
                        appliedCell.viewmoreBtn.isHidden = false
                        appliedCell.rejectedlbl.isHidden = true
                        appliedCell.shortlistlbl.isHidden = true
                        appliedCell.waitingreplylbl.isHidden = true
                        appliedCell.timeleftlbl.isHidden = true
                        
                        appliedCell.rejectedjobView.isHidden = false
                        appliedCell.acceptedjobView.isHidden = true
                        appliedCell.updatejobView.isHidden = true
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                        }
                        
                        if(posts[indexPath.row].postPressed == "false"){
                            appliedCell.notificationWidth.constant = 10
                        }
                        else{
                            appliedCell.notificationWidth.constant = 0
                        }
                        
                        self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        
                        appliedCell.closeBtn.isHidden = false
                        
                    }
                        
                    else if(posts[indexPath.row].postStatus == "acceptedoffer"){
                        
                        appliedCell.viewmoreBtn.isHidden = false
                        appliedCell.rejectedlbl.isHidden = true
                        appliedCell.shortlistlbl.isHidden = true
                        appliedCell.waitingreplylbl.isHidden = true
                        appliedCell.timeleftlbl.isHidden = true
                        
                        appliedCell.rejectedjobView.isHidden = true
                        appliedCell.acceptedjobView.isHidden = false
                        appliedCell.updatejobView.isHidden = true
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                        }
                        
                        if(posts[indexPath.row].postPressed == "false"){
                            appliedCell.notificationWidth.constant = 10
                        }
                        else{
                            appliedCell.notificationWidth.constant = 0
                        }
                        
                        self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        
                        appliedCell.closeBtn.isHidden = false
                        
                        if (posts[indexPath.row].postDate != nil) {
                            
                            var lastdate = ""
                            
                            if posts[indexPath.row].postDate.contains("/") {
                                let items = posts[indexPath.row].postDate.components(separatedBy: "/")
                                lastdate = items[items.count - 1]
                                
                            }
                            else if posts[indexPath.row].postDate.contains("to")  {
                                let items = posts[indexPath.row].postDate.components(separatedBy: "to")
                                lastdate = items[1]
                            }
                            else {
                                lastdate = posts[indexPath.row].postDate
                            }
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd MMM yy"
                            var enddate = formatter.date(from: lastdate)
                            var datenow = Date()
                            
                            if(enddate! > datenow){
                                
                                //End date has over today's date, show review
                                if (posts[indexPath.row].postReviewed != nil) {
                                    appliedCell.acceptjobLabel.text = "You can now review!"
                                }
                                else {
                                    appliedCell.acceptjobLabel.text = "You have accepted job offer"
                                }
                            }
                            
                            
                        }
                        
                    }
                        
                    else if(posts[indexPath.row].postStatus == "changedoffer"){
                        
                        appliedCell.viewmoreBtn.isHidden = false
                        appliedCell.rejectedlbl.isHidden = true
                        appliedCell.shortlistlbl.isHidden = true
                        appliedCell.waitingreplylbl.isHidden = true
                        appliedCell.timeleftlbl.isHidden = true
                        
                        appliedCell.rejectedjobView.isHidden = true
                        appliedCell.acceptedjobView.isHidden = true
                        appliedCell.updatejobView.isHidden = false
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                        }
                        
                        if(posts[indexPath.row].postPressed == "false"){
                            appliedCell.notificationWidth.constant = 10
                        }
                        else{
                            appliedCell.notificationWidth.constant = 0
                        }
                        
                        self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        
                        appliedCell.closeBtn.isHidden = false
                        
                    }
                        
                    else{
                        
                        print("else : \(posts[indexPath.row])")
                        print("else : \(posts[indexPath.row].postTitle)")
                        
                        appliedCell.notificationWidth.constant = 0
                        appliedCell.shortlistlbl.isHidden = true
                        
                        if(posts[indexPath.row].postClosed == "true"){
                            
                            appliedCell.viewmoreBtn.isHidden = true
                            appliedCell.closedView.isHidden = false
                            appliedCell.closedText.isHidden = false
                            appliedCell.rejectedlbl.isHidden = false
                            appliedCell.waitingreplylbl.isHidden = true
                            appliedCell.timeleftlbl.isHidden = true
                            
                            appliedCell.rejectedjobView.isHidden = true
                            appliedCell.acceptedjobView.isHidden = true
                            appliedCell.updatejobView.isHidden = true
                            
                            self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                        }
                        else {
                            appliedCell.viewmoreBtn.isHidden = true
                            appliedCell.closedView.isHidden = true
                            appliedCell.closedText.isHidden = true
                            appliedCell.rejectedlbl.isHidden = true
                            appliedCell.waitingreplylbl.isHidden = false
                            appliedCell.timeleftlbl.isHidden = false
                            
                            appliedCell.rejectedjobView.isHidden = true
                            appliedCell.acceptedjobView.isHidden = true
                            appliedCell.updatejobView.isHidden = true
                            
                            self.enddate = Calendar.current.date(byAdding: .hour, value: 24, to: startdate)
                        }
                        
                        appliedCell.closeBtn.isHidden = true
                        
                    }
                }
                
                appliedCell.endDate = self.enddate
                
                let currentDate = Date()
                
                if(enddate > currentDate){
                    appliedCell.WaitingOver = false
                }
                else{
                    appliedCell.WaitingOver = true
                }
                
                table2cell = appliedCell
            }
            
            tablecell = table2cell
        }
        
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("cell tap")
        
        
        if (posts[indexPath.row].postStatus == "pendingoffer") {
            let tablecell = tableView.cellForRow(at: indexPath) as! Applied_HiredTableViewCell
            
        }
        else {
            let tablecell = tableView.cellForRow(at: indexPath) as! AppliedTableViewCell
            
            if tablecell.notificationWidth != nil {
                tablecell.notificationWidth.constant = 0
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if (self.ref != nil && self.uid != nil) {
            self.ref.child("UserActivities").child(self.uid).child("NewApplied").setValue("false")
            self.ref.child("UserActivities").child(self.uid).child("Applied").child(self.posts[indexPath.row].postKey).child("pressed").setValue("true")
            
            self.ref.child("UserActivities").child(self.uid).child("ShortListedNotification").observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let notiKey = rest.key as? String {
                            self.ref.child("ShortlistedNotification").child("ShortListed").child(notiKey).removeValue(completionBlock: { (error:Error?, ref:DatabaseReference!) in
                                
                                if (error != nil) {
                                }
                                else {
                                    self.ref.child("UserActivities").child(self.uid!).child("ShortListedNotification").child(notiKey).removeValue()
                                }
                            })
                        }
                    }
                }
                
            })
            
            
            self.ref.child("Job").child(self.posts[indexPath.row].postCity).child(self.posts[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.exists() {
                    
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
                    
                    destinationVC.postid = self.posts[indexPath.row].postKey
                    destinationVC.city = self.posts[indexPath.row].postCity
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                }
                else {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "RemovedJob") as! RemovedJob
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                }
                
            })
        }
        
    }
    
    
    func AcceptJobAlert(userid: String, postkey: String){
        
        // create the alert
        let alert = UIAlertController(title: "Accept Job Offer", message: "Are you sure you want to accept the job offer?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { action in
            
            self.acceptjoboffer(userid: userid, postkey:postkey)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func RejectJobAlert(userid: String, postkey: String){
        
        // create the alert
        let alert = UIAlertController(title: "Reject Job Offer", message: "Are you sure you want to reject the job offer?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.default, handler: { action in
            
            self.rejectjoboffer(userid: userid, postkey:postkey)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func DeleteJobAlert(statusval: String, postkey: String){
        
        // create the alert
        let alert = UIAlertController(title: "Delete Applied Job", message: "Are you sure you want to delete this applied job", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { action in
            
            self.deletejob(statusval:statusval, postkey:postkey)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func rejectjoboffer(userid: String, postkey: String) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(userid).child("NewMainNotification").setValue("true")
            ref.child("UserPostedHiredApplicants").child(userid).child(postkey).child(ownuid!).child("offerstatus").setValue("rejected")
            ref.child("UserPostedHiredApplicants").child(userid).child(postkey).child(ownuid!).child("pressed").setValue("false")
            ref.child("UserActivities").child(userid).child("NewPosted").setValue("true")
            ref.child("UserActivities").child(userid).child("NewApplicant").setValue("true")
            ref.child("UserPosted").child(userid).child(postkey).child("pressed").setValue("false")
            ref.child("UserActivities").child(ownuid!).child("Applied").child(postkey).child("status").setValue("rejectedoffer")
            
            
            deleteHiredNotifications()
            
        }
    }
    
    func acceptjoboffer(userid: String, postkey: String) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(userid).child("NewMainNotification").setValue("true")
            ref.child("UserPostedHiredApplicants").child(userid).child(postkey).child(ownuid!).child("offerstatus").setValue("accepted")
            ref.child("UserPostedHiredApplicants").child(userid).child(postkey).child(ownuid!).child("pressed").setValue("false")
            ref.child("UserActivities").child(userid).child("NewPosted").setValue("true")
            ref.child("UserActivities").child(userid).child("NewApplicant").setValue("true")
            ref.child("UserPosted").child(userid).child(postkey).child("pressed").setValue("false")
            ref.child("UserActivities").child(ownuid!).child("Applied").child(postkey).child("status").setValue("acceptedoffer")
            
            
            deleteHiredNotifications()
        }
    }
    
    func deletejob(statusval: String, postkey: String) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            if (statusval != nil) {
                if (statusval == "pendingoffer" || statusval == "changedoffer") {
                    ref.child("UserActivities").child(ownuid!).child("Shortlisted").child(postkey).setValue("true")
                }
                else if (statusval == "acceptedoffer") {
                    ref.child("UserActivities").child(ownuid!).child("Hired").child(postkey).setValue("true")
                }
                else if (statusval == "rejectedoffer") {
                    ref.child("UserActivities").child(ownuid!).child("RejectedOffer").child(postkey).setValue("true")
                }
                else if (statusval == "shortlisted") {
                    ref.child("UserActivities").child(ownuid!).child("Shortlisted").child(postkey).setValue("true")
                }
                
                ref.child("UserActivities").child(ownuid!).child("Applied").child(postkey).removeValue()
            }
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
