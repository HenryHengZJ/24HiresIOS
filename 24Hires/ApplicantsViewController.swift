//
//  ApplicantsViewController.swift
//  JobIn24
//
//  Created by MacUser on 09/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import UICircularProgressRing
import NVActivityIndicatorView
import BetterSegmentedControl

class ApplicantsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var applicantTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var noApplicantsView: UIView!
    
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    
    
    @IBAction func segmentChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0{
            print("Show Pending")
        }else if sender.index == 1{
            print("Show Shortlisted")
        }else{
            print("Show Hired")
        }

    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        //dismiss(animated: true, completion: nil)
        
        performSegueToReturnBack()
        
    }
    
    var applicantlist = [Applicants]()
    
    var postkey: String!
    var applicantUid: String!
    var startdate: Date!
    var enddate: Date!
    var nowDate: Date!
    var passedenddate: Date!
    var strTimeLeft: String!
    var timer: Timer!
    var WaitingBool: Bool!
    
    let userPostedPendingApplicantsRef = Database.database().reference().child("UserPostedPendingApplicants")
    
    
    //MARK:- ObjC Func
    
    @objc func countDownHour(){
        
        
        NotificationCenter.default.post(name: Notification.Name("ApplicantCellUpdate"), object: nil)
        
    }
    //MARK:- Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var firstload   = true
        var initialpost = true
        
        segmentedControl.titles             = ["PENDING","SHORTLISTED","HIRED"]
        segmentedControl.titleFont          = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        segmentedControl.selectedTitleFont  = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        
        
        setLoadingScreen()
        
        applicantTableView.dataSource   = self
        applicantTableView.delegate     = self
        
        // dynamic table view cell height
        applicantTableView.estimatedRowHeight = applicantTableView.rowHeight
        applicantTableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            
            print("postkeyapplcant \(self.postkey)");
            ref.child("UserActivities").child(uid!).child("Posted").child(self.postkey).child("applicants").queryOrdered(byChild: "negatedtime").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.removeLoadingScreen()
                    initialpost = false
                    self.noApplicantsView.isHidden = false
                    return
                    
                }
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let applicantpost = Applicants()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if  let applicantImage = restDict["image"] as? String,
                        let applicantName = restDict["name"] as? String,
                        let applicantPressed = restDict["pressed"] as? String,
                        let applicantRejected = restDict["rejected"] as? String,
                        let aplicantShortlisted = restDict["shortlisted"] as? String,
                        let postKey = rest.key as? String,
                        let applicantTime = restDict["time"] as? TimeInterval,
                        let applicantUid = restDict["userid"] as? String {
                        
                        let applicantstartdate = Date(timeIntervalSince1970: applicantTime/1000)
                        
                        applicantpost.applicantImage = applicantImage
                        applicantpost.applicantName = applicantName
                        applicantpost.applicantUid = applicantUid
                        applicantpost.pressed = applicantPressed
                        applicantpost.rejected = applicantRejected
                        applicantpost.shortlisted = aplicantShortlisted
                        applicantpost.applicantTime = applicantstartdate
                        applicantpost.postKey = postKey
                        
                        
                        self.applicantlist.append(applicantpost)
                        
                        if(applicantRejected == "false" && aplicantShortlisted == "false"){
                            self.WaitingBool = true
                        }
                        
                    }
                }
                
                if(self.WaitingBool == true){
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                    
                    RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                }
                
                self.applicantTableView.reloadData()
                
                self.removeLoadingScreen()
                
                initialpost = true
                
                print("initialapplicantpost1 = \(initialpost)")
                print("firstloadapplicant1 = \(firstload)")
                
            })
            
            ref.child("UserActivities").child(uid!).child("Posted").child(self.postkey).child("applicants").observe(.childAdded, with: { (snapshot) in
                
                if !snapshot.exists() {return}
                
                print("initialapplicant2 = \(initialpost)")
                print("firstloadapplicant2 = \(firstload)")
                
                if (initialpost) {
                    if(firstload){
                        print("firstload applicant ID = \(snapshot.key)")
                        return
                    }
                }
                
                print("added applicant ID = \(snapshot.key)")
                
                guard let restDict = snapshot.value as? [String:Any] else
                {
                    print("Snapshot is nil hence no data returned")
                    return
                }
                
                let applicantpost = Applicants()
                
                if  let applicantImage = restDict["image"] as? String,
                    let applicantName = restDict["name"] as? String,
                    let applicantPressed = restDict["pressed"] as? String,
                    let applicantRejected = restDict["rejected"] as? String,
                    let aplicantShortlisted = restDict["shortlisted"] as? String,
                    let postKey = snapshot.key as? String,
                    let applicantTime = restDict["time"] as? TimeInterval,
                    let applicantUid = restDict["userid"] as? String {
                    
                    let applicantstartdate = Date(timeIntervalSince1970: applicantTime/1000)
                    
                    applicantpost.applicantImage = applicantImage
                    applicantpost.applicantName = applicantName
                    applicantpost.applicantUid = applicantUid
                    applicantpost.pressed = applicantPressed
                    applicantpost.rejected = applicantRejected
                    applicantpost.shortlisted = aplicantShortlisted
                    applicantpost.applicantTime = applicantstartdate
                    applicantpost.postKey = postKey
                    
                    
                    self.applicantlist.insert(applicantpost, at: 0)
                    
                }
                
                if(self.WaitingBool == false){
                    self.WaitingBool = true
                }
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownHour), userInfo: nil, repeats: true)
                
                RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
                
                self.applicantTableView.reloadData()
                
                if (!self.noApplicantsView.isHidden) {
                    self.noApplicantsView.isHidden = true
                }
                
            })
            
        }
    }
    
    
    
    
    //MARK:- TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let applicantuid = applicantlist[indexPath.row].applicantUid
        let applicantname = applicantlist[indexPath.row].applicantName
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ApplicantsProfileViewController") as! ApplicantsProfileViewController
        nextViewController.hidesBottomBarWhenPushed = true
        
        nextViewController.userID = applicantuid
        nextViewController.userName =  applicantname
        
        if (applicantuid != nil) {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return applicantlist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let applicantCell = tableView.dequeueReusableCell(withIdentifier: "ApplicantCell", for: indexPath) as! ApplicantTableViewCell
        
        let applicantid = applicantlist[indexPath.row].applicantUid
        
        applicantCell.applieduserUid = applicantlist[indexPath.row].applicantUid
        
        applicantCell.postKey = applicantlist[indexPath.row].postKey
        
        self.startdate = applicantlist[indexPath.row].applicantTime
        
        applicantCell.applicantImage.sd_setImage(with: URL(string: self.applicantlist[indexPath.row].applicantImage), placeholderImage: UIImage(named: "userprofile_default"))
        
        applicantCell.applicantName.text = applicantlist[indexPath.row].applicantName
        
        if(applicantlist[indexPath.row].pressed == "false"){
            applicantCell.progressRing.setProgress(to: 24.0, duration: 0)
            applicantCell.timerleftlbl.textColor = UIColor(red: 4/255, green: 102/255, blue: 223/255, alpha :1)
        }
        else{
            applicantCell.progressRing.setProgress(to: 0.0, duration: 0)
            applicantCell.timerleftlbl.textColor = UIColor(red: 255/255, green: 170/255, blue: 169/255, alpha :1)
        }
        
        if(applicantlist[indexPath.row].shortlisted == "true"){
            applicantCell.shortlistedView.isHidden = false
            //applicantCell.shortlistStackHeight.constant = 30
            self.enddate = Calendar.current.date(byAdding: .hour, value: 0, to: startdate)
            applicantCell.WaitingOver = true
            applicantCell.timerleftlbl.isHidden = true
        }
        else{
            applicantCell.shortlistedView.isHidden = true
            //applicantCell.shortlistStackHeight.constant = 0
            self.enddate = Calendar.current.date(byAdding: .hour, value: 24, to: startdate)
            applicantCell.WaitingOver = false
            applicantCell.timerleftlbl.isHidden = false
        }
        
        
        applicantCell.endDate = self.enddate
        
        let ref = Database.database().reference()
        
        ref.child("UserInfo").child(applicantid!).observeSingleEvent(of: .value, with: { snapshot in
            
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
        
        ref.child("UserLocation").child(applicantid!).child("CurrentCity").observeSingleEvent(of: .value, with: { snapshot in
            
             if !snapshot.exists() {return}
            
             if let cityval = snapshot.value as? String{
                
                applicantCell.applicantLocation.text = cityval
                
            }
             else{
                
                applicantCell.applicantLocation.text = "Unknown"
            }
            
        })
       
        tablecell = applicantCell
        
        return tablecell
    }
    
    
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
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        performSegueToReturnBack()
    }
    

}

extension UIViewController{
    func performSegueToReturnBack(){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else{
            self.dismiss(animated:true, completion:nil)
        }
    }
}
