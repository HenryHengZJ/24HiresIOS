//
//  SearchCategoryViewController.swift
//  JobIn24
//
//  Created by MacUser on 24/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class SearchCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlet & Variable
    @IBOutlet weak var loadingView          : UIView!
    @IBOutlet weak var loadingBallView      : UIView!
    @IBOutlet weak var noJobView            : UIView!
    @IBOutlet weak var currencyfilterLabel  : UILabel!
    @IBOutlet weak var datefilterLabel      : UILabel!
    @IBOutlet weak var noJobLabel           : UILabel!
    @IBOutlet weak var jobTableView         : UITableView!
    @IBOutlet weak var loadingBall          : NVActivityIndicatorView!

    var postkey         : String!
    var selectedcity    : String!
    var titlecity       : String!
    var lastpostTime    : TimeInterval!
    var refreshControl  : UIRefreshControl!
    var ref             : DatabaseReference!

    //Passed In Data
    var categoryTitle       = String()
    var categoryNumber      = Int64()
    var currentCity         = String()
    
    var posts               = [Post]()
    var loadingData         = false
    var pagingindicator     = UIActivityIndicatorView()
    var filterByStart       = String()
    var filterByEnd         = String()
    var startDateString     = String()
    var endDateString       = String()
    var scenario            = Int()
    var filterByWages       = Double()
    var oldFilterByWages    = Bool()
    var finalStartTime      = Int64()
    var finalEndTime        = Int64()
    
    var categoryFirstPostTime                   = Int64()
    var categoryMostRecentStartDate             = Int64()
    var categoryMostRecentWagesRange            = Int64()
    var categoryMostREcentWagesRangeStartDate   = Int64()
    
    
    var count       = 0
    var startDate  : Int64 = 0
    var endDate    : Int64 = 0
    let loadLimit   = 8
    
    //MARK :- IBAction
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterPressed(_ sender: Any) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
//        self.present(nextViewController, animated:true, completion:nil)
        self.performSegue(withIdentifier: AppConstant.segueIdentifier_searchCategoryToFilter, sender: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterFilterChange(_:)) , name: NSNotification.Name(rawValue: "setFilterPage"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueIdentifier_searchCategoryToFilter{
            let dest = segue.destination as! FilterViewController
            print(filterByWages)
            dest.filterbywages      = Int(filterByWages)
            dest.filterbystart      = filterByStart
            dest.filterbyend        = filterByEnd
            dest.oldfilterbywages   = "\(oldFilterByWages)"
        }
    }
    
    // MARK:- View Apprearance
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[Selected Category]: \(categoryTitle)\n")
        
        setLoadingScreen()
        getSortFilter()
        
        currencyfilterLabel.layer.cornerRadius          = 15
        currencyfilterLabel.layer.masksToBounds         = false
        currencyfilterLabel.layer.shouldRasterize       = true
        currencyfilterLabel.layer.rasterizationScale    = UIScreen .main.scale
        currencyfilterLabel.clipsToBounds               = true
        currencyfilterLabel.backgroundColor             = UIColor.white
        
        datefilterLabel.layer.cornerRadius              = 15
        datefilterLabel.layer.masksToBounds             = false
        datefilterLabel.layer.shouldRasterize           = true
        datefilterLabel.layer.rasterizationScale        = UIScreen .main.scale
        datefilterLabel.clipsToBounds                   = true
        datefilterLabel.backgroundColor                 = UIColor.white

        jobTableView.dataSource = self
        jobTableView.delegate   = self
        
        // dynamic table view cell height
        jobTableView.estimatedRowHeight = jobTableView.rowHeight
        jobTableView.rowHeight          = UITableViewAutomaticDimension

    }
    
    
    @objc func reloadAfterFilterChange(_ notification:Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "setFilterPage"), object: nil)
        posts.removeAll()
        setLoadingScreen()
        getSortFilter()
        
        /*if let scenarioval = notification.userInfo?["scenario"] as? Int,
            let filterbywagesval = notification.userInfo?["filterbywages"] as? Int,
            let filterbystartval = notification.userInfo?["filterbystart"] as? String,
            let filterbyendval = notification.userInfo?["filterbyend"] as? String,
            let oldfilterbywagesval = notification.userInfo?["oldfilterbywages"] as? String
            
        {
            self.scenario = scenarioval
            self.filterbywages = filterbywagesval
            self.filterbystart = filterbystartval
            self.filterbyend = filterbyendval
            self.oldfilterbywages = oldfilterbywagesval
            
            print("filterbywages = \(filterbywages)")
            print("filterbystart = \(filterbystart)")
            print("filterbyend = \(filterbyend)")
            print("oldfilterbywages = \(oldfilterbywages)")
            
            if (scenarioval == 33) {
                self.filterNumLabel.text = "0"
            }
            else if (scenarioval == 11 || scenarioval == 3) {
                self.filterNumLabel.text = "1"
            }
            else if (scenarioval == 22 || scenarioval == 1) {
                self.filterNumLabel.text = "2"
            }
            else if (scenarioval == 2) {
                self.filterNumLabel.text = "3"
            }
            
            setLoadingScreen()
            if (self.city != ""){
                refresh()
            }
            else {
                removeLoadingScreen()
            }
        }*/
    }
    
    //MARK:- Core Functions
    
    func getSortFilter(){
        
        let sortFilterRef = Database.database().reference().child("SortFilter")
        let userID = (Auth.auth().currentUser?.uid)!
        
        if userID != ""{
            sortFilterRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    print("Got Filter Snapshot")
                    //Only Start Date Filter
                    //----------------------
                    if snapshot.hasChild("StartDate") && !snapshot.hasChild("EndDate"){
                        self.filterByStart = snapshot.childSnapshot(forPath: "StartDate").value as! String
                        self.filterByEnd = ""
                        
                        if let startDateString = Utilities.changeDateFormat(dateStr: self.filterByStart){
                            self.datefilterLabel.text = startDateString
                            self.datefilterLabel.isHidden = false
                        }
                        
                        if (snapshot.hasChild("OldWagesFilter")){
                            //[Start Date] Show All
                            self.scenario           = 11
                            self.oldFilterByWages   = true
                            self.filterByWages      = snapshot.childSnapshot(forPath: "OldWagesFilter").value as! Double
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            //Hide Currency Filter Label
                            self.currencyfilterLabel.isHidden = true
                            
                        }else if (snapshot.hasChild("WagesFilter")){
                            //[Start Date] Selected Wages Filter
                            
                            self.scenario = 1
                            self.oldFilterByWages = false
                            self.filterByWages = snapshot.childSnapshot(forPath: "WagesFilter").value as! Double
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            //Show Currency Filter Label
                            self.currencyfilterLabel.text       = self.getWagesFilterText(wages: self.filterByWages)
                            self.currencyfilterLabel.isHidden   = false
                            
                        }else{
                            // (1111) Default value: MYR + Per Hour + Less Than 5
                            self.scenario           = 11
                            self.filterByWages      = 1111
                            self.oldFilterByWages   = true
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            self.currencyfilterLabel.isHidden = true
                        }
                    }
                        
                    // Start & End Date Selected
                    //---------------------------

                    else if snapshot.hasChild("StartDate") && snapshot.hasChild("EndDate") {
                        self.filterByStart  = snapshot.childSnapshot(forPath: "StartDate").value as! String
                        self.filterByEnd    = snapshot.childSnapshot(forPath: "EndDate").value as! String

                        if let startDateString = Utilities.changeDateFormat(dateStr: self.filterByStart){
                            if let endDateString = Utilities.changeDateFormat(dateStr: self.filterByEnd){
                                self.datefilterLabel.text       = "\(startDateString) to \(endDateString)"
                                self.datefilterLabel.isHidden   = false
                            }
                        }else{
                            print("[Date Convert Error]")
                        }
                        
                        if(snapshot.hasChild("OldWagesFilter")){
                            //[Start Date & End Date] Show All
                            self.scenario           = 22
                            self.oldFilterByWages   = true
                            self.filterByWages      = snapshot.childSnapshot(forPath: "OldWagesFilter").value as! Double
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            self.currencyfilterLabel.isHidden = true
                            
                        }else if(snapshot.hasChild("WagesFilter")){
                            //[Start Date & End Date] Selected Wages
                            self.scenario = 2
                            self.oldFilterByWages = false
                            self.filterByWages = snapshot.childSnapshot(forPath: "WagesFilter").value as! Double
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            //Show Currency Filter Label
                            self.currencyfilterLabel.text       = self.getWagesFilterText(wages: self.filterByWages)
                            self.currencyfilterLabel.isHidden   = false
                        }else{
                            //[Start Date & End Date] Default
                            self.scenario            = 22
                            self.filterByWages       = 1111
                            self.oldFilterByWages    = true
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber )
                            
                            self.currencyfilterLabel.isHidden = true
                        }
                    }
                    //No Start / End Date Selected
                    //----------------------------
                    else{
                        self.filterByStart              = ""
                        self.filterByEnd                = ""
                        self.datefilterLabel.isHidden   = true
                        
                        if snapshot.hasChild("OldWagesFilter"){
                            //[No Date] Show All
                            self.scenario            = 33
                            self.oldFilterByWages    = true
                            self.filterByWages       = snapshot.childSnapshot(forPath: "OldWagesFilter").value as! Double
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            self.currencyfilterLabel.text       = "None"
                            self.currencyfilterLabel.isHidden   = false
            
                        }else if (snapshot.hasChild("WagesFilter")){
                            //[No Date] Selected Wages
                            self.scenario            = 3
                            self.oldFilterByWages    = false
                            self.filterByWages       = snapshot.childSnapshot(forPath: "WagesFilter").value as! Double
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                            
                            //Show Currency Filter Label
                            self.currencyfilterLabel.text       = self.getWagesFilterText(wages: self.filterByWages)
                            self.currencyfilterLabel.isHidden   = false
                        
                        }else{
                            //[No Date] Default
                            self.scenario           = 33
                            self.oldFilterByWages   = true
                            self.filterByWages      = 1111
                            
                            self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                        }
                    }
                }else{
                    print("No Filter SnapShot")
                    self.scenario        = 33
                    self.filterByStart   = ""
                    self.filterByEnd     = ""
                    self.oldFilterByWages    = true
                    self.filterByWages       = 1111
                    self.checkUserLocation(filterByStart: self.filterByStart, filterByEnd: self.filterByEnd, filterByWages: self.filterByWages, scenario: self.scenario, categoryNumber: self.categoryNumber)
                    self.currencyfilterLabel.text        = "None"
                    self.currencyfilterLabel.isHidden    = false
                    self.datefilterLabel.isHidden        = true
                }
            }) { (error) in
                
                print(error.localizedDescription)
            }
        }
    }
    
    func checkUserLocation(filterByStart: String, filterByEnd: String, filterByWages: Double, scenario: Int, categoryNumber: Int64){
        
        ref = Database.database().reference()
        
        if currentCity != ""{
            ref.child("Job").child(currentCity).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    //Present Search Job Post
                    self.presentSearchJobPost(filterByStart: filterByStart, filterByEnd: filterByEnd, filterByWages: filterByWages, scenario: scenario, categoryNumber: categoryNumber)
                
                }else{
                    print("No Job Found")
                    self.noJobView.isHidden = false
                    self.noJobLabel.text = "\(Utilities.text(forKey: "searchCategories_NoJobMsg1")) \(self.categoryTitle) \(Utilities.text(forKey: "searchCategories_NoJobMsg2")) \(self.currentCity)"
                }
            }) { (error) in
                print("[Check User Location Error]: \(error.localizedDescription)")
            }
        }
    }
    
    
    func presentSearchJobPost(filterByStart: String, filterByEnd: String, filterByWages: Double, scenario: Int , categoryNumber: Int64){
        
        posts.removeAll()
        count                   = 0
        var wagesInt        : Int64    = 0
        var currencyInt     : Int64    = 0
        var wagesCategoryInt: Int64    = 0
        
        var mQueryJob   : DatabaseQuery!

        if (filterByWages != 0) {
            
            // Get Currency Number
            wagesInt            = Int64(filterByWages.truncatingRemainder(dividingBy: 100000))
            let stringintwages  = String(wagesInt)
            currencyInt         = Int64(Int(stringintwages.prefix(2))!)

            //Get Wages Category Number
            wagesCategoryInt = wagesInt % 100
        
        }
        
        let tsLong: Int64 = Int64(Utilities.getCurrentMillis()/1000)

        if (filterByStart != "") {
            startDate = Int64(filterByStart)!
        }
        if (filterByEnd != "") {
            endDate = Int64(filterByEnd)!
        }
        
        let ref = Database.database().reference()
        print("/////////////////////Search Category Scenario = \(scenario)//////////////////////////")
        //Start Time Selected but No End Time
        if (scenario == 1) {
            print("[Check Filter]: Got Wages Filter With Start Date Only.\n")
            //[Start Date] Got Wages filter
            let opsOne : Int64 = (startDate * 100000000) + (wagesCategoryInt * 100000000000000)
            let opsTwo : Int64 = ((currencyInt - 11) * 10000000000000000)
            let opsThree: Int64 = (categoryNumber * 100000000000000000)
            
            
            finalStartTime = -1 * Int64( opsOne + opsTwo + opsThree)
//                    (startDate * 100000000) +
//                    (wagesCategoryInt * 100000000000000) +
//                    ((currencyInt - 11) * 10000000000000000) +
//                    (categoryNumber * 100000000000000000)
//            )
            
            let multiple = (999999 * 100000000) as Int64
            let wagesCategoryIntOpreation : Int64 = Int64(wagesCategoryInt * 100000000000000)
            let currencyIntOperation :Int64 = ((currencyInt - 11) * 1000000000000000)
            let categoryNumOperation :Int64 = Int64(categoryNumber * 100000000000000000)
            
            let endtime :Int64 = tsLong +
                multiple +
                wagesCategoryIntOpreation +
                currencyIntOperation +
                categoryNumOperation
            
            
            let finalEndTime = endtime * -1
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_mostrecent_wagesrange_startdate").queryStarting(atValue: finalEndTime).queryEnding(atValue: finalStartTime)
        }
            
        else if (scenario == 11) {
            print("[Check Filter]: No Wages Filter With Start Date Only\n")

            //[Start Date] No Wages Filter
            
            let startTime   = Int64(
                    (startDate * 10000000000) +
                    (categoryNumber * 10000000000000000)
            )
            finalStartTime  = Int64(-1 * startTime)
            
            let categoryOperation = Int64(categoryNumber * 10000000000000000)
            let endtime =  Int64(
                    tsLong +
                    (999999 * 10000000000) +
                    categoryOperation
            )
            finalEndTime = Int64(endtime * -1)
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_mostrecent_startdate").queryStarting(atValue: finalEndTime).queryEnding(atValue: finalStartTime)
        }
            
        //Start Time and End Time Both Selected
        else if (scenario == 2){
            print("[Check Filter]: Got Wages Filter With Both Start & End Date\n")

            //[Start Date & End Date] Got Wages filter
            
            let tsLongOperation         = Int64(tsLong % 100000000)
            let startDateOperation      = Int64(startDate * 100000000)
            let endDateOperation        = Int64(endDate * 100000000)
            let wagesCategoryOperation  = Int64(wagesCategoryInt * 100000000000000)
            let currencyIntOperation    = Int64((currencyInt - 11) * 10000000000000000)
            let categoryNumberOperation = Int64(categoryNumber * 100000000000000000)

            finalEndTime = Int64(-1 * Int64((tsLongOperation + endDateOperation + wagesCategoryOperation + currencyIntOperation + categoryNumberOperation)))
            
            finalStartTime = Int64(-1 * Int64(startDateOperation + wagesCategoryOperation + currencyIntOperation + categoryNumberOperation))
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_mostrecent_wagesrange_startdate").queryStarting(atValue: finalEndTime).queryEnding(atValue: finalStartTime)
        }
        
        else if (scenario == 22){
            print("[Check Filter]: No Wages Filter With Both Start & End Date\n")

            //[Start Date & End Date] No Wages Filter
            
            let startDateOps    = Int64(startDate * 10000000000)
            let categoryNumOps  = Int64(categoryNumber * 10000000000000000)
            let endDateOps      = Int64(endDate * 10000000000)
            
            finalStartTime    = Int64(-1 * (startDateOps + categoryNumOps))
            finalEndTime      = Int64(-1 * ((tsLong) + endDateOps + categoryNumOps))
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_mostrecent_startdate").queryStarting(atValue: finalEndTime).queryEnding(atValue: finalStartTime)
        }
        
        // No Start Date & End Date Selected
        
        else if (scenario == 3){
            //[No Date] Got Wages Filter
            let currencyLong        = Int64(currencyInt * 1000000000000)
            let wagesCatLong        = Int64(wagesCategoryInt * 10000000000)
            let catNumLong          = Int64(categoryNumber * 100000000000000)
            let endWagesFilter      = -1 * (tsLong + wagesCatLong + currencyLong + catNumLong)
            let startWagesFilter    = -1 * (wagesCatLong + currencyLong + catNumLong)
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_mostrecent_wagesrange").queryStarting(atValue: endWagesFilter).queryEnding(atValue: startWagesFilter)
        }
        
        else if (scenario == 33){
            //[No Date] No Wages Filter
            
            let catNumLong  = Int64(categoryNumber * 10000000000)
            let startTime   = -1 * (tsLong + catNumLong)
            let endTime     = -1 * (catNumLong)
            
            mQueryJob = ref.child("Job").child(currentCity).queryOrdered(byChild: "category_negatedtime").queryStarting(atValue: startTime).queryEnding(atValue: endTime)
        }else{
            return
        }
        
        let queryRef = mQueryJob.queryLimited(toFirst: UInt(loadLimit))
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()){
                print("[Filtered Job Details Exist]")
                let jobDataSnapshot = snapshot.children.allObjects as! [DataSnapshot]
                
                for details in jobDataSnapshot{
                    let postDetails = Post()
                    print(details)
                    let title       = details.childSnapshot(forPath: "title").value as! String
                    let desc        = details.childSnapshot(forPath: "desc").value as! String
                    let category    = details.childSnapshot(forPath: "category").value as! String
                    let company     = details.childSnapshot(forPath: "company").value as! String
                    let fullAddress = details.childSnapshot(forPath: "fulladdress").value as! String
                    let postImage   = details.childSnapshot(forPath: "postimage").value as! String
                    let postKey     = details.childSnapshot(forPath: "postkey").value as! String
                    let city        = details.childSnapshot(forPath: "city").value as! String
                    let closed      = details.childSnapshot(forPath: "closed").value as! String
                    
                    self.categoryFirstPostTime       = details.childSnapshot(forPath: "category_negatedtime").value as! Int64
                    print("categoryFirstPostTime = \(self.categoryFirstPostTime)")
                    
                    self.categoryMostRecentStartDate = details.childSnapshot(forPath: "category_mostrecent_startdate").value as! Int64
                    print("categoryMostRecentStartDate = \(self.categoryMostRecentStartDate)")
                    
                    self.categoryMostRecentWagesRange = details.childSnapshot(forPath: "category_mostrecent_wagesrange").value as! Int64
                    print("categoryMostRecentWagesRange = \(self.categoryMostRecentWagesRange)")
                    
                    self.categoryMostREcentWagesRangeStartDate = (details.childSnapshot(forPath: "category_mostrecent_wagesrange_startdate").value as! NSNumber).int64Value
                    print("categoryMostREcentWagesRangeStartDate = \(self.categoryMostREcentWagesRangeStartDate)")
                    
                    if details.hasChild("wages"){
                        let wages = details.childSnapshot(forPath: "wages").value as! String
                        postDetails.postWages = wages
                    }
                    if details.hasChild("date"){
                        let date = details.childSnapshot(forPath: "date").value as! String
                        postDetails.postDate = date
                    }
                    
                    postDetails.postTitle   = title
                    postDetails.postDesc    = desc
                    postDetails.postCategory = category
                    postDetails.postCompany = company
                    postDetails.fullAddress = fullAddress
                    postDetails.postImage   = postImage
                    postDetails.postKey     = postKey
                    postDetails.postCity    = city
                    postDetails.postClosed  = closed
                    
                    if (category == self.categoryTitle){
                        print("[Selected Category Matched with Job]")
                        self.count+=1
                        
                        if(self.count != self.loadLimit){
                            
                            if (closed == "false"){
                                print("Jobtitle \(self.count): \(title)")
                                self.posts.append(postDetails)
                            }
                        }
                    }
                }
            
                if (self.posts.isEmpty){
                    self.loadingView.isHidden = true
                    self.noJobLabel.text      = "\(Utilities.text(forKey: "searchCategories_NoJobMsg1")) \(self.categoryTitle) \(Utilities.text(forKey: "searchCategories_NoJobMsg2")) \(self.currentCity)"
                    self.noJobView.isHidden   = false
                    self.noJobLabel.isHidden  = false
                }else{
                    self.loadingView.isHidden = true
                    self.noJobView.isHidden   = true
                    self.noJobLabel.isHidden  = true
                    self.jobTableView.reloadData()
                    self.removeLoadingScreen()
                }
                
            }else{
                print("No Job To Show")
                self.loadingView.isHidden = true
                self.noJobView.isHidden = false
                self.noJobLabel.text = "\(Utilities.text(forKey: "searchCategories_NoJobMsg1")) \(self.categoryTitle) \(Utilities.text(forKey: "searchCategories_NoJobMsg2")) \(self.currentCity)"
                self.noJobLabel.isHidden = false
            }
        }) { (error) in
            print("[PresentSearchJobPost] Error: \(error.localizedDescription)")
        }
        
        ref.removeAllObservers()

    }
    
    
    func getWagesFilterText(wages: Double) -> String{
        
        //Wages
        let selectedWages = wages.truncatingRemainder(dividingBy: 100)
        var wagesCategory = "", currency = ""
        
        switch selectedWages {
        case 11:
            wagesCategory =  "Less than 5"
            break
        case 12:
            wagesCategory =  "5 to 10"
            break
        case 13:
            wagesCategory = "11 to 20"
            break
        case 14:
            wagesCategory = "21 to 50"
            break
        case 15:
            wagesCategory = "More than 50"
            break
        case 21:
            wagesCategory = "Less than 70"
            break
        case 22:
            wagesCategory = "70 to 100"
            break
        case 23:
            wagesCategory = "101 to 200"
            break
        case 24:
            wagesCategory = "201 to 500"
            break
        case 25:
            wagesCategory = "More than 500"
            break
        case 31:
            wagesCategory = "Less than 1000"
            break
        case 32:
            wagesCategory = "1000 to 1500"
            break
        case 33:
            wagesCategory = "1500 to 2000"
            break
        case 34:
            wagesCategory = "2000 to 5000"
            break
        case 35:
            wagesCategory = "More than 5000"
            break
        default:
            wagesCategory = "None"
            break
        }
        
        //Currency
        
        let selectedWagesInt    = Int(filterByWages.truncatingRemainder(dividingBy: 100000))
        let trimmedWagesInt     = Int(String(selectedWagesInt).prefix(2))
        
        switch trimmedWagesInt! {
      
        case 12:
            currency = "SGD"
            break
        case 13:
            currency = "CHY"
            break
        case 14:
            currency = "USD"
            break
        case 15:
            currency = "GBP"
            break
        case 16:
            currency = "EUR"
            break
        case 17:
            currency = "NTD"
            break
        case 18:
            currency = "HKD"
            break
        case 19:
            currency = "INR"
            break
        case 20:
            currency = "IDR"
            break
        default:
            currency = "MYR"
            break
        }
       
        let wagesString = "( \(currency) ) \(wagesCategory)"
        print("[Get Wages String]: \(wagesString)")
        
        return wagesString
       
    }
    
    
    private func setFooterIndicator(){
        
        pagingindicator.activityIndicatorViewStyle = .gray
        pagingindicator.startAnimating()
        pagingindicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: jobTableView.bounds.width, height: CGFloat(44))
        
        self.jobTableView.tableFooterView = pagingindicator
        self.jobTableView.tableFooterView?.isHidden = false
        
        loadMoreData()
        
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        loadingBall.type            = .ballPulseSync
        loadingBall.startAnimating()
        loadingBallView.isHidden    = false
        loadingBallView.alpha       = 1.0
        loadingView.isHidden        = false
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        
        loadingView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.loadingBallView.alpha = 0.0
        }) { (finished:Bool) in
            self.loadingBall.stopAnimating()
            self.loadingBallView.isHidden = true
        }
        
    }
    
    //MARK:- TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell2
        
        if(posts[indexPath.row].postImage == "0"){
            cell.postImage.image = UIImage(named: "job_bg1")
        }
        else if (posts[indexPath.row].postImage == "1"){
            cell.postImage.image = UIImage(named: "job_bg2")
        }
        else if (posts[indexPath.row].postImage == "2"){
            cell.postImage.image = UIImage(named: "job_bg3")
        }
        else{
            cell.postImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postImage), placeholderImage: UIImage(named: "addphoto_darker_bg"))
            
        }
        
        //cell.postImage.downloadImage(from: self.posts[indexPath.row].postImage)
        
        cell.postTitle.text = posts[indexPath.row].postTitle
        
        cell.postCategory.text = posts[indexPath.row].postCategory
        
        cell.postDescrip.setLineHeight(lineHeight: 2, textstring: posts[indexPath.row].postDesc)
        
        
        if (posts[indexPath.row].postWages == "none"){
            cell.postWages.text = "Wages not disclosed"
        }
        else{
            cell.postWages.text = posts[indexPath.row].postWages
        }
        
        if (posts[indexPath.row].postDate == "none"){
            cell.postDate.text = "No Specified Date"
        }
        else{
            cell.postDate.text = posts[indexPath.row].postDate
        }
        
        
        cell.postCompany.text = posts[indexPath.row].postCompany
        
        cell.postLocation.text = posts[indexPath.row].postLocation
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.postkey = posts[indexPath.row].postKey
        self.selectedcity = posts[indexPath.row].postCity
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
        nextViewController.postid = self.postkey
        nextViewController.city = self.selectedcity
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && !loadingData {
            // print("this is the last cell")
//            loadingData = true
//            setFooterIndicator()
        }
    }

    
    /*func loadData(){
        
        let ref = Database.database().reference()
        
        ref.child("Job").child(currentCity).queryOrdered(byChild: "negatedtime").queryLimited(toFirst: UInt(loadlimit)).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                let postpost = Post()
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                if let userID = restDict["uid"] as? String,
                    let postImage       = restDict["postimage"] as? String,
                    let postTitle       = restDict["title"] as? String,
                    let postCategory    = restDict["category"] as? String,
                    let postDesc        = restDict["desc"] as? String,
                    let postDate        = restDict["date"] as? String,
                    let postWages       = restDict["wages"] as? String,
                    let postCompany     = restDict["company"] as? String,
                    let postClosed      = restDict["closed"] as? String,
                    let postTime        = restDict["negatedtime"] as? TimeInterval,
                    let postKey         = rest.key as? String,
                    let postCity        = restDict["city"] as? String,
                    let postLocation    = restDict["fulladdress"] as? String {
                    
                    postpost.postTitle      = postTitle
                    postpost.postImage      = postImage
                    postpost.userID         = userID
                    postpost.postCategory   = postCategory
                    postpost.postDesc       = postDesc
                    postpost.postDate       = postDate
                    postpost.postWages      = postWages
                    postpost.postCompany    = postCompany
                    postpost.postLocation   = postLocation
                    postpost.postClosed     = postClosed
                    postpost.postKey        = postKey
                    postpost.postCity       = postCity
                    
                    self.titlecity          = postCity
                    
                    if(postClosed == "false"){
                        
                        self.posts.append(postpost)
                        
                        self.lastpostTime = postTime
                    }
                    
                }
            }
            
            self.jobTableView.reloadData()
            self.removeLoadingScreen()

        })
        
        ref.removeAllObservers()
    }*/
    
    func loadMoreData(){
        
        let ref = Database.database().reference()
        
        var firstkey = true
        
        var counttime = 1
        
        var postoldTime: TimeInterval!
        
        ref.child("Job").child(currentCity).queryStarting(atValue: self.lastpostTime).queryLimited(toFirst: UInt(loadLimit+1)).queryOrdered(byChild: "negatedtime").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {return}
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                counttime += 1
                
                let postpost = Post()
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                if let userID = restDict["uid"] as? String,
                    let postImage = restDict["postimage"] as? String,
                    let postTitle = restDict["title"] as? String,
                    let postCategory = restDict["category"] as? String,
                    let postDesc = restDict["desc"] as? String,
                    let postDate = restDict["date"] as? String,
                    let postWages = restDict["wages"] as? String,
                    let postCompany = restDict["company"] as? String,
                    let postClosed = restDict["closed"] as? String,
                    let postKey = rest.key as? String,
                    let postTime = restDict["negatedtime"] as? TimeInterval,
                    let postCity = restDict["city"] as? String,
                    let postLocation = restDict["fulladdress"] as? String {
                    
                    print("loadmoretitle \(postTitle)")
                    
                    postpost.postTitle = postTitle
                    postpost.postImage = postImage
                    postpost.userID = userID
                    postpost.postCategory = postCategory
                    postpost.postDesc = postDesc
                    postpost.postDate = postDate
                    postpost.postWages = postWages
                    postpost.postCompany = postCompany
                    postpost.postLocation = postLocation
                    postpost.postClosed = postClosed
                    postpost.postCity = postCity
                    postpost.postKey = postKey
                    
                    
                    if(firstkey){
                        firstkey = false
                    }
                    else{
                        if(postClosed == "false"){
                            
                            self.posts.append(postpost)
                            
                            self.lastpostTime = postTime
                            
                            if(counttime >= self.loadLimit){
                                if(postTime == postoldTime){
                                    self.loadingData = true
                                }
                                else{
                                    self.loadingData = false
                                }
                            }
                            
                            
                            postoldTime = postTime
                        }
                    }
                    
                }
            }
            
            self.jobTableView.reloadData()
            self.pagingindicator.stopAnimating()
            self.jobTableView.tableFooterView = nil
            self.jobTableView.tableFooterView?.isHidden = true
            
        })
        
        ref.removeAllObservers()
        
        /* Code to refresh table view
         let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
         DispatchQueue.main.asyncAfter(deadline: when) {
         // Your code with delay
         //self.loadingData = false
         self.jobtableView.reloadData()
         self.pagingindicator.stopAnimating()
         self.jobtableView.tableFooterView = nil
         self.jobtableView.tableFooterView?.isHidden = true
         
         }*/
    }
    

}
