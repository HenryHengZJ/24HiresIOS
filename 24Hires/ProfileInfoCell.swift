//
//  ProfileInfoCell.swift
//  JobIn24
//
//  Created by MacUser on 16/10/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class ProfileInfoCell: UITableViewCell {

   // @IBOutlet weak var profileIcon: UIImageView!
    
    @IBOutlet weak var profileTitle: UILabel!
    
    @IBOutlet weak var profileDescrip: UILabel!
    
    @IBOutlet weak var genderStackView      : UIStackView!
    @IBOutlet weak var birthdateStackView   : UIStackView!
    @IBOutlet weak var weightStackView      : UIStackView!
    @IBOutlet weak var heightStackView      : UIStackView!
    
    @IBOutlet weak var genderLabel      : UILabel!
    @IBOutlet weak var birthdateLabel   : UILabel!
    @IBOutlet weak var weightLabel      : UILabel!
    @IBOutlet weak var heightLabel      : UILabel!
    
    //@IBOutlet weak var editBtn: UIButton!
    
    //var tapBtn : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   /* @IBAction func editTapped(_ sender: Any) {
        
        if let btnAction = self.tapBtn
        {
            btnAction()
        }
    
    }*/
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.editBtn.imageEdgeInsets = UIEdgeInsets(top:2,left:2, bottom:2, right:2)
        
    }

}
