//
//  SearchesViewController.swift
//  JobIn24
//
//  Created by MacUser on 19/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SearchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchtxtField       : UITextField!
    @IBOutlet weak var locationLabel        : UILabel!
    @IBOutlet weak var searchwordTableView  : UITableView!
    @IBOutlet weak var categoryScrollView   : UIScrollView!
    
    var searchTimer: Timer?
    
    var searchplaceholderLabel : UILabel!
    
    //var searchresult = [String]()
    var searchresult = [Post]()
    
    var location        : String!
    var categoryName    : String!
    var categoryNumber  : Int64!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.dismissKeyboard()
       self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("searchresult.count = \(searchresult.count)")
        
        return searchresult.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tablecell: UITableViewCell!
        
        let wordcell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordSearchTableViewCell
        
        wordcell.searchLabel.text = searchresult.reversed()[indexPath.row].postTitle
        
        print("searchresult.reversed()[indexPath.row].postTitle = \(searchresult.reversed()[indexPath.row].postTitle)")
        
        tablecell = wordcell
        
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let postkey = searchresult.reversed()[indexPath.row].postKey
        let selectedcity = searchresult.reversed()[indexPath.row].postCity
       
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
         
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
         
        destinationVC.postid = postkey
        destinationVC.city = selectedcity
      
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Current Search Location: \(location)")
        
        searchtxtField.delegate = self
        searchtxtField.tag = 0
        searchtxtField.placeholder = "Search Keyword..."
//        searchplaceholderLabel = UILabel()
//        setTextFieldPlaceHolderLabel(phlabel: searchplaceholderLabel,txtfield: searchtxtField)
        
        searchwordTableView.dataSource = self
        searchwordTableView.delegate = self
        
        // dynamic table view cell height
       // searchwordTableView.estimatedRowHeight = searchwordTableView.rowHeight
        //searchwordTableView.rowHeight = UITableViewAutomaticDimension
        
        if location == "" {
            locationLabel.text = "Choose Location"
        }
        else {
            locationLabel.text = location
        }
  
    }
    
    func setTextFieldPlaceHolderLabel(phlabel: UILabel, txtfield: UITextField){
        
        if (txtfield.tag == 0){
            phlabel.text = "  Search Keyword.."
        }
       
        phlabel.font = UIFont.systemFont(ofSize: (txtfield.font?.pointSize)!)
        phlabel.sizeToFit()
        txtfield.addSubview(phlabel)
        phlabel.frame.origin = CGPoint(x: 5, y: (txtfield.font?.pointSize)! / 2)
        phlabel.textColor = UIColor.white
        phlabel.alpha = 0.7
        phlabel.isHidden = false
    }

   
    @IBAction func onBackPressed(_ sender: UIButton) {
        
     self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clearbtnPressed(_ sender: UIButton) {
        
        searchtxtField.text = ""
        categoryScrollView.isHidden = false
        searchwordTableView.isHidden = true


    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector:  #selector(locationSelected(_:)), name: NSNotification.Name(rawValue: AppConstant.notification_selectLocationToSearchMenu), object: nil)
        
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToStateList , sender: self)
    }
    
    @IBAction func searchtxtFieldChanged(_ sender: UITextField) {
       
        let searchword = searchtxtField.text
        
        if (searchword != "") {
//            self.searchplaceholderLabel.isHidden = true
            categoryScrollView.isHidden = true
            searchwordTableView.isHidden = false
        }
        else{
//            self.searchplaceholderLabel.isHidden = false
            categoryScrollView.isHidden = false
            searchwordTableView.isHidden = true
        }
        
        
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchForKeyword(_ :)), userInfo: ["searchText": searchtxtField.text!], repeats: false)

    }
   
    @objc func locationSelected(_ notification: Notification){
        if (notification.object != nil){
            let object = notification.object
            let dict = object as! NSDictionary            
            let selectedLocation = dict["location"] as! String
            print(selectedLocation)
            
            locationLabel.text = selectedLocation
            location = selectedLocation
            print("Location Updated to : \(location)")
        }
    }
    
    
    @objc func searchForKeyword(_ timer: Timer) {
        
        let keyword = timer.userInfo as! Dictionary<String, AnyObject>
        
        let stringkeyword = keyword["searchText"] as! String
        let lowerkeyword = stringkeyword.lowercased()
        print("lowerkeyword: \(lowerkeyword)") 
        
        if (lowerkeyword != "" && location != "") {
            
            let ref = Database.database().reference()
            ref.child("Job").child(location).queryOrdered(byChild: "lowertitle").queryStarting(atValue: lowerkeyword).queryEnding(atValue: lowerkeyword+"~").queryLimited(toFirst: 15).observeSingleEvent(of: .value, with: { snapshot in
                
                if !snapshot.exists() {return}
                print("Got Result")
                print("Clear Current Table\n")
                
                self.searchresult.removeAll()
               
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let postpost = Post()
                    print("***************************** SnapShot Response******************************\n")
                    print("Response: \(rest)\n")
                    print("*************************************************************\n")
                    
                    guard let restDict = rest.value as? [String: Any]
                        else {
                            print("else part")
                            continue }
                    
                    if let postTitle    = restDict["title"] as? String,
                        let postCity    = restDict["city"] as? String,
                        let postKey     = restDict["postkey"] as? String
                    {
                        print("Post Key: \(postKey)")

                        postpost.postCity   = postCity
                        postpost.postTitle  = postTitle
                        postpost.postKey    = postKey
                        self.searchresult.append(postpost)
                    }
                }
                
                self.searchwordTableView.reloadData()
            })
        }

    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueIdentifier_SearchMenuToCategoryResult{
            let dest = segue.destination as! SearchCategoryViewController
            dest.categoryTitle  = categoryName
            dest.categoryNumber = categoryNumber
            dest.currentCity    = location
        }
        
    }
    
    
    @IBAction func baristaBtnPressed(_ sender: Any) {
        print("[Barista Catergory Selected]\n")
        categoryName    = "Barista / Bartender"
        categoryNumber  = 11
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func beautyBtnPressed(_ sender: Any) {
        print("[Beauty Catergory Selected]\n")
        categoryName    = "Beauty / Wellness"
        categoryNumber  = 12
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func chefBtnPressed(_ sender: Any) {
        print("[Chef Catergory Selected]\n")
        categoryName    = "Chef / Kitchen Helper"
        categoryNumber  = 13
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func eventBtnPressed(_ sender: Any) {
        print("[Event Catergory Selected]\n")
        categoryName    = "Event Crew"
        categoryNumber  = 14
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func emceeBtnPressed(_ sender: Any) {
        print("[Emcee Catergory Selected]\n")
        categoryName    = "Emcee"
        categoryNumber  = 15
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func educationBtnPressed(_ sender: Any) {
        print("[Education Catergory Selected]\n")
        categoryName    = "Education"
        categoryNumber  = 16
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }

    @IBAction func fitnessBtnPressed(_ sender: Any) {
        print("[Fitness Catergory Selected]\n")
        categoryName    = "Fitness / Gym"
        categoryNumber  = 17
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func modellingBtnPressed(_ sender: Any) {
        print("[Modelling Catergory Selected]\n")
        categoryName    = "Modelling / Shooting"
        categoryNumber  = 18
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }

    @IBAction func mascotBtnPressed(_ sender: Any) {
        print("[Mascot Catergory Selected]\n")
        categoryName    = "Mascot"
        categoryNumber  = 19
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func officeBtnPressed(_ sender: Any) {
        print("[Office Catergory Selected]\n")
        categoryName    = "Office / Admin"
        categoryNumber  = 20
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func promoterBtnPressed(_ sender: Any) {
        print("[Promoter Catergory Selected]\n")
        categoryName    = "Promoter / Sampling"
        categoryNumber  = 21
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func roadshowBtnPressed(_ sender: Any) {
        print("[Roadshow Catergory Selected]\n")
        categoryName    = "Roadshow"
        categoryNumber  = 22
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func rovingBtnPressed(_ sender: Any) {
        print("[Roving Catergory Selected]\n")
        categoryName    = "Roving Team"
        categoryNumber  = 23
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func retailBtnPressed(_ sender: Any) {
        print("[Retail Catergory Selected]\n")
        categoryName    = "Retial / Consumer"
        categoryNumber  = 24
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func servingBtnPressed(_ sender: Any) {
        print("[Serving Catergory Selected]\n")
        categoryName    = "Serving"
        categoryNumber  = 25
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func usherBtnPressed(_ sender: Any) {
        print("[Usher Catergory Selected]\n")
        categoryName    = "Usher / Ambassador"
        categoryNumber  = 26
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func waiterBtnPressed(_ sender: Any) {
        print("[Waiter Catergory Selected]\n")
        categoryName    = "Waiter / Waitress"
        categoryNumber  = 27
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    
    @IBAction func otherBtnPressed(_ sender: Any) {
        print("[Other Catergory Selected]\n")
        categoryName    = "Other"
        categoryNumber  = 28
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_SearchMenuToCategoryResult, sender: self)
    }
    




}
