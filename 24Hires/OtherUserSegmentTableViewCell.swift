//
//  OtherUserSegmentTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 18/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class OtherUserSegmentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var segmentView: UIView!
    
    @IBOutlet weak var swsegmentControl: OtherUserSegmentedControl!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
