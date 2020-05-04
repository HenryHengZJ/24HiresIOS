//
//  SearchCategoryTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 19/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class SearchCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
