//
//  PostCell2.swift
//  JobIn24
//
//  Created by MacUser on 10/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class PostCell2: UITableViewCell {
    
    
    @IBOutlet weak var postImage: ImageViewWithGradient!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postCategory: UILabelPadding!
    
    @IBOutlet weak var postDescrip: UILabel!
    
    @IBOutlet weak var postDate: UILabel!
    
    @IBOutlet weak var postWages: UILabel!
    
    @IBOutlet weak var postCompany: UILabel!
    
    @IBOutlet weak var postLocation: UILabel!
    
    @IBOutlet weak var innerView: UIView!
    
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
        self.postCategory.layer.cornerRadius = 10
        self.postCategory.layer.masksToBounds = false
        self.postCategory.layer.shouldRasterize = true
        self.postCategory.layer.rasterizationScale = UIScreen .main.scale
        self.postCategory.backgroundColor = UIColor.clear
        self.postCategory.layer.borderWidth = 2.0
        self.postCategory.layer.borderColor = UIColor(red: 0.00, green: 0.66, blue: 1.00, alpha: 1.0).cgColor
        
//        innerView.layer.cornerRadius  = 10
////        innerView.clipsToBounds       = true
//        innerView.layer.shadowColor   = UIColor.lightGray.cgColor
//        innerView.layer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
//        innerView.layer.shadowOpacity = 1.0
//        innerView.layer.shadowRadius  = 3.0
//        innerView.layer.masksToBounds = false
        
    }

}
