//
//  ProfileViewController4.swift
//  JobIn24
//
//  Created by MacUser on 26/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import NVActivityIndicatorView

class ProfileViewController4: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var profileimage: UIImageView!
    
    @IBOutlet weak var profileLocation: UILabel!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var reviewStarView: CosmosView!
    
    @IBOutlet weak var loadingView      : UIView!
    @IBOutlet weak var loadingIndicator : NVActivityIndicatorView!
    
    var usercoverImage: String?

    var countValue = 0
    var oldcountValue = 0
    
    var segmentindex = 0
 
    var segmentint = true
  
    var reviewposts = [UserReview]()
    
    var profileabout = ["none"]
    var profileemail = ["none"]
    var profilephone = ["none"]
    var profileworktitle = ["none","none","none","none","none"]
    var profileworkplace = ["none","none","none","none","none"]
    var profileworklength = ["none","none","none","none","none"]
    var profileeducation = ["none"]
    var profilelanguages = ["none"]
    
    var profileGender       = ["none"]
    var profileBirthdate    = ["none"]
    var profileWeight       = ["none"]
    var profileHeight       = ["none"]
    
    var reviewcount5: Double?
    var reviewcount4: Double?
    var reviewcount3: Double?
    var reviewcount2: Double?
    var reviewcount1: Double?
    var totalreviewcount: Double? = 0.0
    
    var refreshControl: UIRefreshControl!
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var tablecell: UITableViewCell!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell") as! SegmentTableViewCell
        
        cell.swsegmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: UIControlEvents.valueChanged)
        
        if(segmentint){
            
            cell.swsegmentControl.selectedSegmentIndex = 0
            
            self.segmentint = false
        }
        else{
            
            cell.swsegmentControl.selectedSegmentIndex = self.segmentindex
        }
        
        tablecell = cell
        
        return tablecell
        
    }
    
    @objc func segmentSelected(sender: SWSegmentedControl){
        
        if(sender.selectedSegmentIndex == 1){
            loadReviewData()
            self.countValue = reviewposts.count
            print("select1")
            
        }
        else if(sender.selectedSegmentIndex == 0){
            loadProfileData()
            self.countValue = 5
            print("select0")
            
        }
        
        self.segmentindex = sender.selectedSegmentIndex
        self.oldcountValue = self.countValue
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(segmentindex == 0){
            
            self.countValue = 5
            
            print(self.countValue)
        }
        else if(segmentindex == 1){
            
            self.countValue = reviewposts.count
            print(self.countValue)
        }
        
        return countValue
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        if(segmentindex == 0){
            
            var insidetablecell: UITableViewCell!
            
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ProfileInfoCell
               
                if(profileabout[0] != "none"){
                    cell.profileDescrip.setLineHeight(lineHeight: 5, textstring: profileabout[0])
                    cell.profileDescrip.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.profileDescrip.text = "No Description Added"
                    cell.profileDescrip.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                    
                }
               
                if(profileBirthdate[0] != "none"){
                    cell.birthdateLabel.setLineHeight(lineHeight: 5, textstring: profileBirthdate[0])
                    cell.birthdateStackView.isHidden = false
                }
                else{
                    cell.birthdateStackView.isHidden = true
                }
                
                
                if(profileGender[0] != "none"){
                    cell.genderLabel.setLineHeight(lineHeight: 5, textstring: profileGender[0])
                    cell.genderStackView.isHidden = false
                }
                else{
                    cell.genderStackView.isHidden = true
                }
                
                if(profileWeight[0] != "none"){
                    cell.weightLabel.setLineHeight(lineHeight: 5, textstring: profileWeight[0] + " kg")
                    cell.weightStackView.isHidden = false
                }
                else{
                    cell.weightStackView.isHidden = true
                }
                
                if(profileHeight[0] != "none"){
                    cell.heightLabel.setLineHeight(lineHeight: 5, textstring: profileHeight[0] + " cm")
                    cell.heightStackView.isHidden = false
                }
                else{
                    cell.heightStackView.isHidden = true
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
                
                if (profileemail.count > 0) {
                    if(profileemail[0] != "none"){
                        cell.emailLabel.setLineHeight(lineHeight: 5, textstring: profileemail[0])
                        cell.emailLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                    }
                    else{
                        cell.emailLabel.text = "No Email Added"
                        cell.emailLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                    }
                }
                
                
                
                if(profilephone[0] != "none"){
                    cell.phoneLabel.setLineHeight(lineHeight: 5, textstring: profilephone[0])
                    cell.phoneLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.phoneLabel.text = "No Phone Added"
                    cell.phoneLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 2){
                
                if(profileworktitle[0] == "none" && profileworkplace[0] == "none"){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoWorkExpCell", for: indexPath) as! NoWorkTableViewCell
                    
                    cell.worklabel.text = "Not Work Experience"
                    cell.worklabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                    insidetablecell = cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkCell2", for: indexPath) as! WorkTableViewCell2
                    
                    for i in (0..<5)
                    {
                        var workTitle: UILabel!
                        var workCompany: UILabel!
                        var workView: UIView!
                        
                        if(i == 0){
                            workTitle = cell.workTitle1
                            workCompany = cell.workCompany1
                            workView = cell.workView1
                        }
                        else if(i == 1){
                            workTitle = cell.workTitle2
                            workCompany = cell.workCompany2
                            workView = cell.workView2
                        }
                        else if (i == 2){
                            workTitle = cell.workTitle3
                            workCompany = cell.workCompany3
                            workView = cell.workView3
                        }
                        else if (i == 3){
                            workTitle = cell.workTitle4
                            workCompany = cell.workCompany4
                            workView = cell.workView4
                        }
                        else if (i == 4){
                            workTitle = cell.workTitle5
                            workCompany = cell.workCompany5
                            workView = cell.workView5
                        }
                        
                        if(profileworktitle[i] != "none"){
                            workTitle.setLineHeight(lineHeight: 5, textstring: profileworktitle[i])
                        }
                        else{
                            print("ixx1 =  \(i)")
                            workView.isHidden = true
                        }
                        if(profileworkplace[i] != "none"){
                            workCompany.setLineHeight(lineHeight: 5, textstring: profileworkplace[i])
                        }
                        else{
                            workView.isHidden = true
                        }
                        
                    }
                    
                      insidetablecell = cell
                }

              
                
            }
                
            else if (indexPath.row == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EduTableViewCell
                
                if(profileeducation[0] != "none"){
                    cell.eduLabel.setLineHeight(lineHeight: 5, textstring: profileeducation[0])
                    cell.eduLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.eduLabel.text = "Not Education Added"
                    cell.eduLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
                
            else if (indexPath.row == 4){
                let cell = tableView.dequeueReusableCell(withIdentifier: "LanguagesCell", for: indexPath) as! LanguagesTableViewCell
                
                if(profilelanguages[0] != "none"){
                    cell.languagesLabel.setLineHeight(lineHeight: 5, textstring: profilelanguages[0])
                    cell.languagesLabel.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
                }
                else{
                    cell.languagesLabel.text = "Not Languages Added"
                    cell.languagesLabel.textColor = UIColor(red: 88/255, green: 92/255, blue: 95/255, alpha: 0.7)
                }
                
                insidetablecell = cell
            }
            
            tablecell = insidetablecell
        }
        
        else if (segmentindex == 1){
            print("self.countValue1 \(self.countValue)")
            
            var insidereviewcell: UITableViewCell!

            if(reviewposts.count != 0){
                
                let reviewcell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ProfileReviewCell

                reviewcell.userImage.sd_setImage(with: URL(string: self.reviewposts[indexPath.row].userImage), placeholderImage: UIImage(named: "userprofile_default"))
                
                //reviewcell.userImage.downloadprofileImage(from: self.reviewposts[indexPath.row].userImage)
                
                reviewcell.userName.text =  self.reviewposts[indexPath.row].userName
                
                reviewcell.userReviewMessage.setLineHeight(lineHeight: 2.5, textstring: self.reviewposts[indexPath.row].userReviewMessage)
                
                //reviewcell.userReviewMessage.text = self.reviewposts[indexPath.row].userReviewMessage
                
                reviewcell.timeLabel.text =  self.reviewposts[indexPath.row].userTime
                
                reviewcell.reviewRating.rating =  self.reviewposts[indexPath.row].userRating
                
                
                insidereviewcell = reviewcell
            }
            else if (reviewposts.count == 0) {
                
                print("noreview")
                
            }
            
            tablecell = insidereviewcell
        }
        
        
        return tablecell
    }
    
    @objc func updateInfo(_ notification: NSNotification) {
        
        loadProfileData()
        
        if let ProfileImageval = notification.userInfo?["ProfileImage"] as? String {
            if (ProfileImageval != "") {
                self.profileimage.downloadprofileImage(from: ProfileImageval)
            }
        }
        if let CoverImageval = notification.userInfo?["CoverImage"] as? String {
            if (CoverImageval != "") {
                self.coverImage.downloadprofileImage(from: CoverImageval)
            }
        }
        if let CurrentCityval = notification.userInfo?["CurrentCity"] as? String {
            if (CurrentCityval != "") {
                self.profileLocation.text = CurrentCityval
            }
        }
        if let nameval = notification.userInfo?["name"] as? String {
            if (nameval != "") {
                self.profileName.text = nameval
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("=======================\nMy Profile Page\n=======================")
       // setupLoadingView(visible: true)
        checkInternetBeforeRun()

    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingView(visible: true)

        // Do any additional setup after loading the view.
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
        
        // dynamic table view cell height
        profileTableView.estimatedRowHeight = profileTableView.rowHeight
        profileTableView.rowHeight = UITableViewAutomaticDimension
        
      
        profileimage.layer.cornerRadius = profileimage.frame.size.width/2
        profileimage.clipsToBounds = true
        profileimage.layer.borderWidth = 2.0
        profileimage.layer.borderColor = UIColor.white.cgColor
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //let testUIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(ProfileViewController4.editButton))
        //self.navigationItem.rightBarButtonItem  = testUIBarButtonItem

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        profileTableView.addSubview(refreshControl)
       
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController4.updateInfo(_:)), name: Notification.Name("updateInfo"), object: nil)
        
//        checkInternetBeforeRun()

    }
    
    @objc func refresh(sender:AnyObject) {
        
        
        // Code to refresh table view
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            loadPictureName(uid:uid!)
            
            loadLocation(uid:uid!)
            
            loadReviewStar(uid:uid!)
            
            loadProfileData()
            
        }
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.refreshControl.endRefreshing()
        }

    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsBtnPressed(_ sender: UIBarButtonItem) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileTableViewController") as! EditProfileTableViewController

        self.navigationController?.pushViewController(nextViewController, animated: true)
        

        
    }
    
    func setupLoadingView(visible: Bool){
        if visible{
            loadingView.isHidden = false
            loadingIndicator.startAnimating()
        }else{
            
            UIView.transition(with: loadingView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.loadingView.isHidden = true
            }) { (true) in
                self.loadingIndicator.stopAnimating()
            }
        }
        
    }
    
    func checkInternetBeforeRun(){
        print("[CHECK INTERNET CONNECTION]\n=========================================\n")
        if ReachabilityTest.isConnectedToNetwork() {
            print("[Check Internet Connection]: Internet connection available")

            let currentUser = Auth.auth().currentUser
            
            if(currentUser != nil){
                
                let uid = currentUser?.uid
                
                loadPictureName(uid:uid!)
                
                loadLocation(uid:uid!)
                
                loadReviewStar(uid:uid!)
                
                loadProfileData()
                
            }
            
        }
        else{
            print("[Check Internet Connection]: No internet connection")
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
                self.checkInternetBeforeRun()
            }
            noInternetAlertForceRetry(buttonAction: retryAction)
        }
    }
    
    func loadReviewStar(uid:String) {
        
        let ref = Database.database().reference()
        
        self.reviewLabel.text = "\(Int(totalreviewcount!)) Reviews"
        self.reviewStarView.rating =  0
        
        ref.child("UserReview").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                return
            }
            
            if(snapshot.hasChild("Rate5")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate5").value as? Double
                {
                    self.reviewcount5 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate4")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate4").value as? Double
                {
                    self.reviewcount4 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate3")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate3").value as? Double
                {
                    self.reviewcount3 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate2")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate2").value as? Double
                {
                    self.reviewcount2 = getReviewData
                }
            }
            if(snapshot.hasChild("Rate1")){
                if let getReviewData = snapshot.childSnapshot(forPath: "Rate1").value as? Double
                {
                    self.reviewcount1 = getReviewData
                }
            }
            
            if (self.reviewcount5 != nil && self.reviewcount4 != nil && self.reviewcount3 != nil && self.reviewcount2 != nil && self.reviewcount1 != nil ){
                
                self.totalreviewcount = self.reviewcount5! + self.reviewcount4! + self.reviewcount3! + self.reviewcount2! + self.reviewcount1!
                
                let top1divider = (5*self.reviewcount5!)+(4*self.reviewcount4!)+(3*self.reviewcount3!)
                
                let top2divider = (2*self.reviewcount2!)+(1*self.reviewcount1!)
                
                let combinedivider = top1divider+top2divider
                
                let starcount = combinedivider/self.totalreviewcount!
                
                let inttotalreview = Int(self.totalreviewcount!)
                
                self.reviewLabel.text = "\(inttotalreview) Reviews"
                
                self.reviewStarView.rating =  starcount
            }
            
        })
        
        ref.removeAllObservers()
    }
    
    func loadLocation(uid:String) {
        
        let ref = Database.database().reference()
        
        ref.child("UserLocation").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                self.profileLocation.text = "Somewhere on earth"
                return
            }
            
            if (snapshot.hasChild("CurrentCity")){
                if (snapshot.childSnapshot(forPath: "CurrentCity").value as? String) != nil
                {
                    self.profileLocation.text = snapshot.childSnapshot(forPath: "CurrentCity").value as? String
                    
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    func loadPictureName(uid:String) {
        
        let ref = Database.database().reference()
        
        ref.child("UserAccount").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {return}
            
            if let getData = snapshot.value as? [String:Any]{
                print(getData)
                
                let userName    = getData["name"] as? String
                let userImage   = getData["image"] as? String
                
                self.profileimage.sd_setImage(with: URL(string: userImage!), placeholderImage: UIImage(named: "userprofile_default"))
                
                self.usercoverImage     = userImage
                self.profileName.text   = userName
                self.setupLoadingView(visible: false)

            }
            
        })
        
        ref.child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.childSnapshot(forPath: uid).exists()){
                
                if let viewWithTag = self.coverImage.viewWithTag(100) {
                    viewWithTag.removeFromSuperview()
                }
                
                self.coverImage.sd_setImage(with: URL(string: self.usercoverImage!), placeholderImage: UIImage(named: "profilebg3"))
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.tag = 100
                blurEffectView.frame = self.coverImage.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.coverImage.addSubview(blurEffectView)
                return
            }
            
            if let getData = snapshot.childSnapshot(forPath: uid).value as? [String:Any]{
                
                if snapshot.childSnapshot(forPath: uid).hasChild("CoverImage"){
                    
                    if let viewWithTag = self.coverImage.viewWithTag(200) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                    let userCoverImage = getData["CoverImage"] as? String
                    self.coverImage.sd_setImage(with: URL(string: userCoverImage!), placeholderImage: UIImage(named: "profilebg3"))
                    
                    let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width: self.coverImage.frame.size.width, height: self.coverImage.frame.size.height))
                    overlay.backgroundColor = UIColor(red:0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                    overlay.tag = 200
                    self.coverImage.addSubview(overlay)
                    
                }
                else{
                    
                    if let viewWithTag = self.coverImage.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                    self.coverImage.sd_setImage(with: URL(string: self.usercoverImage!), placeholderImage: UIImage(named: "profilebg3"))
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.tag = 100
                    blurEffectView.frame = self.coverImage.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.coverImage.addSubview(blurEffectView)
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    func loadProfileData(){
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(!snapshot.hasChild(uid!)){
                    
                     self.profileabout      = ["none"]
                     self.profileemail      = ["none"]
                     self.profilephone      = ["none"]
                     self.profileGender     = ["none"]
                     self.profileBirthdate  = ["none"]
                     self.profileWeight     = ["none"]
                     self.profileHeight     = ["none"]
                     self.profileworktitle  = ["none","none","none","none","none"]
                     self.profileworkplace  = ["none","none","none","none","none"]
                     self.profileworklength = ["none","none","none","none","none"]
                     self.profileeducation  = ["none"]
                     self.profilelanguages  = ["none"]
                    
                    self.profileTableView.reloadData()
                    
                    return
                }else{
                    self.profileabout.removeAll()
                    self.profileemail.removeAll()
                    self.profilephone.removeAll()
                    self.profileGender.removeAll()
                    self.profileBirthdate.removeAll()
                    self.profileWeight.removeAll()
                    self.profileHeight.removeAll()
                    self.profileworktitle.removeAll()
                    self.profileworkplace.removeAll()
                    self.profileworklength.removeAll()
                    self.profileeducation.removeAll()
                    self.profilelanguages.removeAll()
                }

                if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp1"){
                    if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp1").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp2"){
                    if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp2").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp3"){
                    if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp3").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp4"){
                    if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp4").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                
                if snapshot.childSnapshot(forPath: uid!).hasChild("WorkExp5"){
                    if let getWorkData = snapshot.childSnapshot(forPath: uid!).childSnapshot(forPath: "WorkExp5").value as? [String:Any]
                    {
                        if let userDescrip = getWorkData["worktitle"] as? String
                        {
                            self.profileworktitle.append(userDescrip)
                            
                        }
                        if let userDescrip = getWorkData["workcompany"] as? String
                        {
                            self.profileworkplace.append(userDescrip)
                            
                        }
                    }
                }
                else{
                    self.profileworktitle.append("none")
                    self.profileworkplace.append("none")
                }
                
                if let getData = snapshot.childSnapshot(forPath: uid!).value as? [String:Any]{
                    
                    if let userDescrip = getData["About"] as? String
                    {
                        self.profileabout.append(userDescrip)
                        
                    }
                    else{
                        self.profileabout.append("none")
                    }
                    
                    if let userAge = getData["Age"] as? String
                    {
                        self.profileBirthdate.append(userAge)
                        
                    }
                    else{
                        self.profileBirthdate.append("none")
                    }
                    
                    if let userGender = getData["Gender"] as? String
                    {
                        if userGender == "" {
                            self.profileGender.append("none")
                        }
                        else {
                             self.profileGender.append(userGender)
                        }
                    }
                    else{
                        self.profileGender.append("none")
                    }
                    
                    if let userWeight = getData["Weight"] as? String
                    {
                        self.profileWeight.append(userWeight)
                        
                    }
                    else{
                        self.profileWeight.append("none")
                    }
                    
                    if let userHeight = getData["Height"] as? String
                    {
                        self.profileHeight.append(userHeight)
                        
                    }
                    else{
                        self.profileHeight.append("none")
                    }
                    
                    if let userEmail = getData["Email"] as? String
                    {
                        self.profileemail.append(userEmail)
                        
                    }
                    else{
                        self.profileemail.append("none")
                    }
                    
                    
                    if let userPhone = getData["Phone"] as? String
                    {
                        self.profilephone.append(userPhone)
                        
                    }
                    else{
                        self.profilephone.append("none")
                    }
                    
                    
                    if let userEducation = getData["Education"] as? String
                    {
                        self.profileeducation.append(userEducation)
                        
                    }
                    else{
                        self.profileeducation.append("none")
                    }
                    
                    
                    if let userLanguage = getData["Language"] as? String
                    {
                        self.profilelanguages.append(userLanguage)
                        
                    }
                    else{
                        self.profilelanguages.append("none")
                    }
                    
                    self.profileTableView.reloadData()
                }
            })
            
            ref.removeAllObservers()
        }
    }
    
    func loadReviewData(){
        
        let currentUser = Auth.auth().currentUser
        
        if(currentUser != nil){
            
            let uid = currentUser?.uid
            
            let ref = Database.database().reference()
            
            ref.child("UserReview").child(uid!).child("Review").queryOrdered(byChild: "time").observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {
                    self.reviewposts.removeAll()
                    self.profileTableView.reloadData()
                    return
                    
                }
                
                self.reviewposts.removeAll()
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let reviewreview = UserReview()
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    if let userReviewMessage = restDict["reviewmessage"] as? String,
                        let userImage = restDict["userimage"] as? String,
                        let userName = restDict["username"] as? String,
                        let ratingstar = restDict["rating"] as? Double,
                        let t = restDict["time"] as? TimeInterval {
                        
                        let poststartdate = Date(timeIntervalSince1970: t/1000)
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "dd MMM yyyy"
                        let strDate = dateFormatter.string(from: poststartdate)
                        
                        reviewreview.userName = userName
                        reviewreview.userImage = userImage
                        reviewreview.userReviewMessage = userReviewMessage
                        reviewreview.userTime = strDate
                        reviewreview.userRating = ratingstar
                        
                        self.reviewposts.append(reviewreview)
                        
                    }
                }
                
                self.profileTableView.reloadData()
                
            })
            
            ref.removeAllObservers()
            
        }
    }
    

}


extension UIImageView{
    func downloadprofileImage(from imgURL: String){
        let url = URLRequest(url: URL(string:imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url){
            (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            
            if response != nil{
                let responseData = response as! HTTPURLResponse

                if (responseData.statusCode == 200){
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data!)
                    }
                }
            }
        }
        
        task.resume()
    }
    
}

extension UILabel
{
    func setLineHeight(lineHeight: CGFloat, textstring: String)
    {
        
        
        let attributeString = NSMutableAttributedString(string: textstring)
        let style = NSMutableParagraphStyle()
        
        style.lineSpacing = lineHeight
        attributeString.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey,
                                     value: style,
                                     range: NSMakeRange(0, textstring.characters.count))
        
        self.attributedText = attributeString
        
    }
}

