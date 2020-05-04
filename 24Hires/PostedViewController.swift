//
//  PostedViewController.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import FirebaseStorage

class PostedViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postedTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var noPostJobView: UIView!
    
    var mjobbg1, mjobbg2, mjobbg3: String!
    
    var posts = [Post]()
    
    var postkey: String!
    var selectedCity:String!
    
    
    var uid: String!
    
    var ref: DatabaseReference!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 || posts.count < 0{
            self.removeLoadingScreen()
            self.noPostJobView.isHidden = false
        }
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let postedcell = tableView.dequeueReusableCell(withIdentifier: "PostedCell", for: indexPath) as! PostedCell
        
        let posttotalhiredcount = posts[indexPath.row].totalhiredcount
        
        let applicantscount = posts[indexPath.row].applicantscount
        
        let newapplicantscount = posts[indexPath.row].newapplicantscount
        
        
        postedcell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
        
        
        //postedcell.postImage.downloadpostImage(from: self.posts ()[indexPath.row].postImage)
        
        postedcell.postTitle.text = posts[indexPath.row].postTitle
        
        postedcell.postCompany.text = posts[indexPath.row].postCompany
        
        postedcell.postDescrip.text = posts[indexPath.row].postDesc
        
        postedcell.actiontapBtn = {
            // create the alert
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Edit Post", style: UIAlertActionStyle.default, handler: { action in
                
                // Go to EditPost
                let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
                
                let editPost = storyBoard.instantiateViewController(withIdentifier: "EditPostViewController") as! EditPostViewController
                
                editPost.postkey = self.posts[indexPath.row].postKey
                
                editPost.city = self.posts[indexPath.row].postCity
                
                self.present(editPost, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Close Job", style: UIAlertActionStyle.default, handler: { action in
                
                self.CloseJob(postkey: self.posts[indexPath.row].postKey, city: self.posts[indexPath.row].postCity, totalapplicantscount: Int(applicantscount!))
                
            }))
            alert.addAction(UIAlertAction(title: "Remove Job", style: UIAlertActionStyle.destructive, handler: { action in
                
                self.RemoveJob(city: self.posts[indexPath.row].postCity, postkey:self.posts[indexPath.row].postKey, postimage:self.posts[indexPath.row].postImage)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        postedcell.tapBtn = {
            
            self.postkey = self.posts[indexPath.row].postKey
            self.selectedCity = self.posts[indexPath.row].postCity
            
            
            //let storyboard = UIStoryboard(name: "Activities", bundle: nil)
            
            //let destinationVC = storyboard.instantiateViewController(withIdentifier: "ApplicantsViewController") as! ApplicantsViewController
            
            //destinationVC.postkey = self.posts ()[indexPath.row].postKey
            
            //destinationVC.modalTransitionStyle = .crossDissolve
            //destinationVC.modalPresentationStyle = .fullScreen
            
            
            self.performSegue(withIdentifier: "ApplicantsSegue", sender: self)
            
            //self.present(destinationVC, animated:true, completion:nil)
            
            self.ref.child("UserActivities").child(self.uid).child("NewPosted").setValue("false")
            self.ref.child("UserPosted").child(self.uid).child(self.postkey).child("pressed").setValue("true")
            self.ref.child("UserPosted").child(self.uid).child(self.postkey).child("newapplicantscount").setValue(0)
            
            self.checkDates(postkey: self.postkey);
            
        }
        
        
        if(posts[indexPath.row].postClosed == "true"){
            postedcell.closedText.isHidden = false
            postedcell.closedView.isHidden = false
            
            postedcell.newApplicantLabelHeight.constant = 0
            postedcell.numNewApplicantHeight.constant = 0
            
            if(posttotalhiredcount == 0.0){
                postedcell.totalApplicantsLabel.text = "0 total hired applicants"
            }
            else{
                postedcell.totalApplicantsLabel.text = "\(Int(posttotalhiredcount!)) total hired applicants"
            }
        }
        else{
            postedcell.closedText.isHidden = true
            postedcell.closedView.isHidden = true
            
            if(applicantscount == 0.0){
                postedcell.totalApplicantsLabel.text = "0 total applicant"
            }
            else{
                postedcell.totalApplicantsLabel.text = "\(Int(applicantscount!)) total applicants"
            }
            
            if(newapplicantscount == 0.0){
                postedcell.newApplicantLabelHeight.constant = 0
                postedcell.numNewApplicantHeight.constant = 0
                postedcell.numNewApplicant.text = "0"
            }
            else{
                postedcell.newApplicantLabelHeight.constant = 15
                postedcell.numNewApplicantHeight.constant = 20
                postedcell.numNewApplicant.text = "\(Int(newapplicantscount!))"
            }
        }
        
        tablecell = postedcell
        
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.postkey = posts[indexPath.row].postKey
        var selectedcity = posts[indexPath.row].postCity
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ApplicantsSegue"){
            /*let barVC = segue.destination as! UITabBarController
            
            let pendingVC       = barVC.viewControllers![0] as! PendingApplicantViewController
            let shortlistedVC   = barVC.viewControllers![1] as! ShortlistedApplicantViewController
            let hiredVC         = barVC.viewControllers![2] as! HiredApplicantViewController
            
            pendingVC.postkey       = self.postkey
            shortlistedVC.postkey   = self.postkey
            hiredVC.postkey         = self.postkey
            
            pendingVC.jobCity       = selectedCity
            shortlistedVC.jobCity   = selectedCity
            hiredVC.jobCity         = selectedCity
            
            
            let vc = segue.destination as! ApplicantTopTab
            vc.postKey = self.postkey*/
            
            let vc = segue.destination as! Applicants2ViewController
            vc.postkey = self.postkey
            vc.jobCity = selectedCity
        }
    }
    
    //disable storyboard segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLoadingScreen()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        postedTableView.dataSource = self
        postedTableView.delegate = self
        
        // dynamic table view cell height
        postedTableView.estimatedRowHeight = postedTableView.rowHeight
        postedTableView.rowHeight = UITableViewAutomaticDimension
        
        /*let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipedright)*/
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Posted Anonymouse User")
                self.removeLoadingScreen()
                self.noPostJobView.isHidden = false
            }
            else {
                
                uid = currentUser?.uid
                ref = Database.database().reference()
                
                ref.child("UserActivities").child(uid!).child("Posted").observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        self.removeLoadingScreen()
                        self.noPostJobView.isHidden = false
                        return
                        
                    }
                })
                
                ref.child("DefaultJobPhotos").observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        return
                    }
                    
                    if snapshot.hasChild("jobbg1") {
                        self.mjobbg1 = snapshot.childSnapshot(forPath: "jobbg1").value as? String
                    }
                    if snapshot.hasChild("jobbg2") {
                        self.mjobbg2 = snapshot.childSnapshot(forPath: "jobbg2").value as? String
                    }
                    if snapshot.hasChild("jobbg3") {
                        self.mjobbg3 = snapshot.childSnapshot(forPath: "jobbg3").value as? String
                    }
                })
                
                ref.child("UserPosted").child(uid!).observe(.childChanged, with: { (snapshot) in
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let value = snapshot.value as? NSDictionary
                        self.posts[index].totalhiredcount = value?["totalhiredcount"] as? Double
                        self.posts[index].applicantscount = value?["applicantscount"] as? Double
                        self.posts[index].newapplicantscount = value?["newapplicantscount"] as? Double
                        self.posts[index].postImage = value?["postimage"] as? String
                        self.posts[index].postTitle = value?["title"] as? String
                        self.posts[index].postDesc = value?["desc"] as? String
                        self.posts[index].postClosed = value?["closed"] as? String
                        self.posts[index].postCompany = value?["company"] as? String
                        self.posts[index].postCity = value?["city"] as? String
                        
                        let indexPath = IndexPath(item: index, section: 0)
                        self.postedTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
                
                ref.child("UserPosted").child(uid!).observe(.childAdded, with: { (snapshot) in
                    
                    if !snapshot.exists() {
                        self.removeLoadingScreen()
                        self.noPostJobView.isHidden = false
                        return}
                    
                    guard let restDict = snapshot.value as? [String:Any] else
                    {
                        print("Snapshot is nil hence no data returned")
                        return
                    }
                    
                    let postpost = Post()
                    
                    if let postImage = restDict["postimage"] as? String {
                        postpost.postImage = postImage
                    }
                    if let postTitle = restDict["title"] as? String {
                        postpost.postTitle = postTitle
                    }
                    if let postDesc = restDict["desc"] as? String {
                        postpost.postDesc = postDesc
                    }
                    if let postClosed = restDict["closed"] as? String {
                        postpost.postClosed = postClosed
                    }
                    if let postCompany = restDict["company"] as? String {
                        postpost.postCompany = postCompany
                    }
                    if let postCity = restDict["city"] as? String {
                        postpost.postCity = postCity
                    }
                    if let postPressed = restDict["pressed"] as? String {
                        postpost.postPressed = postPressed
                    }
                    if let posttotalhiredcount = restDict["totalhiredcount"] as? Double {
                        postpost.totalhiredcount = posttotalhiredcount
                    }
                    if let applicantscount = restDict["applicantscount"] as? Double {
                        postpost.applicantscount = applicantscount
                    }
                    if let newapplicantscount = restDict["newapplicantscount"] as? Double {
                        postpost.newapplicantscount = newapplicantscount
                    }
                    if let postKey = snapshot.key as? String{
                        postpost.postKey = postKey
                    }
                    
                    self.posts.insert(postpost, at: 0)
                    
                    self.postedTableView.reloadData()
                    self.removeLoadingScreen()
                    
                    if (!self.noPostJobView.isHidden) {
                        self.removeLoadingScreen()
                        self.noPostJobView.isHidden = true
                    }
                    
                })
                
                
                ref.child("UserPosted").child(uid!).observe(.childRemoved, with: { (snapshot) in
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.posts.remove(at: indexPath.row)
                        self.postedTableView.beginUpdates()
                        self.postedTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.postedTableView.endUpdates()
                        
                        if (self.posts.count == 0) {
                            self.removeLoadingScreen()
                            self.noPostJobView.isHidden = false
                        }
                    }
                })
                
            }

        }
        else {
            self.removeLoadingScreen()
            self.noPostJobView.isHidden = false
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
    
    func checkDates(postkey: String) {
        
        self.ref.child("UserPostedHiredApplicants").child(self.uid).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                if let applicantid = rest.key as? String {
                    
                    if  let postReviewed = restDict["reviewed"] as? String {}
                    else {
                        if let postDate = restDict["date"] as? String {
                            
                            var lastdate = ""
                            
                            if postDate.contains("/") {
                                let items = postDate.components(separatedBy: "/")
                                lastdate = items[items.count - 1]
                                
                            }else if postDate.contains("to"){
                                let items = postDate.components(separatedBy: "to")
                                lastdate = items[1]
                            }else{
                                lastdate = postDate
                            }
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd MMM yy"
                            var enddate = formatter.date(from: lastdate)
                            var datenow = Date()
                            
                            if(enddate! > datenow){
                                
                                //End date has over today's date, show review
                                if  let postReviewpressed = restDict["reviewpressed"] as? String {}
                                else {
                                    self.ref.child("UserPostedHiredApplicants").child(self.uid).child(postkey).child(applicantid).child("reviewpressed").setValue("false")
                                }
                            }
                            
                        }
                    }
                }
            }
        })
        
    }
    
    func CloseJob(postkey: String, city: String, totalapplicantscount: Int){
        
        // create the alert
        let alert = UIAlertController(title: "Close Job", message: "Are you sure you want to close this job? No further applications will be received", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                let ref = Database.database().reference()
                
                // Close the job at mJob so it wont show at HomePage
                ref.child("Job").child(city).child(postkey).child("closed").setValue("true")
                //Close the job at Posted Tab, so it will display Job Closed. Remove all new applicnats
                ref.child("UserPosted").child(uid!).child(postkey).child("closed").setValue("true")
                ref.child("UserPosted").child(uid!).child(postkey).child("applicantscount").setValue(0)
                ref.child("UserPosted").child(uid!).child(postkey).child("newapplicantscount").setValue(0)
                
                if (totalapplicantscount > 0) {
                    //Notify all PENDING applicants who has applied to the job about the job has closed
                    ref.child("UserPostedPendingApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                        
                        if !snapshot.exists() {
                            
                            return
                            
                        }
                        
                        for rest in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            if let applicantid = rest.key as? String{
                                
                                ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("closed").setValue("true")
                                ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("status").setValue("appliedrejected")
                                
                            }
                        }
                        
                        ref.child("UserPostedPendingApplicants").child(uid!).child(postkey).removeValue()
                    })
                    
                    //Notify all SHORTLISTED applicants who has applied to the job about the job has closed
                    ref.child("UserPostedShortlistedApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                        
                        if !snapshot.exists() {
                            
                            return
                            
                        }
                        
                        for rest in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            if let applicantid = rest.key as? String{
                                
                                ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("closed").setValue("true")
                                ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("status").setValue("appliedrejected")
                                
                            }
                        }
                        
                        ref.child("UserPostedShortlistedApplicants").child(uid!).child(postkey).removeValue()
                    })
                    
                    //Notify all HIRED applicants who has applied to the job about the job has closed
                    ref.child("UserPostedHiredApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                        
                        if !snapshot.exists() {
                            
                            return
                            
                        }
                        
                        for rest in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            if let applicantid = rest.key as? String{
                                
                                ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("closed").setValue("true")
                                
                            }
                        }
                        
                    })
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func RemoveJob(city: String, postkey:String, postimage:String){
        
        // create the alert
        let alert = UIAlertController(title: "Remove Job", message: "Are you sure you want to remove this job?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.default, handler: { action in
            
            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                let ref = Database.database().reference()
                let mGeoFire = ref.child("JobsLocation").child(city)
                let storage = Storage.storage()
                
                if city != nil {
                    ref.child("Job").child(city).child(postkey).removeValue()
                    ref.child("UserPosted").child(uid!).child(postkey).removeValue()
                    mGeoFire.child(postkey).removeValue()
                }
                
                //Notify all PENDING applicants who has applied to the job about the job has closed
                ref.child("UserPostedPendingApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        
                        return
                        
                    }
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let applicantid = rest.key as? String{
                            ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("status").setValue("removed")
                            
                        }
                    }
                    
                    ref.child("UserPostedPendingApplicants").child(uid!).child(postkey).removeValue()
                })
                
                //Notify all SHORTLISTED applicants who has applied to the job about the job has closed
                ref.child("UserPostedShortlistedApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        
                        return
                        
                    }
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let applicantid = rest.key as? String{
                            
                            ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("status").setValue("removed")
                            
                        }
                    }
                    
                    ref.child("UserPostedShortlistedApplicants").child(uid!).child(postkey).removeValue()
                })
                
                //Notify all HIRED applicants who has applied to the job about the job has closed
                ref.child("UserPostedHiredApplicants").child(uid!).child(postkey).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        
                        return
                        
                    }
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let applicantid = rest.key as? String{
                            
                            ref.child("UserActivities").child(applicantid).child("Applied").child(postkey).child("status").setValue("removed")
                            
                        }
                    }
                    ref.child("UserPostedHiredApplicants").child(uid!).child(postkey).removeValue()
                })
                
                if (self.mjobbg1 == nil || self.mjobbg2 == nil || self.mjobbg3 == nil) {
                    return
                }
                
                if (postimage != self.mjobbg1 && postimage != self.mjobbg2 && postimage != self.mjobbg3) {
                    
                    let oldpath = storage.reference(forURL: postimage)
                    
                    oldpath.delete(completion: { (err) in
                        if let err = err {
                            print("error deleting file")
                        }
                        else {
                            print("file deleted")
                        }
                    })
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}

let postimageCache = NSCache<NSString, UIImage>()
extension UIImageView{
    func downloadpostImage(from imgURL: String){
        let url = URLRequest(url: URL(string:imgURL)!)
        
        image = nil
        
        if let imageToCache = postimageCache.object(forKey: imgURL as NSString){
            self.image = imageToCache
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){
            (data, response, error) in
            
            if error != nil{
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                //create UIImage
                let imageToCache = UIImage(data: data!)
                //add image to cache
                postimageCache.setObject(imageToCache!, forKey: imgURL as NSString)
                self.image = imageToCache
            }
            
        }
        
        task.resume()
    }
}

