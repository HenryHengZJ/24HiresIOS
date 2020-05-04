//
//  SegmentTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 26/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class SegmentTableViewCell: UITableViewCell {

    @IBOutlet weak var swsegmentControl: SWSegmentedControl!
    
    @IBOutlet weak var segmentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
