//
//  MessageTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 28/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var lastMessage: UILabel!
    
    @IBOutlet weak var lastTime: UILabel!
    
    @IBOutlet weak var notificationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.width/2
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.shouldRasterize = true
        self.profileImage.layer.rasterizationScale = UIScreen .main.scale
        self.profileImage.backgroundColor = UIColor.clear
        self.profileImage.layer.borderWidth = 0
        self.profileImage.clipsToBounds = true
        
        self.notificationView.layer.cornerRadius = 5
        self.notificationView.layer.masksToBounds = false
        self.notificationView.layer.shouldRasterize = true
        self.notificationView.layer.rasterizationScale = UIScreen .main.scale
        self.notificationView.layer.borderWidth = 0
        self.notificationView.clipsToBounds = true
    }

}
