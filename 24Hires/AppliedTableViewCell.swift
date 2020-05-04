//
//  AppliedTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import CircleProgressView
import UICircularProgressRing
import FirebaseAuth
import FirebaseDatabase

class AppliedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var shortlistlbl: UILabel!
    
    @IBOutlet weak var waitingreplylbl: UILabel!
    
    @IBOutlet weak var timeleftlbl: UILabel!
    
    @IBOutlet weak var rejectedlbl: UILabel!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postCompany: UILabel!
    
    @IBOutlet weak var notificationWidth: NSLayoutConstraint!
    
    @IBOutlet weak var notificationDot: UIView!
    
    @IBOutlet weak var notificationDot2: UIView!
    
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var closedText: UIView!
    
    @IBOutlet weak var removedText: UILabel!
    
    @IBOutlet weak var removedView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var acceptedjobView: UIView!
    
    @IBOutlet weak var rejectedjobView: UIView!
    
    @IBOutlet weak var updatejobView: UIView!
    
    @IBOutlet weak var viewjobBtn: UIButton!
    
    @IBOutlet weak var acceptjobLabel: UILabel!
    
    @IBOutlet weak var viewmoreBtn: UIButton!
    
    
    var endDate: Date!
    
    var nowDate: Date!
    
    var WaitingOver: Bool!
    
    var posterUid: String!
    
    var postKey: String!
    
    var viewmoretapBtn : (() -> Void)? = nil
    
    var viewjobtapBtn : (() -> Void)? = nil
    
    var closetapBtn : (() -> Void)? = nil
    
    var viewjobclickBtn : (() -> Void)? = nil
    
    
    var tap: UILongPressGestureRecognizer!
    var jobtap: UILongPressGestureRecognizer!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let removedviewBG = removedView.backgroundColor
        let closeviewBG = closedView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        removedView.backgroundColor = removedviewBG
        closedView.backgroundColor = closeviewBG
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let removedviewBG = removedView.backgroundColor
        let closeviewBG = closedView.backgroundColor
        super.setSelected(selected, animated: animated)
        removedView.backgroundColor = removedviewBG
        closedView.backgroundColor = closeviewBG
    }
    
    
    @objc func updateUI2(){
        
        
        self.nowDate = Date()
        
        let diffDateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: nowDate, to: endDate)
        
        let hours = Int(diffDateComponents.hour!)
        let Doublehours = Double(hours)
        
        let minutes = Int(diffDateComponents.minute!)
        
        let seconds = Int(diffDateComponents.second!)
        
        if(endDate > nowDate){
            
            let xstrTimeLeft = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
            
            progressRing.setProgress(to: CGFloat(Doublehours+1.0), duration: 1.0)
            
            timeleftlbl.text = xstrTimeLeft
        }
        else{
            
            if(WaitingOver == false){
                // set rejected to true, progressview to 0, then set WaitingOver to true
                
                let currentUser = Auth.auth().currentUser
                
                if(currentUser != nil){
                    
                    let uid = currentUser?.uid
                    
                    let ref = Database.database().reference()
                    ref.child("UserActivities").child(uid!).child("Applied").child(self.postKey).child("status").setValue("appliedrejected", withCompletionBlock: { (error, snapshot) in
                        if error != nil {
                            print("oops, an error")
                        } else {
                            print("completed")
                            self.progressRing.setProgress(to: 0.0, duration: 0.0)
                            //self.progressRing.progress = 0.0
                            self.WaitingOver = true
                        }
                    })
                    
                }
                
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppliedTableViewCell.updateUI2), name: Notification.Name("AppliedCellUpdate"), object: nil)
        
        progressRing.setProgress(to: CGFloat(0.0), duration: 1.0)
        
        tap = UILongPressGestureRecognizer(target: self, action: #selector(self.viewmoreTap(_:)))
        tap.minimumPressDuration = 0.5
        // tap.cancelsTouchesInView = false
        
        let viewMorePress = UITapGestureRecognizer(target: self, action: #selector(self.viewMorePress(_:)))
        
        /*let accepttap = UITapGestureRecognizer(target: self, action: #selector(self.acceptTap(_:)))
        
        let rejecttap = UITapGestureRecognizer(target: self, action: #selector(self.rejectTap(_:)))
        
        let updatetap = UITapGestureRecognizer(target: self, action: #selector(self.updateTap(_:)))*/
        
        let closetap = UITapGestureRecognizer(target: self, action: #selector(self.closeTap(_:)))
        
        closetap.cancelsTouchesInView = false
        viewMorePress.cancelsTouchesInView = false
        
        viewmoreBtn.addGestureRecognizer(tap)   // For Long Press
        
        //For Single Tap
        closeBtn.addGestureRecognizer(closetap)
        viewmoreBtn.addGestureRecognizer(viewMorePress)
   
    }
    
    @objc func viewMorePress(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.viewmoretapBtn
        {
            btnAction()
        }
    }
  
    
    @objc func closeTap(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.closetapBtn
        {
            btnAction()
        }
    }
    
    
    @objc func viewmoreTap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            acceptedjobView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
            rejectedjobView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
            updatejobView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        }
        else if sender.state == .ended {
            acceptedjobView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            rejectedjobView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            updatejobView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.postImage.layer.cornerRadius = self.postImage.bounds.size.width/2
        self.postImage.layer.masksToBounds = false
        self.postImage.layer.shouldRasterize = true
        self.postImage.layer.rasterizationScale = UIScreen .main.scale
        self.postImage.backgroundColor = UIColor.clear
        self.postImage.layer.borderWidth = 0
        self.postImage.clipsToBounds = true
        
        self.cardView.layer.cornerRadius = 5
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.shouldRasterize = true
        self.cardView.layer.rasterizationScale = UIScreen .main.scale
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.borderWidth = 0
        self.cardView.clipsToBounds = true
        
        self.notificationDot.layer.cornerRadius = 5
        self.notificationDot.layer.masksToBounds = false
        self.notificationDot.layer.shouldRasterize = true
        self.notificationDot.layer.rasterizationScale = UIScreen .main.scale
        self.notificationDot.layer.borderWidth = 0
        self.notificationDot.clipsToBounds = true
        
        self.notificationDot2.layer.cornerRadius = 5
        self.notificationDot2.layer.masksToBounds = false
        self.notificationDot2.layer.shouldRasterize = true
        self.notificationDot2.layer.rasterizationScale = UIScreen .main.scale
        self.notificationDot2.layer.borderWidth = 0
        self.notificationDot2.clipsToBounds = true
        
        
        self.closedView.layer.cornerRadius = self.closedView.bounds.size.width/2
        self.closedView.layer.masksToBounds = false
        self.closedView.layer.shouldRasterize = true
        self.closedView.layer.rasterizationScale = UIScreen .main.scale
        self.closedView.layer.borderWidth = 0
        self.closedView.clipsToBounds = true
        
        self.closedText.layer.cornerRadius = self.closedText.bounds.size.width/2
        self.closedText.layer.masksToBounds = false
        self.closedText.layer.shouldRasterize = true
        self.closedText.layer.rasterizationScale = UIScreen .main.scale
        self.closedText.layer.borderWidth = 0
        self.closedText.clipsToBounds = true
        
        self.removedView.layer.cornerRadius = self.removedView.bounds.size.width/2
        self.removedView.layer.masksToBounds = false
        self.removedView.layer.shouldRasterize = true
        self.removedView.layer.rasterizationScale = UIScreen .main.scale
        self.removedView.layer.borderWidth = 0
        self.removedView.clipsToBounds = true
        
        
        self.closeBtn.imageEdgeInsets = UIEdgeInsets(top:5,left:5, bottom:5, right:5)
        
    }
    
}
