//
//  AppliedViewController.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CircleProgressView
import NVActivityIndicatorView

class AppliedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    var WaitingBool: Bool!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var tablecell: UITableViewCell!
     
        let appliedCell = tableView.dequeueReusableCell(withIdentifier: "AppliedCell", for: indexPath) as! AppliedTableViewCell
      
        if (posts.count > indexPath.row) {
            
            print("appliedcell3")
            
            appliedCell.tag = indexPath.row
            
            if(posts[indexPath.row].postImage == "0"){
                appliedCell.postImage.image = UIImage(named: "job_bg1")
            }
            else if (posts[indexPath.row].postImage == "1"){
                appliedCell.postImage.image = UIImage(named: "job_bg2")
            }
            else if (posts[indexPath.row].postImage == "2"){
                appliedCell.postImage.image = UIImage(named: "job_bg3")
            }
            else{
                appliedCell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
                
            }
            
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
            
            if(posts[indexPath.row].postShortlisted == "true"){
                
                print("trueshortlist : \(posts[indexPath.row])")
                print("trueshortlist : \(posts[indexPath.row].postTitle)")
                
                appliedCell.shortlistlbl.isHidden = false
                appliedCell.rejectedlbl.isHidden = true
                appliedCell.waitingreplylbl.isHidden = true
                appliedCell.timeleftlbl.isHidden = true
                //appliedCell.progressRing.progress = 0.0
                
                
                if(posts[indexPath.row].postClosed == "true"){
                    appliedCell.closedView.isHidden = false
                    appliedCell.closedText.isHidden = false
                }
                
                if(posts[indexPath.row].postRemoved == "true"){
                    appliedCell.removedText.isHidden = false
                    appliedCell.removedView.isHidden = false
                    appliedCell.shortlistlbl.isHidden = true
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
                
            else if(posts[indexPath.row].postRejected == "true"){
                
                print("truereject : \(posts[indexPath.row])")
                print("truereject : \(posts[indexPath.row].postTitle)")
                
                appliedCell.rejectedlbl.isHidden = false
                appliedCell.shortlistlbl.isHidden = true
                appliedCell.waitingreplylbl.isHidden = true
                appliedCell.timeleftlbl.isHidden = true
                //appliedCell.progressRing.progress = 0.0
                
                
                if(posts[indexPath.row].postClosed == "true"){
                    appliedCell.closedView.isHidden = false
                    appliedCell.closedText.isHidden = false
                }
                
                if(posts[indexPath.row].postRemoved == "true"){
                    appliedCell.removedText.isHidden = false
                    appliedCell.removedView.isHidden = false
                    appliedCell.rejectedlbl.isHidden = true
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
                
                if(posts[indexPath.row].postClosed == "false" && posts[indexPath.row].postRemoved == "false"){
                    appliedCell.rejectedlbl.isHidden = true
                    appliedCell.shortlistlbl.isHidden = true
                    appliedCell.waitingreplylbl.isHidden = false
                    appliedCell.timeleftlbl.isHidden = false
                    appliedCell.closedView.isHidden = true
                    appliedCell.closedText.isHidden = true
                    appliedCell.removedText.isHidden = true
                    appliedCell.removedView.isHidden = true
                    
                    self.enddate = Calendar.current.date(byAdding: .hour, value: 24, to: startdate)
                    
                    appliedCell.closeBtn.isHidden = true
                }
                    
                else if (posts[indexPath.row].postClosed == "false" && posts[indexPath.row].postRemoved == "true"){
                    appliedCell.rejectedlbl.isHidden = true
                    appliedCell.shortlistlbl.isHidden = true
                    appliedCell.waitingreplylbl.isHidden = true
                    appliedCell.timeleftlbl.isHidden = true
                    appliedCell.closedView.isHidden = true
                    appliedCell.closedText.isHidden = true
                    appliedCell.removedText.isHidden = false
                    appliedCell.removedView.isHidden = false
                    
                    self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
                    
                    appliedCell.closeBtn.isHidden = false
                    
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
        }

        tablecell = appliedCell
        
        return tablecell
    }
    
    @objc func countDownHour(){
        
    
        NotificationCenter.default.post(name: Notification.Name("AppliedCellUpdate"), object: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.postkey = posts[indexPath.row].postKey
        let selectedcity = posts[indexPath.row].postCity
        
        //let destinationVC = JobDetail()
        //destinationVC.postid = postkey
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
        
        destinationVC.postid = postkey
        destinationVC.city = selectedcity
        
        //self.presentDetail(destinationVC)
        
        //destinationVC.modalTransitionStyle = .crossDissolve
        //destinationVC.modalPresentationStyle = .fullScreen
        //self.present(destinationVC, animated:true, completion:nil)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var firstload = true
        var initialpost = true
        
        setLoadingScreen()
        
        appliedTableView.dataSource = self
        appliedTableView.delegate = self
        
        // dynamic table view cell height
        appliedTableView.estimatedRowHeight = appliedTableView.rowHeight
        appliedTableView.rowHeight = UITableViewAutomaticDimension
        
        let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipedright)
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(uid!).child("Applied").queryOrdered(byChild: "negatedtime").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.removeLoadingScreen()
                    initialpost = false
                    self.noAppliedJobView.isHidden = false
                    return
                    
                }
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let postpost = Post()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if  let postCity = restDict["city"] as? String,
                        let postClosed = restDict["closed"] as? String,
                        let postImage = restDict["postimage"] as? String,
                        let postPressed = restDict["pressed"] as? String,
                        let postRejected = restDict["rejected"] as? String,
                        let postRemoved = restDict["removed"] as? String,
                        let postShortlisted = restDict["shortlisted"] as? String,
                        let postTitle = restDict["title"] as? String,
                        let postDesc = restDict["desc"] as? String,
                        let postCompany = restDict["company"] as? String,
                        let postuserID = restDict["uid"] as? String,
                        let t = restDict["time"] as? TimeInterval,
                        let postKey = rest.key as? String{
                        
                        let poststartdate = Date(timeIntervalSince1970: t/1000)
                     
                        postpost.postCity = postCity
                        postpost.postClosed = postClosed
                        postpost.postPressed = postPressed
                        postpost.postRejected = postRejected
                        postpost.postRemoved = postRemoved
                        postpost.postShortlisted = postShortlisted
                        postpost.userID = postuserID
                        postpost.postTitle = postTitle
                        postpost.postImage = postImage
                        postpost.postDesc = postDesc
                        postpost.postCompany = postCompany
                        postpost.postKey = postKey
                        postpost.startDate = poststartdate
                        
                        print("applied append title= \(postTitle)")
                    
                        self.posts.append(postpost)
                        
                        if(postClosed == "false" && postRejected == "false" && postRemoved == "false" && postShortlisted == "false"){
                            self.WaitingBool = true
                        }
                        
                    }
                }
                
                if(self.WaitingBool == true){
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                    
                    RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                }
                
                self.appliedTableView.reloadData()
                
                self.removeLoadingScreen()
                
                firstload = false
                
                initialpost = true
                
            })
            
            ref.child("UserActivities").child(uid!).child("Applied").observe(.childChanged, with: { (snapshot) in
                print("applied changed ID = \(snapshot.key)")
                let ID = snapshot.key
                if let index = self.posts.index(where: {$0.postKey == ID}) {
                    let value = snapshot.value as? NSDictionary
                    self.posts[index].postPressed = value?["pressed"] as? String
                    self.posts[index].postClosed = value?["closed"] as? String
                    self.posts[index].postRemoved = value?["removed"] as? String
                    self.posts[index].postRejected = value?["rejected"] as? String
                    self.posts[index].postShortlisted = value?["shortlisted"] as? String
                    let indexPath = IndexPath(item: index, section: 0)
                    self.appliedTableView.reloadRows(at: [indexPath], with: .top)
                }
            })
            
           
            
            ref.child("UserActivities").child(uid!).child("Applied").observe(.childAdded, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                if (initialpost) {
                    if(firstload){
                        print("firstload applied ID = \(snapshot.key)")
                        return
                    }
                }
                
                print("added applied ID = \(snapshot.key)")
                
                guard let restDict = snapshot.value as? [String:Any] else
                {
                    print("Snapshot is nil hence no data returned")
                    return
                }
                
                let postpost = Post()
                
                if  let postCity = restDict["city"] as? String,
                    let postClosed = restDict["closed"] as? String,
                    let postImage = restDict["postimage"] as? String,
                    let postPressed = restDict["pressed"] as? String,
                    let postRejected = restDict["rejected"] as? String,
                    let postRemoved = restDict["removed"] as? String,
                    let postShortlisted = restDict["shortlisted"] as? String,
                    let postTitle = restDict["title"] as? String,
                    let postDesc = restDict["desc"] as? String,
                    let postCompany = restDict["company"] as? String,
                    let postuserID = restDict["uid"] as? String,
                    let t = restDict["time"] as? TimeInterval,
                    let postKey = snapshot.key as? String{
                    
                    let poststartdate = Date(timeIntervalSince1970: t/1000)
                    
                    postpost.postCity = postCity
                    postpost.postClosed = postClosed
                    postpost.postPressed = postPressed
                    postpost.postRejected = postRejected
                    postpost.postRemoved = postRemoved
                    postpost.postShortlisted = postShortlisted
                    postpost.userID = postuserID
                    postpost.postTitle = postTitle
                    postpost.postImage = postImage
                    postpost.postDesc = postDesc
                    postpost.postCompany = postCompany
                    postpost.postKey = postKey
                    postpost.startDate = poststartdate
                    
                    self.posts.insert(postpost, at: 0)
                    
                    print("inserted applied ID = \(postTitle)")
  
                }
                
                if(self.WaitingBool == false){
                    self.WaitingBool = true
                }
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                
                RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                
                self.appliedTableView.reloadData()
                
                if (!self.noAppliedJobView.isHidden) {
                    self.noAppliedJobView.isHidden = true
                }
                
            })
            
            
        }

        // Do any additional setup after loading the view.
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
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 3 { // set your total tabs here
                self.tabBarController?.selectedIndex += 1
            }
        } else if sender.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                self.tabBarController?.selectedIndex -= 1
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
