//
//  NearbyJobTableViewCell.swift
//  JobIn24
//
//  Created by Jeekson Choong on 05/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class NearbyJobTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel   : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var jobImage     : UIImageView!
    @IBOutlet weak var markerNumber : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.adjustsFontSizeToFitWidth = true
        addressLabel.adjustsFontSizeToFitWidth = true
        
        jobImage.clipsToBounds = true
        jobImage.layer.cornerRadius = jobImage.bounds.height/2
        
        jobImage.contentMode = .scaleAspectFill
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
