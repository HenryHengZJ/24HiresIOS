//
//  InsideChatTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 17/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class InsideChatTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ownerImage: UIImageView!
   
    @IBOutlet weak var ownerTime: UILabel!
    
    @IBOutlet weak var ownerMessage: MessageLabelPadding!
  
    @IBOutlet weak var receiverImage: UIImageView!
    
    @IBOutlet weak var receiverTime: UILabel!
   
    @IBOutlet weak var receiverMessage: MessageLabelPadding!
    
    @IBOutlet weak var pastTimeStackView: UIStackView!
    
    @IBOutlet weak var pastTimeLabel: UILabel!
    
    @IBOutlet weak var pasTimeHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //this is needed to keep label padding in place
        sizeToFit()
        layoutIfNeeded()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
 self.ownerMessageView.layer.cornerRadius = 10
        self.ownerMessageView.layer.masksToBounds = false
        self.ownerMessageView.layer.shouldRasterize = true
        self.ownerMessageView.layer.rasterizationScale = UIScreen .main.scale
        self.ownerMessageView.backgroundColor = UIColor.clear
        self.ownerMessageView.layer.backgroundColor = UIColor(red: 137/255, green: 208/255, blue: 255/255, alpha: 1.0).cgColor*/
        
        self.receiverMessage.layer.cornerRadius = 10
        self.receiverMessage.layer.masksToBounds = true
        
        self.ownerMessage.layer.cornerRadius = 10
        self.ownerMessage.layer.masksToBounds = true
       
        
        self.ownerImage.layer.cornerRadius = 25
        self.ownerImage.clipsToBounds = true
        self.ownerImage.backgroundColor = UIColor.clear
        
        self.receiverImage.layer.cornerRadius = 25
        self.receiverImage.clipsToBounds = true
        self.receiverImage.backgroundColor = UIColor.clear
      
        
    }

}
