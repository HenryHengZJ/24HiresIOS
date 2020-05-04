//
//  HiredApplicantViewController.swift
//  JobIn24
//
//  Created by MacUser on 27/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import UICircularProgressRing
import NVActivityIndicatorView

class HiredApplicantViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var applicantTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var noApplicantsView: UIView!
    
    
    var applicantlist = [Applicants]()
    
    var postkey: String!
    var jobCity: String!
    var applicantUid: String!
    var startdate: Date!
    var enddate: Date!
    var nowDate: Date!
    var passedenddate: Date!
    var strTimeLeft: String!
    var timer: Timer!
    var WaitingBool: Bool!
    
    var uid: String!
    var ref: DatabaseReference!
    
    //Prepare Segue
    var prepareApplicantUID : String!
    var preparePostKey      : String!
    var prepareJobCity      : String!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == AppConstant.segueIdentifier_hiredToHirerViewDetails{
            
            let dest = segue.destination as! HirerViewDetailsViewController
            dest.postKey        = preparePostKey
            dest.applicantsUID  = prepareApplicantUID
            dest.jobCity        = prepareJobCity
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return applicantlist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let applicantCell = tableView.dequeueReusableCell(withIdentifier: "ApplicantCell", for: indexPath) as! HiredApplicantTableViewCell
        
        let applicantid = applicantlist[indexPath.row].applicantUid
        
        
        applicantCell.applicantImage.sd_setImage(with: URL(string: self.applicantlist[indexPath.row].applicantImage), placeholderImage: UIImage(named: "userprofile_default"))
        
        applicantCell.applicantName.text = applicantlist[indexPath.row].applicantName
        
        applicantCell.progressRing.setProgress(to: 24.0, duration: 0)
        
        applicantCell.viewdetailsclickBtn = {
            self.ref.child("UserActivities").child(self.uid).child("NewApplicant").setValue("false")
            self.ref.child("UserPostedHiredApplicants").child(self.uid).child(self.postkey).child(applicantid!).child("pressed").setValue("true")
            
            self.prepareApplicantUID    = applicantid
            self.preparePostKey         = self.postkey
            self.prepareJobCity         = self.jobCity
            
            if self.prepareApplicantUID != "" && self.preparePostKey != ""{
                self.performSegue(withIdentifier: AppConstant.segueIdentifier_hiredToHirerViewDetails, sender: self)
            }else{
                self.showAlertBox(title: "Error", msg: "System encountered some error.", buttonString: "Ok")
            }
            
        }
        
       self.ref.child("UserInfo").child(applicantid!).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            if snapshot.hasChild("WorkExp1"){
                
                if let worktitle1 = snapshot.childSnapshot(forPath: "WorkExp1").childSnapshot(forPath: "worktitle").value as? String{
                    
                    applicantCell.workTitle1.text = worktitle1
                    applicantCell.workTitle1.isHidden = false
                    
                }
                
                if let workplace1 = snapshot.childSnapshot(forPath: "WorkExp1").childSnapshot(forPath: "workcompany").value as? String{
                    
                    //applicantCell.workPlace1Height.constant = 16
                    applicantCell.workPlace1.isHidden = false
                    applicantCell.workPlace1.text = "at \(workplace1)"
                    
                }
                
            }
            else{
                applicantCell.workTitle1.text = "No Work Experiences"
                applicantCell.workPlace1.isHidden = true
                applicantCell.workTitle1.isHidden = false
            }
            
            if snapshot.hasChild("WorkExp2"){
                
                if let worktitle2 = snapshot.childSnapshot(forPath: "WorkExp2").childSnapshot(forPath: "worktitle").value as? String{
                    
                    //applicantCell.workTitle2Height.constant = 16
                    applicantCell.workTitle2.text = worktitle2
                    applicantCell.workTitle2.isHidden = false
                    
                }
                
                if let workplace2 = snapshot.childSnapshot(forPath: "WorkExp2").childSnapshot(forPath: "workcompany").value as? String{
                    
                    //applicantCell.workPlace2Height.constant = 16
                    applicantCell.workPlace2.text = workplace2
                    applicantCell.workPlace2.isHidden = false
                    
                }
                
            }
            else{
                applicantCell.workTitle2.isHidden = true
                applicantCell.workPlace2.isHidden = true
            }
            
            
        })
        
        self.ref.child("UserLocation").child(applicantid!).child("CurrentCity").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            if let cityval = snapshot.value as? String{
                
                applicantCell.applicantLocation.text = cityval
                
            }
            else{
                
                applicantCell.applicantLocation.text = "Somewhere on earth"
            }
            
        })
        
        tablecell = applicantCell
        
        return tablecell
    }
    
    func countDownHour(){
        
        
        NotificationCenter.default.post(name: Notification.Name("ApplicantCellUpdate"), object: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let applicantuid = applicantlist[indexPath.row].applicantUid
        let applicantname = applicantlist[indexPath.row].applicantName
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ApplicantsProfileViewController") as! ApplicantsProfileViewController
        nextViewController.hidesBottomBarWhenPushed = true
        
        print("============== Passing Data to Applicants Profile ==========")
        print("[ApplicantUID]       : \(applicantuid!)")
        print("[ApplicantUsername]  : \(applicantname!)")
        print("[Post Key]           : \(postkey!)")
        print("[Job City]           : \(jobCity!)")
        
        nextViewController.userID   = applicantuid
        nextViewController.userName = applicantname
        nextViewController.jobCity  = jobCity
        nextViewController.postkey  = postkey!
        nextViewController.status   = .completed
        
        if (applicantuid != nil) {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLoadingScreen()
        
        applicantTableView.dataSource = self
        applicantTableView.delegate = self
        
        // dynamic table view cell height
        applicantTableView.estimatedRowHeight = applicantTableView.rowHeight
        applicantTableView.rowHeight = UITableViewAutomaticDimension
        
        /*let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipedright)*/
        
        
        // Do any additional setup after loading the view.
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            uid = currentUser?.uid
            
            ref = Database.database().reference()
            
            ref.child("UserPostedHiredApplicants").child(uid!).child(self.postkey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.removeLoadingScreen()
                    self.noApplicantsView.isHidden = false
                    return
                    
                }
            })
            
            ref.child("UserPostedHiredApplicants").child(uid!).child(self.postkey).observe(.childChanged, with: { (snapshot) in
                let ID = snapshot.key
                if let index = self.applicantlist.index(where: {$0.applicantUid == ID}) {
                    let value = snapshot.value as? NSDictionary
                    self.applicantlist[index].pressed = value?["pressed"] as? String
                    let indexPath = IndexPath(item: index, section: 0)
                    self.applicantTableView.reloadRows(at: [indexPath], with: .top)
                }
            })
            
            ref.child("UserPostedHiredApplicants").child(uid!).child(self.postkey).observe(.childRemoved, with: { (snapshot) in
                let ID = snapshot.key
                if let index = self.applicantlist.index(where: {$0.applicantUid == ID}) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.applicantlist.remove(at: indexPath.row)
                    self.applicantTableView.beginUpdates()
                    self.applicantTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.applicantTableView.endUpdates()
                    
                    if (self.applicantlist.count == 0) {
                        self.noApplicantsView.isHidden = false
                    }
                }
            })
            
            ref.child("UserPostedHiredApplicants").child(uid!).child(self.postkey).queryOrdered(byChild: "time").observe(.childAdded, with: { (snapshot) in
                
                if !snapshot.exists() {
                    self.removeLoadingScreen()
                    self.noApplicantsView.isHidden = false
                    return}
                
                print("added applicant ID = \(snapshot.key)")
                
                guard let restDict = snapshot.value as? [String:Any] else
                {
                    print("Snapshot is nil hence no data returned")
                    self.removeLoadingScreen()
                    self.noApplicantsView.isHidden = false
                    return
                }
                
                let applicantpost = Applicants()
                
                if let applicantImage = restDict["image"] as? String {
                    applicantpost.applicantImage = applicantImage
                }
                if let applicantName = restDict["name"] as? String {
                    applicantpost.applicantName = applicantName
                }
                if let applicantDate = restDict["date"] as? String {
                    applicantpost.date = applicantDate
                }
                if let applicantUid = snapshot.key as? String {

                    applicantpost.applicantUid = applicantUid
                    
                }
                
                self.applicantlist.insert(applicantpost, at: 0)

                self.applicantTableView.reloadData()
                
                self.removeLoadingScreen()
                
                if (!self.noApplicantsView.isHidden) {
                    self.noApplicantsView.isHidden = true
                }
                
            })
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // Set the activity indicator into the main view
    func setLoadingScreen() {
        loadingBall.type = .ballPulseSync
        loadingBall.startAnimating()
        loadingBallView.isHidden = false
        loadingBallView.alpha = 1.0
        
        loadingView.isHidden = false
        
    }
    
    // Remove the activity indicator from the main view
    func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
}
