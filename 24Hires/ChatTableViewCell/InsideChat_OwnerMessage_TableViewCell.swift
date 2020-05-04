//
//  InsideChat_OwnerMessage_TableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 01/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class InsideChat_OwnerMessage_TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ownerImage: UIImageView!
    
    @IBOutlet weak var pastTimeStackView: UIStackView!
    
    @IBOutlet weak var pastTimeLabel: UILabel!
    
    @IBOutlet weak var ownerMessage: MessageLabelPadding!
    
    @IBOutlet weak var ownerTime: UILabel!
    
    @IBOutlet weak var pasTimeHeight: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.ownerMessage.layer.cornerRadius = 10
        self.ownerMessage.layer.masksToBounds = true
        
        self.ownerImage.layer.cornerRadius = 25
        self.ownerImage.clipsToBounds = true
        self.ownerImage.backgroundColor = UIColor.clear
        
    }

}
