//
//  HiredApplicantTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 28/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FirebaseDatabase
import FirebaseAuth

class HiredApplicantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var applicantImage: UIImageView!
    
    @IBOutlet weak var applicantName: UILabel!
    
    @IBOutlet weak var applicantLocation: UILabel!
    
    @IBOutlet weak var workTitle1: UILabel!
    
    @IBOutlet weak var workPlace1: UILabel!
    
    @IBOutlet weak var workTitle2: UILabel!
    
    @IBOutlet weak var workPlace2: UILabel!
    
    @IBOutlet weak var viewmoreBtn: UIButton!
    
    var viewdetailsclickBtn : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewdetailsTap(_ sender: Any) {
        if let btnAction = self.viewdetailsclickBtn
        {
            btnAction()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.applicantImage.layer.cornerRadius = self.applicantImage.bounds.size.width/2
        self.applicantImage.layer.masksToBounds = false
        self.applicantImage.layer.shouldRasterize = true
        self.applicantImage.layer.rasterizationScale = UIScreen .main.scale
        self.applicantImage.backgroundColor = UIColor.clear
        self.applicantImage.layer.borderWidth = 0
        self.applicantImage.clipsToBounds = true
        
        self.viewmoreBtn.layer.cornerRadius = 5
        self.viewmoreBtn.layer.masksToBounds = false
        self.viewmoreBtn.layer.shouldRasterize = true
        self.viewmoreBtn.layer.rasterizationScale = UIScreen .main.scale
        self.viewmoreBtn.backgroundColor = UIColor.clear
        self.viewmoreBtn.layer.borderWidth = 0.8
        self.viewmoreBtn.layer.borderColor = UIColor(red: 0.00, green: 0.66, blue: 1.00, alpha: 1.0).cgColor
        
    }

}
