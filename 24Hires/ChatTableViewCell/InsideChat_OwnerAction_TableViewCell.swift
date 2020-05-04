//
//  InsideChat_OwnerAction_TableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 01/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class InsideChat_OwnerAction_TableViewCell: UITableViewCell {
    
    @IBOutlet weak var ownerImage: UIImageView!
    
    @IBOutlet weak var ownerTime: UILabel!
    
    @IBOutlet weak var ownerMessage: MessageLabelPadding!
    
    @IBOutlet weak var pastTimeStackView: UIStackView!
    
    @IBOutlet weak var pastTimeLabel: UILabel!
    
    @IBOutlet weak var pastTimeHeight: NSLayoutConstraint!

    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var titleLabel: MessageLabelPadding!
    
    @IBOutlet weak var descripLabel: MessageLabelPadding!
    
    @IBOutlet weak var jobStackView: UIStackView!
    
    var tapBtn : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sizeToFit()
        layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.detailsTap(_:)))
        
        jobStackView.addGestureRecognizer(tap)
    }

    
    @objc func detailsTap(_ sender: UITapGestureRecognizer) {
        print("detailsTap")
        if let btnAction = self.tapBtn
        {
            btnAction()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.ownerMessage.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            self.ownerMessage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.ownerMessage.layer.masksToBounds = true
    
        self.ownerImage.layer.cornerRadius = 25
        self.ownerImage.clipsToBounds = true
        self.ownerImage.backgroundColor = UIColor.clear
        
        self.actionView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            self.actionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.actionView.layer.masksToBounds = true
     
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let ownerMessageBG = ownerMessage.backgroundColor
        let actionViewBG = actionView.backgroundColor
        let titleLabelBG = titleLabel.backgroundColor
        let descripLabelBG = descripLabel.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        ownerMessage.backgroundColor = ownerMessageBG
        actionView.backgroundColor = actionViewBG
        titleLabel.backgroundColor = titleLabelBG
        descripLabel.backgroundColor = descripLabelBG
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let ownerMessageBG = ownerMessage.backgroundColor
        let actionViewBG = actionView.backgroundColor
        let titleLabelBG = titleLabel.backgroundColor
        let descripLabelBG = descripLabel.backgroundColor
        super.setSelected(selected, animated: animated)
        ownerMessage.backgroundColor = ownerMessageBG
        actionView.backgroundColor = actionViewBG
        titleLabel.backgroundColor = titleLabelBG
        descripLabel.backgroundColor = descripLabelBG
    }
}
