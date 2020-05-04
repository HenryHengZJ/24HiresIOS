//
//  WorkTableViewCell2.swift
//  JobIn24
//
//  Created by MacUser on 26/11/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class WorkTableViewCell2: UITableViewCell {
   
    @IBOutlet weak var workView1: UIView!
    @IBOutlet weak var workCompany1: UILabel!
    @IBOutlet weak var workTitle1: UILabel!
    @IBOutlet weak var workLength: UILabel!
    
    @IBOutlet weak var workView2: UIView!
    @IBOutlet weak var workCompany2: UILabel!
    @IBOutlet weak var workTitle2: UILabel!
    @IBOutlet weak var workLength2: UILabel!

    @IBOutlet weak var workView3: UIView!
    @IBOutlet weak var workCompany3: UILabel!
    @IBOutlet weak var workTitle3: UILabel!
    @IBOutlet weak var workLength3: UILabel!
    
    @IBOutlet weak var workView4: UIView!
    @IBOutlet weak var workCompany4: UILabel!
    @IBOutlet weak var workTitle4: UILabel!
    @IBOutlet weak var workLength4: UILabel!

    @IBOutlet weak var workView5: UIView!
    @IBOutlet weak var workCompany5: UILabel!
    @IBOutlet weak var workTitle5: UILabel!
    @IBOutlet weak var workLength5: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
