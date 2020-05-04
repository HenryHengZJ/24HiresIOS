//
//  SavedCell.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class PostedCell: UITableViewCell {
    
    @IBOutlet weak var numNewApplicant: RoundNumber!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var numNewApplicantHeight: NSLayoutConstraint!
    
    @IBOutlet weak var newApplicantLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postCompany: UILabel!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var totalApplicantsLabel: UILabel!
    
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var closedText: UIView!
    
    @IBOutlet weak var applicantBtn: UIButton!
    
    var tapBtn : (() -> Void)? = nil
    var actiontapBtn : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let applicanttap = UILongPressGestureRecognizer(target: self, action: #selector(self.applicantTap(_:)))
        applicanttap.minimumPressDuration = 0.5
        applicantBtn.addGestureRecognizer(applicanttap)
        
        let actiontap = UITapGestureRecognizer(target: self, action: #selector(self.actionTap(_:)))
        actionBtn.addGestureRecognizer(actiontap)
        
    }
    
    
    @objc func actionTap(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.actiontapBtn
        {
            btnAction()
        }
    }
    
    
    func applicanttap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            actionBtn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        }
        else if sender.state == .ended {
            actionBtn.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func applicantTap(_ sender: Any) {
        
        if let btnAction = self.tapBtn
        {
            btnAction()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.numNewApplicant.layer.cornerRadius = 10
        self.numNewApplicant.layer.masksToBounds = false
        self.numNewApplicant.layer.shouldRasterize = true
        self.numNewApplicant.layer.rasterizationScale = UIScreen .main.scale
        self.numNewApplicant.backgroundColor = UIColor.red
        self.numNewApplicant.layer.borderWidth = 0
        self.numNewApplicant.clipsToBounds = true
        
        self.postImage.layer.cornerRadius = self.postImage.bounds.size.width/2
        self.postImage.layer.masksToBounds = false
        self.postImage.layer.shouldRasterize = true
        self.postImage.layer.rasterizationScale = UIScreen .main.scale
        self.postImage.backgroundColor = UIColor.clear
        self.postImage.layer.borderWidth = 0
        self.postImage.clipsToBounds = true
        
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
        
        self.cardView.layer.cornerRadius = 5
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.shouldRasterize = true
        self.cardView.layer.rasterizationScale = UIScreen .main.scale
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.borderWidth = 0
        self.cardView.clipsToBounds = true
        
        
        self.actionBtn.imageEdgeInsets = UIEdgeInsets(top:3,left:3, bottom:3, right:3)
        
    }
    
    
}
