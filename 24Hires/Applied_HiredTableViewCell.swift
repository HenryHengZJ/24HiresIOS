//
//  Applied_HiredTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 21/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import CircleProgressView
import UICircularProgressRing
import FirebaseAuth
import FirebaseDatabase

class Applied_HiredTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postCompany: UILabel!
   
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var closedText: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var rejectBtn: UIButton!
    
    @IBOutlet weak var acceptBtn: UIButton!
    
    @IBOutlet weak var viewMoreBtn: UIButton!
    
    @IBOutlet weak var viewJobBtn: UIButton!
    
    var viewmoretapBtn : (() -> Void)? = nil
    
    var viewjobtapBtn : (() -> Void)? = nil
    
    var closetapBtn : (() -> Void)? = nil
    
    var acceptjobtapBtn : (() -> Void)? = nil
    
    var rejectjobtapBtn : (() -> Void)? = nil
    
    var viewjobclickBtn : (() -> Void)? = nil
    
    
    var tap: UILongPressGestureRecognizer!
    var jobtap: UILongPressGestureRecognizer!
    
  
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let rejectbtnBG = rejectBtn.backgroundColor
        let acceptBtnBG = acceptBtn.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        rejectBtn.backgroundColor = rejectbtnBG
        acceptBtn.backgroundColor = acceptBtnBG
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let rejectbtnBG = rejectBtn.backgroundColor
        let acceptBtnBG = acceptBtn.backgroundColor
        super.setSelected(selected, animated: animated)
        rejectBtn.backgroundColor = rejectbtnBG
        acceptBtn.backgroundColor = acceptBtnBG
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.progressRing.setProgress(to: 0.0, duration: 0.0)
        
        tap = UILongPressGestureRecognizer(target: self, action: #selector(self.viewmoreTap(_:)))
        tap.minimumPressDuration = 0.5
     //   tap.cancelsTouchesInView = false
      
        let closetap = UITapGestureRecognizer(target: self, action: #selector(self.closeTap(_:)))
        let accepttap = UITapGestureRecognizer(target: self, action: #selector(self.acceptTap(_:)))
        let rejecttap = UITapGestureRecognizer(target: self, action: #selector(self.rejectTap(_:)))
        let viewMorePress = UITapGestureRecognizer(target: self, action: #selector(self.viewMorePress(_:)))

        closetap.cancelsTouchesInView = false
        accepttap.cancelsTouchesInView = false
        rejecttap.cancelsTouchesInView = false
        viewMorePress.cancelsTouchesInView = false
        
        viewMoreBtn.addGestureRecognizer(tap)   // For Long Press
      
        //For Single Tap
        closeBtn.addGestureRecognizer(closetap)
        acceptBtn.addGestureRecognizer(accepttap)
        rejectBtn.addGestureRecognizer(rejecttap)
        viewMoreBtn.addGestureRecognizer(viewMorePress)
        
    }

    
    @objc func acceptTap(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.acceptjobtapBtn
        {
            btnAction()
        }
    }
        
    @objc func rejectTap(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.rejectjobtapBtn
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
    
    
    @objc func viewMorePress(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.viewmoretapBtn
        {
            btnAction()
        }
    }
 
    
    @objc func viewmoreTap(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {
            viewMoreBtn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        }
        else if sender.state == .ended {
            viewMoreBtn.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            
        }
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
       
        self.rejectBtn.layer.masksToBounds = false
        self.rejectBtn.layer.shadowRadius = 3.0
        self.rejectBtn.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.rejectBtn.layer.shadowOffset = CGSize(width: 0, height:3)
        self.rejectBtn.layer.shadowOpacity = 1.0
        
        self.acceptBtn.layer.masksToBounds = false
        self.acceptBtn.layer.shadowRadius = 3.0
        self.acceptBtn.layer.shadowColor = UIColor(red: 0, green:0, blue:0, alpha:0.25).cgColor
        self.acceptBtn.layer.shadowOffset = CGSize(width: 0, height:3)
        self.acceptBtn.layer.shadowOpacity = 1.0

        self.closeBtn.imageEdgeInsets = UIEdgeInsets(top:5,left:5, bottom:5, right:5)
        
    }
    
}
