//
//  CalendarViewController.swift
//  JobIn24
//
//  Created by MacUser on 30/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Koyomi

class CalendarViewController: UIViewController {
    
    fileprivate let invalidPeriodLength = 90

    @IBOutlet weak var singleBtn: UIButton!
    
    @IBOutlet weak var multipleBtn: UIButton!
    
    @IBOutlet weak var rangeBtn: UIButton!
    
    var selectionMode = 1
    
    var fromstartdate:Date!
    var toenddate:Date!
    var dates: [Date] = []
    
    @IBOutlet fileprivate weak var koyomi: Koyomi! {
        didSet {
           
            let today = Date()
            koyomi.calendarDelegate = self
            koyomi.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            koyomi.weeks = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
            koyomi.style = .tealBlue
            koyomi.select(date: today)
            dates.append(today)
            koyomi.dayPosition = .center
            koyomi.selectionMode = .single(style: .circle)
            koyomi.selectedStyleColor = UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1)
            koyomi
                .setDayFont(size: 14)
                .setWeekFont(size: 14)
        }
    }
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!{
        didSet {
            segmentedControl.setTitle("Previous", forSegmentAt: 0)
            segmentedControl.setTitle("Current", forSegmentAt: 1)
            segmentedControl.setTitle("Next", forSegmentAt: 2)
        }
    }
    
    @IBOutlet fileprivate weak var currentDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDateLabel.text = koyomi.currentDateString()
        
        singleBtn.contentEdgeInsets = UIEdgeInsets(top:15,left:15, bottom:15, right:15)
        singleBtn.layer.cornerRadius = singleBtn.frame.size.height / 2
        
        multipleBtn.contentEdgeInsets = UIEdgeInsets(top:15,left:15, bottom:15, right:15)
        multipleBtn.layer.cornerRadius = multipleBtn.frame.size.height / 2
        
        rangeBtn.contentEdgeInsets = UIEdgeInsets(top:15,left:15, bottom:15, right:15)
        rangeBtn.layer.cornerRadius = rangeBtn.frame.size.height / 2

        changeBtnColor(selectedbtn: singleBtn, unselectedBtn1: multipleBtn, unselectedBtn2: rangeBtn)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func date(_ date: Date, later: Int) -> Date {
        var components = DateComponents()
        components.day = later
        return (Calendar.current as NSCalendar).date(byAdding: components, to: date, options: NSCalendar.Options(rawValue: 0)) ?? date
    }
    
    @IBAction func tappedControl(_ sender: UISegmentedControl) {
        
        let month: MonthType = {
            switch sender.selectedSegmentIndex {
            case 0:
                return .previous
            case 1:
                return .current
            default:
                return .next
            }
        }()
        koyomi.display(in: month)
        displaydates()
    }
    
    func displaydates(){
        if selectionMode == 1 {
            
            // If want to select only one day.
            
             print("dates?? \(dates)")
            
            if(dates.isEmpty == false){
                
                let firstdate = dates[0]
                koyomi.select(date: firstdate)
                koyomi.reloadData()
            }
            
        }
        else if selectionMode == 2 {
            
            // If want to select multiple day.
            
            if(dates.isEmpty == false){
                koyomi.select(dates: dates)
                koyomi.reloadData()
            }

        }
        else{
            
            // If want to select range day
            
            if(fromstartdate != nil && toenddate != nil){
                koyomi.select(date: fromstartdate, to: toenddate)
                koyomi.reloadData()
            }

        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func multiplePressed(_ sender: UIButton) {
        dates.removeAll()
        selectionMode = 2
        changeBtnColor(selectedbtn: multipleBtn, unselectedBtn1: singleBtn, unselectedBtn2: rangeBtn)
        koyomi.selectionMode = .multiple(style: .circle)
        koyomi.unselectAll()
        koyomi.reloadData()
    }
    
    @IBAction func singlePressed(_ sender: UIButton) {
        dates.removeAll()
        selectionMode = 1
        changeBtnColor(selectedbtn: singleBtn, unselectedBtn1: multipleBtn, unselectedBtn2: rangeBtn)
        koyomi.selectionMode = .single(style: .circle)
        koyomi.unselectAll()
        koyomi.reloadData()
    }
    
    @IBAction func rangePressed(_ sender: UIButton) {
        selectionMode = 3
        changeBtnColor(selectedbtn: rangeBtn, unselectedBtn1: multipleBtn, unselectedBtn2: singleBtn)
        koyomi.selectionMode = .sequence(style: .semicircleEdge)
        koyomi.unselectAll()
        koyomi.reloadData()
    }
    
    func changeBtnColor(selectedbtn: UIButton!, unselectedBtn1: UIButton!, unselectedBtn2: UIButton!){
        
       
        selectedbtn.backgroundColor = UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1)
        selectedbtn.layer.borderWidth = 0.0
        selectedbtn.layer.borderColor = UIColor.clear.cgColor
        selectedbtn.setTitleColor(UIColor.white, for: .normal)
       
        unselectedBtn1.backgroundColor = UIColor.clear
        unselectedBtn1.layer.borderWidth = 2.0
        unselectedBtn1.layer.borderColor = UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1).cgColor
        unselectedBtn1.setTitleColor(UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1), for: .normal)
     
        unselectedBtn2.backgroundColor = UIColor.clear
        unselectedBtn2.layer.borderWidth = 2.0
        unselectedBtn2.layer.borderColor = UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1).cgColor
        unselectedBtn2.setTitleColor(UIColor(red: 58/255, green: 178/255, blue: 244/255, alpha: 1), for: .normal)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        var startingdate = ""
        var starrangedate = ""
        var endrangedate = ""
        var labeldate = ""
        
        let startingDateFormatter = DateFormatter()
        startingDateFormatter.dateFormat = "yyMMdd"
        
        let normallabelDateFormatter = DateFormatter()
        normallabelDateFormatter.dateFormat = " dd MMM "
        
        let lastlabelDateFormatter = DateFormatter()
        lastlabelDateFormatter.dateFormat = " dd MMM yy"
        
        if selectionMode == 1 {
          
            if(dates.isEmpty == false){
                
                let firstdate = dates[0]
                labeldate = lastlabelDateFormatter.string(from: firstdate)
                startingdate = startingDateFormatter.string(from: firstdate)
                
                let dateDict: [String: String] = ["labeldate": labeldate, "startdate":startingdate]
                
                NotificationCenter.default.post(name: Notification.Name("updateDate"), object: nil, userInfo: dateDict)
                
                
                dismiss(animated: true, completion: nil)
            }
            else{
                self.emptyDates()
            }
            
        }
        else if selectionMode == 2 {
            
            if(dates.isEmpty == false){
                
                var newdatestring: [String] = []
                
                dates = dates.sorted(by: { $0.compare($1) == .orderedAscending})
                
                let firstdate = dates[0]
                startingdate = startingDateFormatter.string(from: firstdate)
                
                for var newdate in (0..<dates.count) {
                    
                    if (newdate == dates.count - 1) {
                        labeldate = lastlabelDateFormatter.string(from: dates[newdate])
                        newdatestring.append(labeldate)
                    }
                    else {
                        labeldate = normallabelDateFormatter.string(from: dates[newdate])
                        newdatestring.append(labeldate)
                    }
                }
                
                let joiner = "/"
                let joinedStrings = newdatestring.joined(separator: joiner)

                labeldate = joinedStrings
                
                let dateDict: [String: String] = ["labeldate": labeldate, "startdate":startingdate]
                
                NotificationCenter.default.post(name: Notification.Name("updateDate"), object: nil, userInfo: dateDict)
                
                dismiss(animated: true, completion: nil)
            }
            else {
                self.emptyDates()
            }
            
        }
        else{
           
            if(fromstartdate != nil && toenddate != nil){
                startingdate = startingDateFormatter.string(from: fromstartdate)
              
                starrangedate = lastlabelDateFormatter.string(from: fromstartdate)
               
                endrangedate = lastlabelDateFormatter.string(from: toenddate)
                
                labeldate = starrangedate + " to" + endrangedate
                
                let dateDict: [String: String] = ["labeldate": labeldate, "startdate":startingdate]
                
                NotificationCenter.default.post(name: Notification.Name("updateDate"), object: nil, userInfo: dateDict)
                
                dismiss(animated: true, completion: nil)
            }
            else {
                self.emptyDates()
            }
            
        }
    }
    
    
    func emptyDates(){
        
        // create the alert
        let alert = UIAlertController(title: "Empty dates", message: "Please select dates", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
            //self.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            //self.dismiss(animated: true, completion: nil)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - KoyomiDelegate -

extension CalendarViewController: KoyomiDelegate {
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {
        
        print("You Selected: \(date)")
        
        if (selectionMode == 1) {
        
            if (dates.contains(date!)) {
                koyomi.unselect(date: date!)
                dates.removeAll()
            }
            else {
                dates.removeAll()
                dates.append(date!)
            }
        }
        else if (selectionMode == 2) {
            
            if (dates.contains(date!)) {
                koyomi.unselect(date: date!)
                dates = dates.filter() { $0 != date! }
            }
            else {
                dates.append(date!)
            }
        }
        else if (selectionMode == 3) {
            
            dates.removeAll()
        }
      
    }
    
    func koyomi(_ koyomi: Koyomi, currentDateString dateString: String) {
        koyomi.currentDateFormat = "MMM/yyyy"
        currentDateLabel.text = dateString
    }
    
    @objc(koyomi:shouldSelectDates:to:withPeriodLength:)
    func koyomi(_ koyomi: Koyomi, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool {

        toenddate = toDate
        
        if (toenddate == nil) {
            fromstartdate = nil
        }
        else {
            fromstartdate = date
        }
        
        if length > invalidPeriodLength {
            print("More than \(invalidPeriodLength) days are invalid period.")
            return false
        }
        return true
    }
}
