//
//  Saved2ViewController.swift
//  JobIn24
//
//  Created by MacUser on 09/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class Saved2ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var savedTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingBallView: UIView!
    
    @IBOutlet weak var loadingBall: NVActivityIndicatorView!
    
    @IBOutlet weak var noSavedJobView: UIView!
    
    var uid:String!
    
    var ref: DatabaseReference!
    
    var posts = [Post]()
    
    var postkey: String!
    
    
    override func viewDidLoad() {
        
        setLoadingScreen()
        
        savedTableView.dataSource = self
        savedTableView.delegate = self
        
        // dynamic table view cell height
        savedTableView.estimatedRowHeight = savedTableView.rowHeight
        savedTableView.rowHeight = UITableViewAutomaticDimension
        
        /*let swipedleft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedleft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipedleft)
        
        let swipedright = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipedright.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipedright)*/
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            if currentUser!.isAnonymous {
                print("[Get Saved Anonymouse User")
                self.showNoSavedScreen()
            }
            else {
                uid = currentUser!.uid
                ref = Database.database().reference()
                ref.child("UserActivities").child(uid!).child("Saved").observeSingleEvent(of: .value, with: { snapshot in
                    
                    if !snapshot.exists() {
                        self.removeLoadingScreen()
                        self.noSavedJobView.isHidden = false
                        return
                        
                    }
                })
                
                ref.child("UserActivities").child(uid!).child("Saved").queryOrdered(byChild: "time").observe(.childAdded, with: { (snapshot) in
                    
                    if !snapshot.exists() {
                        self.showNoSavedScreen()
                        return
                    }
                    
                    guard let restDict = snapshot.value as? [String:Any] else
                    {
                        print("Snapshot is nil hence no data returned")
                        return
                    }
                    
                    let postpost = Post()
                    
                    if  let postImage = restDict["postimage"] as? String {
                        postpost.postImage = postImage
                    }
                    if let postTitle = restDict["title"] as? String {
                        postpost.postTitle = postTitle
                    }
                    if let postDesc = restDict["desc"] as? String {
                        postpost.postDesc = postDesc
                    }
                    if let postCity = restDict["city"] as? String {
                        postpost.postCity = postCity
                    }
                    if let postCompany = restDict["company"] as? String {
                        postpost.postCompany = postCompany
                    }
                    if let postKey = snapshot.key as? String {
                        postpost.postKey = postKey
                    }
                    
                    self.posts.insert(postpost, at: 0)
                    
                    self.savedTableView.reloadData()
                    
                    self.removeLoadingScreen()
                    
                    if (!self.noSavedJobView.isHidden) {
                        self.noSavedJobView.isHidden = true
                    }
                    
                })
                
                ref.child("UserActivities").child(uid!).child("Saved").observe(.childChanged, with: { (snapshot) in
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let value = snapshot.value as? NSDictionary
                        self.posts[index].postImage = value?["postimage"] as? String
                        self.posts[index].postTitle = value?["title"] as? String
                        self.posts[index].postDesc = value?["desc"] as? String
                        self.posts[index].postCompany = value?["company"] as? String
                        self.posts[index].postCity = value?["city"] as? String
                        
                        let indexPath = IndexPath(item: index, section: 0)
                        self.savedTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
                
                ref.child("UserActivities").child(uid!).child("Saved").observe(.childRemoved, with: { (snapshot) in
                    let ID = snapshot.key
                    if let index = self.posts.index(where: {$0.postKey == ID}) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.posts.remove(at: indexPath.row)
                        self.savedTableView.beginUpdates()
                        self.savedTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.savedTableView.endUpdates()
                        
                        if (self.posts.count == 0) {
                            self.noSavedJobView.isHidden = false
                        }
                    }
                })
            }
            
        }
        else {
            self.showNoSavedScreen()
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
        noSavedJobView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
    
    // Remove the activity indicator from the main view
    private func showNoSavedScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        noSavedJobView.isHidden = false
        
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let savedcell = tableView.dequeueReusableCell(withIdentifier: "SavedCell", for: indexPath) as! SavedTableViewCell
        
        if (posts.count > indexPath.row) {
            
            savedcell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "activities_loading"))
            
            //savedcell.postImage.downloadpostImage(from: self.posts[indexPath.row].postImage)
            
            savedcell.postTitle.text = posts[indexPath.row].postTitle
            
            savedcell.postCompany.text = posts[indexPath.row].postCompany
            
            savedcell.postDescrip.text = posts[indexPath.row].postDesc
            
            savedcell.closedView.isHidden = true
            savedcell.closedText.isHidden = true
            savedcell.removedView.isHidden = true
            
            savedcell.closetapBtn = {
                self.DeleteJobAlert(postkey: self.posts[indexPath.row].postKey)
            }
            self.ref.child("Job").child(posts[indexPath.row].postCity).child(self.posts[indexPath.row].postKey).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    savedcell.removedView.isHidden = false
                    return
                }
                else{
                    savedcell.removedView.isHidden = true
                    
                    if  let postClosed = snapshot.childSnapshot(forPath: "closed").value as? String{
                        
                        if(postClosed == "true"){
                            savedcell.closedView.isHidden = false
                            savedcell.closedText.isHidden = false
                        }
                        else{
                            savedcell.closedView.isHidden = true
                            savedcell.closedText.isHidden = true
                        }
                        
                    }
                }
                
            })
            
        }
        
        tablecell = savedcell
        
        
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.ref != nil && uid != nil) {
            
            tableView.deselectRow(at: indexPath, animated: true)
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
        
        //self.presentDetail(destinationVC)
        //destinationVC.modalTransitionStyle = .crossDissolve
        // destinationVC.modalPresentationStyle = .fullScreen
        // self.present(destinationVC, animated:true, completion:nil)
        
    }
    
    func DeleteJobAlert(postkey: String){
        
        // create the alert
        let alert = UIAlertController(title: "Delete Saved Job", message: "Are you sure you want to delete this saved job", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { action in
            
            self.deletejob(postkey:postkey)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func deletejob(postkey: String) {
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let ownuid = currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("UserActivities").child(ownuid!).child("Saved").child(postkey).removeValue();
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
