//
//  TalentViewController.swift
//  JobIn24
//
//  Created by Jeekson Choong on 28/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TalentViewController: UIViewController {

    @IBOutlet weak var comingSoonImageView: UIImageView!
    
    var ref = DatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        ref.child("TalentComingSoon").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let comingSoonBannerLink = snapshot.value as? String ?? ""
                self.comingSoonImageView.sd_setImage(with: URL(string: comingSoonBannerLink), completed: nil)
                
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
