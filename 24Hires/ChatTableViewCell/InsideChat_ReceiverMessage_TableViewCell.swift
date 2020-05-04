//
//  InsideChat_ReceiverMessage_TableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 01/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class InsideChat_ReceiverMessage_TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var pastTimeStackView: UIStackView!
    
    @IBOutlet weak var pasTimeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pastTimeLabel: UILabel!
    
   
    @IBOutlet weak var receiverMessage: MessageLabelPadding!
    
    @IBOutlet weak var receiverImage: UIImageView!
    
    @IBOutlet weak var receiverTime: UILabel!
    
    
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
        
        self.receiverMessage.layer.cornerRadius = 10
        self.receiverMessage.layer.masksToBounds = true
        
        self.receiverImage.layer.cornerRadius = 25
        self.receiverImage.clipsToBounds = true
        self.receiverImage.backgroundColor = UIColor.clear
        
    }

}
