//
//  PointsAndRewardsViewController.swift
//  JobIn24
//
//  Created by Jeekson on 16/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class PointsAndRewardsViewController: UIViewController {

    @IBOutlet weak var comingSoonImageView: UIImageView!
    
    var ref = DatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("ComingSoon").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let comingSoonBannerLink = snapshot.value as? String ?? ""
                self.comingSoonImageView.sd_setImage(with: URL(string: comingSoonBannerLink), completed: nil)
                
            }
        }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
