//
//  SavedCell.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class SavedCell: UITableViewCell {

    @IBOutlet weak var numNewApplicant: RoundNumber!
    
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
        self.numNewApplicant.layer.cornerRadius = self.numNewApplicant.bounds.size.width/2
        self.numNewApplicant.layer.masksToBounds = false
        self.numNewApplicant.layer.shouldRasterize = true
        self.numNewApplicant.layer.rasterizationScale = UIScreen .main.scale
        self.numNewApplicant.backgroundColor = UIColor.red
        
    }


}
