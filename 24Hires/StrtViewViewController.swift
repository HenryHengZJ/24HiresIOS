//
//  StrtViewViewController.swift
//  JobIn24
//
//  Created by MacUser on 24/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import GoogleMaps

class StrtViewViewController: UIViewController {

    @IBOutlet weak var closeedView: UIView!
    
    @IBOutlet weak var panaromaView: GMSPanoramaView!
    
    var latitude: Double!
    var longitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panaromaView.moveNearCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        
        closeedView.layer.cornerRadius = closeedView.frame.size.width/2
        closeedView.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
