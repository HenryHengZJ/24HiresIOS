//
//  ProfileReviewCell.swift
//  JobIn24
//
//  Created by MacUser on 16/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Cosmos

class ProfileReviewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userReviewMessage: UILabel!
    
    @IBOutlet weak var reviewRating: CosmosView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
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
  
        self.userImage.layer.cornerRadius = 25
        self.userImage.clipsToBounds = true
        self.userImage.backgroundColor = UIColor.clear
        
    }

}
