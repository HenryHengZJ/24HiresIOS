//
//  StateTableViewCell.swift
//  JobIn24
//
//  Created by Jeekson Choong on 13/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var stateLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
