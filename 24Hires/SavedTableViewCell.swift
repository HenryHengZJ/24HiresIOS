//
//  SavedTableViewCell.swift
//  JobIn24
//
//  Created by MacUser on 22/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class SavedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var postCompany: UILabel!
    
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var closedText: UIView!
    
    @IBOutlet weak var removedView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    
    var closetapBtn : (() -> Void)? = nil
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let removedviewBG = removedView.backgroundColor
        let closeviewBG = closedView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        removedView.backgroundColor = removedviewBG
        closedView.backgroundColor = closeviewBG
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let removedviewBG = removedView.backgroundColor
        let closeviewBG = closedView.backgroundColor
        super.setSelected(selected, animated: animated)
        removedView.backgroundColor = removedviewBG
        closedView.backgroundColor = closeviewBG
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let closetap = UITapGestureRecognizer(target: self, action: #selector(self.closeTap(_:)))
        closetap.cancelsTouchesInView = false
        
        closeBtn.addGestureRecognizer(closetap)
    }
    
    @objc func closeTap(_ sender: UITapGestureRecognizer) {
        if let btnAction = self.closetapBtn
        {
            btnAction()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.postImage.layer.cornerRadius = self.postImage.bounds.size.width/2
        self.postImage.layer.masksToBounds = false
        self.postImage.layer.shouldRasterize = true
        self.postImage.layer.rasterizationScale = UIScreen .main.scale
        self.postImage.backgroundColor = UIColor.clear
        self.postImage.layer.borderWidth = 0
        self.postImage.clipsToBounds = true
        
        self.closedView.layer.cornerRadius = self.closedView.bounds.size.width/2
        self.closedView.layer.masksToBounds = false
        self.closedView.layer.shouldRasterize = true
        self.closedView.layer.rasterizationScale = UIScreen .main.scale
        self.closedView.layer.borderWidth = 0
        self.closedView.clipsToBounds = true
        
        self.removedView.layer.cornerRadius = self.removedView.bounds.size.width/2
        self.removedView.layer.masksToBounds = false
        self.removedView.layer.shouldRasterize = true
        self.removedView.layer.rasterizationScale = UIScreen .main.scale
        self.removedView.layer.borderWidth = 0
        self.removedView.clipsToBounds = true
        
        self.closedText.layer.cornerRadius = self.closedText.bounds.size.width/2
        self.closedText.layer.masksToBounds = false
        self.closedText.layer.shouldRasterize = true
        self.closedText.layer.rasterizationScale = UIScreen .main.scale
        self.closedText.layer.borderWidth = 0
        self.closedText.clipsToBounds = true
        
        self.cardView.layer.cornerRadius = 5
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.shouldRasterize = true
        self.cardView.layer.rasterizationScale = UIScreen .main.scale
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.borderWidth = 0
        self.cardView.clipsToBounds = true
        
        
        
        self.closeBtn.imageEdgeInsets = UIEdgeInsets(top:5,left:5, bottom:5, right:5)
        
        
    }
    
}
